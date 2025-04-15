import express from 'express';
import { register, login } from '../controllers/authController.js';
import { uploadProfile } from '../middlewares/uploadMiddleware.js';

const router = express.Router();

router.post('/register', uploadProfile.single('fotoProfil'), register);
router.post('/login', login);

export default router;
