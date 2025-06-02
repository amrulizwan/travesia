import { faker } from '@faker-js/faker/locale/id_ID';
import fs from 'fs';
import path from 'path';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import dotenv from 'dotenv';

dotenv.config();

const IMAGE_CDN_URL = process.env.IMAGE_CDN_URL || 'https://image.mypsikolog.id';

const s3Client = new S3Client({
  region: 'auto',
  endpoint: process.env.CLOUDFLARE_R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.CLOUDFLARE_R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.CLOUDFLARE_R2_SECRET_ACCESS_KEY,
  },
});

export const generateUniqueFileName = (originalName, prefix) => {
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2, 15);
  const extension = path.extname(originalName);
  return `${timestamp}-${random}-${prefix}${extension}`;
};

export const uploadToS3 = async (filePath, fileName, folder) => {
  const fileContent = fs.readFileSync(filePath);
  const command = new PutObjectCommand({
    Bucket: process.env.CLOUDFLARE_IMAGE_BUCKET,
    Key: `${folder}/${fileName}`,
    Body: fileContent,
    ContentType: `image/${path.extname(fileName).slice(1)}`,
  });

  await s3Client.send(command);
  return `${IMAGE_CDN_URL}/${folder}/${fileName}`;
};

export const getRandomImage = async (folder) => {
  const imagesPath = path.join(process.cwd(), 'assets');
  const images = fs.readdirSync(imagesPath).filter((file) => file.endsWith('.png'));
  const randomImage = images[Math.floor(Math.random() * images.length)];
  const imagePath = path.join(imagesPath, randomImage);
  const uniqueFileName = generateUniqueFileName(randomImage, folder);
  const imageUrl = await uploadToS3(imagePath, uniqueFileName, folder);
  return imageUrl;
};
