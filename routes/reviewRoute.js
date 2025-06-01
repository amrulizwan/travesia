import express from 'express';
import {
    createReview,
    getReviewsForWisata,
    getReviewById,
    updateReview,
    deleteReview,
    pengelolaRespondToReview,
    adminSetReviewStatus,
    getMyReviews // Added this import
} from '../controllers/reviewController.js';
import { protect, authorizeRoles } from '../middlewares/authMiddleware.js';

const router = express.Router();

// POST /api/reviews - Pengunjung creates a review
router.post('/', protect, authorizeRoles('pengunjung'), createReview);

// GET /api/reviews/wisata/:wisataId - Publicly list 'approved' reviews for a Wisata
router.get('/wisata/:wisataId', getReviewsForWisata);

// GET /api/reviews/my-reviews - Logged-in 'pengunjung' views their own reviews
router.get('/my-reviews', protect, authorizeRoles('pengunjung'), getMyReviews);

// GET /api/reviews/:reviewId - Get a single review by its ID (public, but controller might have checks for status)
router.get('/:reviewId', getReviewById);

// PUT /api/reviews/:reviewId - Pengunjung updates their own review
router.put('/:reviewId', protect, authorizeRoles('pengunjung'), updateReview);

// DELETE /api/reviews/:reviewId - Pengunjung deletes their own review OR Admin deletes any review
router.delete('/:reviewId', protect, authorizeRoles('pengunjung', 'admin'), deleteReview);

// PUT /api/reviews/:reviewId/respond - Pengelola of the specific Wisata adds/updates pengelolaResponse
router.put('/:reviewId/respond', protect, authorizeRoles('pengelola'), pengelolaRespondToReview);

// PUT /api/reviews/:reviewId/status - Admin sets review status
router.put('/:reviewId/status', protect, authorizeRoles('admin'), adminSetReviewStatus);

export default router;
