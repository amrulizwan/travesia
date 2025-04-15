import multer from 'multer';
import path from 'path';
import fs from 'fs';

const ensureUploadDir = (dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

const uploadDirs = {
  profile: 'uploads/profile',
  gallery: 'uploads/gallery',
  fasilitas: 'uploads/fasilitas',
};

Object.values(uploadDirs).forEach(ensureUploadDir);

const storage = (folder) =>
  multer.diskStorage({
    destination: (req, file, cb) => {
      cb(null, folder);
    },
    filename: (req, file, cb) => {
      const ext = path.extname(file.originalname);
      const filename = `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
      cb(null, filename);
    },
  });

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Hanya file gambar yang diperbolehkan!'), false);
  }
};

export const uploadProfile = multer({ storage: storage(uploadDirs.profile), fileFilter });
export const uploadGallery = multer({ storage: storage(uploadDirs.gallery), fileFilter });
export const uploadFasilitas = multer({ storage: storage(uploadDirs.fasilitas), fileFilter });
