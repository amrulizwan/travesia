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

const createMulterUpload = (bucket) => {
  if (!bucket) {
    throw new Error(`Bucket name is not configured in environment variables`);
  }

  return multer({
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
};

// Validate bucket names before creating uploaders
const validateBucket = (bucketName, envVar) => {
  if (!bucketName) {
    throw new Error(`${envVar} is not configured in environment variables`);
  }
  return bucketName;
};

export const imageUpload = createMulterUpload(validateBucket(process.env.CLOUDFLARE_IMAGE_BUCKET, 'CLOUDFLARE_IMAGE_BUCKET'));
export const chatImageUpload = createMulterUpload(validateBucket(process.env.CLOUDFLARE_CHAT_IMAGE_BUCKET, 'CLOUDFLARE_CHAT_IMAGE_BUCKET'));
export const bannerUpload = createMulterUpload(validateBucket(process.env.CLOUDFLARE_BANNER_BUCKET, 'CLOUDFLARE_BANNER_BUCKET'));
export const audioUpload = createMulterUpload(validateBucket(process.env.CLOUDFLARE_AUDIO_BUCKET, 'CLOUDFLARE_AUDIO_BUCKET'));
export const fileUpload = createMulterUpload(validateBucket(process.env.CLOUDFLARE_FILE_BUCKET, 'CLOUDFLARE_FILE_BUCKET'));
export const profileUpload = createMulterUpload(validateBucket(process.env.CLOUDFLARE_PROFILE_BUCKET, 'CLOUDFLARE_PROFILE_BUCKET'));
export const iconsUpload = createMulterUpload(validateBucket(process.env.CLOUDFLARE_ICON_BUCKET, 'CLOUDFLARE_ICON_BUCKET'));
export const galleryUpload = createMulterUpload(validateBucket(process.env.CLOUDFLARE_IMAGE_BUCKET, 'CLOUDFLARE_IMAGE_BUCKET'));

export { s3 };
