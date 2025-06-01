import mongoose from 'mongoose';
import Review from '../models/Review.js';
import Ticket from '../models/Ticket.js';
import Wisata from '../models/Wisata.js';

// Helper function to check if user has a successful ticket for the wisata
const hasPurchasedTicket = async (userId, wisataId) => {
    const ticket = await Ticket.findOne({
        user: userId,
        wisata: wisataId,
        paymentStatus: 'success'
    });
    return !!ticket;
};

// 1. Create a new review
export const createReview = async (req, res) => {
    const { wisataId, rating, comment, ticketId } = req.body; // ticketId is optional
    const userId = req.user._id;

    if (!mongoose.Types.ObjectId.isValid(wisataId)) {
        return res.status(400).json({ message: 'Invalid Wisata ID format.' });
    }
    if (ticketId && !mongoose.Types.ObjectId.isValid(ticketId)) {
        return res.status(400).json({ message: 'Invalid Ticket ID format.' });
    }

    try {
        const wisata = await Wisata.findById(wisataId);
        if (!wisata) {
            return res.status(404).json({ message: 'Wisata not found.' });
        }

        // **Optional but recommended: Check if user has a completed ticket purchase for this Wisata**
        // For this implementation, we'll make having *any* successful ticket for the wisata a prerequisite.
        // A stricter check could use the provided 'ticketId' if front-end supplies it from user's ticket list.
        const canReview = await hasPurchasedTicket(userId, wisataId);
        if (!canReview) {
             return res.status(403).json({ message: 'You must have a completed ticket purchase for this Wisata to leave a review.' });
        }

        const existingReview = await Review.findOne({ user: userId, wisata: wisataId });
        if (existingReview) {
            return res.status(400).json({ message: 'You have already reviewed this Wisata.' });
        }

        const review = new Review({
            user: userId,
            wisata: wisataId,
            ticket: ticketId, // Store if provided
            rating,
            comment,
            status: 'approved' // Default to 'approved'; can be changed to 'pending' for moderation
        });

        await review.save();
        // Optionally, trigger average rating calculation here if implemented on the model
        // await Review.calculateAverageRating(wisataId);
        res.status(201).json({ message: 'Review submitted successfully!', data: review });
    } catch (error) {
        console.error("Error creating review:", error);
        res.status(500).json({ message: 'Error creating review.', error: error.message });
    }
};

// 2. Get all 'approved' reviews for a Wisata (public, paginated)
export const getReviewsForWisata = async (req, res) => {
    const { wisataId } = req.params;
    const { page = 1, limit = 10 } = req.query;

    if (!mongoose.Types.ObjectId.isValid(wisataId)) {
        return res.status(400).json({ message: 'Invalid Wisata ID format.' });
    }

    try {
        const query = { wisata: wisataId, status: 'approved' };
        const reviews = await Review.find(query)
            .populate('user', 'nama fotoProfil') // Populate user's name and profile photo
            .populate('pengelolaResponse.respondedBy', 'nama') // Populate responder's name
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit)
            .exec();

        const count = await Review.countDocuments(query);

        res.status(200).json({
            data: reviews,
            totalPages: Math.ceil(count / limit),
            currentPage: parseInt(page),
            totalReviews: count
        });
    } catch (error) {
        console.error("Error fetching reviews for Wisata:", error);
        res.status(500).json({ message: 'Error fetching reviews.', error: error.message });
    }
};

// 3. Get a single review by ID
export const getReviewById = async (req, res) => {
    const { reviewId } = req.params;
    if (!mongoose.Types.ObjectId.isValid(reviewId)) {
        return res.status(400).json({ message: 'Invalid Review ID format.' });
    }
    try {
        const review = await Review.findById(reviewId)
            .populate('user', 'nama fotoProfil')
            .populate('wisata', 'nama')
            .populate('pengelolaResponse.respondedBy', 'nama');

        if (!review) {
            return res.status(404).json({ message: 'Review not found.' });
        }
        // Optional: Check status if non-approved reviews should be hidden from general users
        // if (review.status !== 'approved' && (!req.user || req.user.role === 'pengunjung')) {
        //    return res.status(404).json({ message: 'Review not found or not approved.' });
        // }
        res.status(200).json({ data: review });
    } catch (error) {
        console.error("Error fetching review by ID:", error);
        res.status(500).json({ message: 'Error fetching review.', error: error.message });
    }
};

// 4. Update a review (by owner)
export const updateReview = async (req, res) => {
    const { reviewId } = req.params;
    const { rating, comment } = req.body;
    const userId = req.user._id;

    if (!mongoose.Types.ObjectId.isValid(reviewId)) {
        return res.status(400).json({ message: 'Invalid Review ID format.' });
    }

    try {
        const review = await Review.findById(reviewId);
        if (!review) {
            return res.status(404).json({ message: 'Review not found.' });
        }
        if (review.user.toString() !== userId.toString()) {
            return res.status(403).json({ message: 'You are not authorized to update this review.' });
        }

        if (rating) review.rating = rating;
        if (comment) review.comment = comment;
        // Optionally, if admin approval is needed after edit, change status:
        // review.status = 'pending';

        await review.save();
        // Optionally, trigger average rating calculation here
        // await Review.calculateAverageRating(review.wisata);
        res.status(200).json({ message: 'Review updated successfully.', data: review });
    } catch (error) {
        console.error("Error updating review:", error);
        res.status(500).json({ message: 'Error updating review.', error: error.message });
    }
};

// 5. Delete a review (by owner or Admin)
export const deleteReview = async (req, res) => {
    const { reviewId } = req.params;
    const userId = req.user._id;
    const userRole = req.user.role;

    if (!mongoose.Types.ObjectId.isValid(reviewId)) {
        return res.status(400).json({ message: 'Invalid Review ID format.' });
    }

    try {
        const review = await Review.findById(reviewId);
        if (!review) {
            return res.status(404).json({ message: 'Review not found.' });
        }

        if (userRole === 'admin' || review.user.toString() === userId.toString()) {
            const wisataId = review.wisata; // Store before deleting
            await review.remove(); // Or review.deleteOne() in Mongoose 6+
            // Optionally, trigger average rating calculation here
            // await Review.calculateAverageRating(wisataId);
            res.status(200).json({ message: 'Review deleted successfully.' });
        } else {
            return res.status(403).json({ message: 'You are not authorized to delete this review.' });
        }
    } catch (error) {
        console.error("Error deleting review:", error);
        res.status(500).json({ message: 'Error deleting review.', error: error.message });
    }
};

// 6. Pengelola responds to a review
export const pengelolaRespondToReview = async (req, res) => {
    const { reviewId } = req.params;
    const { responseText } = req.body;
    const pengelolaUserId = req.user._id;

    if (!mongoose.Types.ObjectId.isValid(reviewId)) {
        return res.status(400).json({ message: 'Invalid Review ID format.' });
    }
    if (!responseText || responseText.trim() === '') {
        return res.status(400).json({ message: 'Response text cannot be empty.' });
    }

    try {
        const review = await Review.findById(reviewId).populate('wisata'); // Populate wisata to check its pengelola
        if (!review) {
            return res.status(404).json({ message: 'Review not found.' });
        }
        if (!review.wisata) {
            return res.status(500).json({ message: 'Could not find associated Wisata for the review.' });
        }

        // Check if the current user is the pengelola of the Wisata this review belongs to
        if (!review.wisata.pengelola || review.wisata.pengelola.toString() !== pengelolaUserId.toString()) {
            return res.status(403).json({ message: 'You are not authorized to respond to reviews for this Wisata.' });
        }

        review.pengelolaResponse = {
            responseText: responseText,
            respondedBy: pengelolaUserId,
            respondedAt: new Date()
        };
        await review.save();
        res.status(200).json({ message: 'Response posted successfully.', data: review });
    } catch (error) {
        console.error("Error responding to review:", error);
        res.status(500).json({ message: 'Error responding to review.', error: error.message });
    }
};

// 7. Admin sets review status (pending, approved, rejected)
export const adminSetReviewStatus = async (req, res) => {
    const { reviewId } = req.params;
    const { status } = req.body;

    if (!mongoose.Types.ObjectId.isValid(reviewId)) {
        return res.status(400).json({ message: 'Invalid Review ID format.' });
    }
    if (!status || !['pending', 'approved', 'rejected'].includes(status)) {
        return res.status(400).json({ message: 'Invalid status. Must be one of: pending, approved, rejected.' });
    }

    try {
        const review = await Review.findById(reviewId);
        if (!review) {
            return res.status(404).json({ message: 'Review not found.' });
        }

        review.status = status;
        await review.save();
        // Optionally, trigger average rating calculation if status changes to/from 'approved'
        // await Review.calculateAverageRating(review.wisata);
        res.status(200).json({ message: `Review status updated to ${status}.`, data: review });
    } catch (error) {
        console.error("Error setting review status:", error);
        res.status(500).json({ message: 'Error setting review status.', error: error.message });
    }
};

// (Bonus) Get all reviews written by the currently logged-in user
export const getMyReviews = async (req, res) => {
    const userId = req.user._id;
    const { page = 1, limit = 10 } = req.query;

    try {
        const query = { user: userId };
        const reviews = await Review.find(query)
            .populate('wisata', 'nama') // Populate Wisata's name
            .populate('pengelolaResponse.respondedBy', 'nama') // Populate responder's name
            .sort({ createdAt: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit)
            .exec();

        const count = await Review.countDocuments(query);

        res.status(200).json({
            data: reviews,
            totalPages: Math.ceil(count / limit),
            currentPage: parseInt(page),
            totalReviews: count
        });
    } catch (error) {
        console.error("Error fetching user's reviews:", error);
        res.status(500).json({ message: "Error fetching user's reviews.", error: error.message });
    }
};
