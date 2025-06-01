import multer from 'multer';
import { S3Client } from '@aws-sdk/client-s3';
import multerS3 from 'multer-s3';
import dotenv from 'dotenv';

dotenv.config();

const s3 = new S3Client({
  region: 'auto',
  endpoint: process.env.CLOUDFLARE_R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.CLOUDFLARE_R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.CLOUDFLARE_R2_SECRET_ACCESS_KEY,
  },
});

const createMulterUpload = (bucket) =>
  multer({
    storage: multerS3({
      s3,
      bucket,
      ACL: 'public-read',
      metadata: (req, file, cb) => {
        cb(null, { fieldName: file.fieldname });
      },
      key: (req, file, cb) => {
        cb(null, `${Date.now().toString()}-${file.originalname}`);
      },
    }),
  });

export const generateImageUrl = (bucket, fileName) => {
  return `https://${bucket}.mypsikolog.id/${fileName}`;
};

export const imageUpload = createMulterUpload(process.env.CLOUDFLARE_IMAGE_BUCKET);
export const chatImageUpload = createMulterUpload(process.env.CLOUDFLARE_CHAT_IMAGE_BUCKET);
export const bannerUpload = createMulterUpload(process.env.CLOUDFLARE_BANNER_BUCKET);
export const audioUpload = createMulterUpload(process.env.CLOUDFLARE_AUDIO_BUCKET);
export const fileUpload = createMulterUpload(process.env.CLOUDFLARE_FILE_BUCKET);
export const profileUpload = createMulterUpload(process.env.CLOUDFLARE_PROFILE_BUCKET);
export const iconsUpload = createMulterUpload(process.env.CLOUDFLARE_ICON_BUCKET);
export const galleryUpload = createMulterUpload(process.env.CLOUDFLARE_GALLERY_BUCKET); // Added for gallery images
export { s3 };
