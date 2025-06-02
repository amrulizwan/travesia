import mongoose from 'mongoose';
import Province from '../models/Province.js';
import fs from 'fs';
import path from 'path';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import dotenv from 'dotenv';

dotenv.config();

const s3Client = new S3Client({
  region: 'auto',
  endpoint: process.env.CLOUDFLARE_R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.CLOUDFLARE_R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.CLOUDFLARE_R2_SECRET_ACCESS_KEY,
  },
});

const IMAGE_CDN_URL = 'https://image.mypsikolog.id';

const provinces = [
  { name: 'Aceh', code: 'ID-AC' },
  { name: 'Sumatera Utara', code: 'ID-SU' },
  { name: 'Sumatera Barat', code: 'ID-SB' },
  { name: 'Riau', code: 'ID-RI' },
  { name: 'Jambi', code: 'ID-JA' },
  { name: 'Sumatera Selatan', code: 'ID-SS' },
  { name: 'Bengkulu', code: 'ID-BE' },
  { name: 'Lampung', code: 'ID-LA' },
  { name: 'Kepulauan Bangka Belitung', code: 'ID-BB' },
  { name: 'Kepulauan Riau', code: 'ID-KR' },
  { name: 'DKI Jakarta', code: 'ID-JK' },
  { name: 'Jawa Barat', code: 'ID-JB' },
  { name: 'Jawa Tengah', code: 'ID-JT' },
  { name: 'DI Yogyakarta', code: 'ID-YO' },
  { name: 'Jawa Timur', code: 'ID-JI' },
  { name: 'Banten', code: 'ID-BT' },
  { name: 'Bali', code: 'ID-BA' },
  { name: 'Nusa Tenggara Barat', code: 'ID-NB' },
  { name: 'Nusa Tenggara Timur', code: 'ID-NT' },
  { name: 'Kalimantan Barat', code: 'ID-KB' },
  { name: 'Kalimantan Tengah', code: 'ID-KT' },
  { name: 'Kalimantan Selatan', code: 'ID-KS' },
  { name: 'Kalimantan Timur', code: 'ID-KI' },
  { name: 'Kalimantan Utara', code: 'ID-KU' },
  { name: 'Sulawesi Utara', code: 'ID-SA' },
  { name: 'Sulawesi Tengah', code: 'ID-ST' },
  { name: 'Sulawesi Selatan', code: 'ID-SN' },
  { name: 'Sulawesi Tenggara', code: 'ID-SG' },
  { name: 'Gorontalo', code: 'ID-GO' },
  { name: 'Sulawesi Barat', code: 'ID-SR' },
  { name: 'Maluku', code: 'ID-MA' },
  { name: 'Maluku Utara', code: 'ID-MU' },
  { name: 'Papua', code: 'ID-PA' },
  { name: 'Papua Barat', code: 'ID-PB' },
];

const generateUniqueFileName = (originalName, provinceCode) => {
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2, 15);
  const extension = path.extname(originalName);
  return `${timestamp}-${random}-${provinceCode.toLowerCase()}${extension}`;
};

const uploadToS3 = async (filePath, fileName) => {
  const fileContent = fs.readFileSync(filePath);
  const command = new PutObjectCommand({
    Bucket: process.env.CLOUDFLARE_IMAGE_BUCKET,
    Key: `provinces/${fileName}`,
    Body: fileContent,
    ContentType: `image/${path.extname(fileName).slice(1)}`,
  });

  await s3Client.send(command);
  // Return complete URL instead of just the path
  return `${IMAGE_CDN_URL}/provinces/${fileName}`;
};

const seedProvinces = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://127.0.0.1:27017/travesia', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    // Clear existing provinces
    await Province.deleteMany({});

    // Get all images from assets folder
    const imagesPath = path.join(process.cwd(), 'assets');
    const images = fs.readdirSync(imagesPath).filter((file) => file.endsWith('.png'));

    if (images.length === 0) {
      throw new Error('No images found in assets folder');
    }

    // Upload images to S3 and create provinces
    const provinceData = await Promise.all(
      provinces.map(async (province, index) => {
        // Use modulo to cycle through available images if we have fewer images than provinces
        const imageFile = images[index % images.length];
        const imagePath = path.join(imagesPath, imageFile);
        const uniqueFileName = generateUniqueFileName(imageFile, province.code);

        try {
          const s3Path = await uploadToS3(imagePath, uniqueFileName);
          return {
            ...province,
            image: s3Path,
          };
        } catch (error) {
          console.error(`Error uploading image for ${province.name}:`, error);
          throw error;
        }
      })
    );

    // Insert provinces
    await Province.insertMany(provinceData);

    console.log('Provinces seeded successfully with S3 images!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding provinces:', error);
    process.exit(1);
  } finally {
    await mongoose.disconnect();
  }
};

seedProvinces();
