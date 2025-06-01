import express from 'express';
import {
  createTransaction,
  handleMidtransNotification,
  getUserTickets,
  getSalesByWisata,
} from '../controllers/ticketController.js';
import { protect, authorizeRoles } from '../middlewares/authMiddleware.js';

const router = express.Router();

// POST /api/tickets/purchase - User purchases a ticket
router.post('/purchase', protect, authorizeRoles('pengunjung'), createTransaction);

// POST /api/tickets/midtrans-notification - Midtrans sends payment status updates
// This endpoint should ideally be open but secured (e.g. by verifying Midtrans signature, which is a TODO in controller)
router.post('/midtrans-notification', handleMidtransNotification);

// GET /api/tickets/my-tickets - Logged-in user views their tickets
router.get('/my-tickets', protect, authorizeRoles('pengunjung'), getUserTickets);

// GET /api/tickets/sales/:wisataId - Admin/Pengelola views sales for a specific Wisata
router.get('/sales/:wisataId', protect, authorizeRoles('admin', 'pengelola'), getSalesByWisata);

export default router;
