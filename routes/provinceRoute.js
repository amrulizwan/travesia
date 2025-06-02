import express from 'express';
import { getAllProvinces, addProvince, updateProvince, deleteProvince } from '../controllers/provinceController.js';
import { verifyToken, isAdmin } from '../middlewares/authMiddleware.js';
import { provinceUpload, handleUploadError } from '../middlewares/uploadMiddleware.js';

const router = express.Router();

router.get('/', getAllProvinces);
router.post('/', verifyToken, isAdmin, provinceUpload.single('image'), handleUploadError, addProvince);
router.put('/:id', verifyToken, isAdmin, provinceUpload.single('image'), handleUploadError, updateProvince);
router.delete('/:id', verifyToken, isAdmin, deleteProvince);

export default router;
