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
  getWisataByProvince,
} from '../controllers/wisataController.js';
import { protect, authorizeRoles } from '../middlewares/authMiddleware.js';
import { galleryUpload } from '../middlewares/uploadMiddleware.js'; // Corrected import and Assuming galleryUpload is configured

const router = express.Router();

router.get('/', getAllWisata);
router.get('/:id', getWisataById);
router.get('/province/:provinceId', getWisataByProvince);

router.post('/', protect, authorizeRoles('admin', 'pengelola'), tambahWisata);
router.put(
  '/:id',
  protect,
  authorizeRoles('admin', 'pengelola'),
  updateWisata
);
router.delete('/:id', protect, authorizeRoles('admin', 'pengelola'), hapusWisata);

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
router.put('/:id/assign-pengelola', protect, authorizeRoles('admin'), changeWisataPengelola);

export default router;
