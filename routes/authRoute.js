import express from 'express';
import { register, login, requestResetPassword, verifyResetPassword } from '../controllers/authController.js';
import { profileUpload } from '../middlewares/uploadMiddleware.js';

const router = express.Router();

router.post('/register', profileUpload.single('fotoProfil'), register);
router.post('/login', login);
router.post('/request-reset-password', requestResetPassword);
router.post('/verify-reset-password', verifyResetPassword);

export default router;
