import express from 'express';
import { listUsers, getUserById, updateUserRole, manageUserAccountStatus } from '../controllers/adminController.js';
import { protect, authorizeRoles } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.use(protect);
router.use(authorizeRoles('admin'));

router.get('/', listUsers);
router.get('/:userId', getUserById);
router.put('/:userId/role', updateUserRole);
router.put('/:userId/status', manageUserAccountStatus);

export default router;
