import express from 'express';
import {
  listUsers,
  getUserById,
  updateUserRole,
  manageUserAccountStatus
} from '../controllers/adminController.js'; // Adjust path as needed
import { protect, authorizeRoles } from '../middlewares/authMiddleware.js'; // Adjust path

const router = express.Router();

// All routes in this file are for admins only
router.use(protect);
router.use(authorizeRoles('admin'));

router.get('/', listUsers); // GET /api/admin/users
router.get('/:userId', getUserById); // GET /api/admin/users/:userId
router.put('/:userId/role', updateUserRole); // PUT /api/admin/users/:userId/role
router.put('/:userId/status', manageUserAccountStatus); // PUT /api/admin/users/:userId/status

export default router;
