import express from 'express';
import { register, login, requestResetPassword, verifyResetPassword, getProfile, updateProfile, updateProfilePicture } from '../controllers/authController.js';
import { profileUpload } from '../middlewares/uploadMiddleware.js';
import { verifyToken } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.post('/register', profileUpload.single('fotoProfil'), register);
router.post('/pengelola', profileUpload.single('fotoProfil'), verifyToken, register);
router.post('/login', login);
router.post('/request-reset-password', requestResetPassword);
router.post('/verify-reset-password', verifyResetPassword);

// Profile routes
router.get('/profile', verifyToken, getProfile);
router.put('/profile', verifyToken, updateProfile);
router.put('/profile/picture', verifyToken, profileUpload.single('fotoProfil'), updateProfilePicture);

export default router;
