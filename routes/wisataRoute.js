import express from 'express';
import {
  tambahWisata,
  updateWisata,
  hapusWisata,
  tambahGambarGaleri,
  verifikasiGambarGaleri,
  getAllWisata,
  getWisataById,
  changeWisataPengelola, // Added new function
} from '../controllers/wisataController.js';
import { protect, authorizeRoles } from '../middlewares/authMiddleware.js';
import { galleryUpload } from '../middlewares/uploadMiddleware.js'; // Corrected import and Assuming galleryUpload is configured

const router = express.Router();

// Public routes (accessible by anyone, even unauthenticated)
router.get('/', getAllWisata); // Or use protect if all wisata should be behind login
router.get('/:id', getWisataById);

// Routes for creating, updating, deleting Wisata (Admin and Pengelola)
router.post(
  '/',
  protect,
  authorizeRoles('admin', 'pengelola'),
  // galleryUpload.single('namaFieldUntukGambarUtamaWisata'), // If Wisata has a main image uploaded during creation
  tambahWisata
);
router.put(
  '/:id',
  protect,
  authorizeRoles('admin', 'pengelola'),
  // galleryUpload.single('namaFieldUntukGambarUtamaWisata'), // If Wisata has a main image updated
  updateWisata
);
router.delete('/:id', protect, authorizeRoles('admin', 'pengelola'), hapusWisata);

// Routes for gallery management
router.post(
  '/:id/gallery',
  protect,
  authorizeRoles('admin', 'pengelola'),
  galleryUpload.single('gambar'), // Assuming 'gambar' is the field name for the gallery image
  tambahGambarGaleri
);
router.put(
  '/:wisataId/gallery/:gambarId/verify',
  protect,
  authorizeRoles('admin'), // Only admin can verify images
  verifikasiGambarGaleri
);

// Admin: Change Pengelola of a Wisata
router.put(
  '/:id/assign-pengelola',
  protect,
  authorizeRoles('admin'),
  changeWisataPengelola
);

export default router;
