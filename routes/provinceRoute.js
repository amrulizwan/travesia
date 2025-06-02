import express from 'express';
import { getAllProvinces, addProvince, updateProvince, deleteProvince } from '../controllers/provinceController.js';
import { verifyToken, isAdmin } from '../middlewares/authMiddleware.js';
import { provinceUpload } from '../middlewares/uploadMiddleware.js';

const router = express.Router();

router.get('/', getAllProvinces);
router.post('/', verifyToken, isAdmin, provinceUpload.single('image'), addProvince);
router.put('/:id', verifyToken, isAdmin, provinceUpload.single('image'), updateProvince);
router.delete('/:id', verifyToken, isAdmin, deleteProvince);

export default router;
