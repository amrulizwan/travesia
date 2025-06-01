import mongoose from 'mongoose';

const reviewSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  wisata: { type: mongoose.Schema.Types.ObjectId, ref: 'Wisata', required: true },
  ticket: { type: mongoose.Schema.Types.ObjectId, ref: 'Ticket' }, // Optional link to the ticket
  rating: { type: Number, min: 1, max: 5, required: true },
  comment: { type: String, trim: true, required: true },
  pengelolaResponse: {
    responseText: { type: String, trim: true },
    respondedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Pengelola who responded
    respondedAt: { type: Date }
  },
  status: { // For moderation by admin
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'approved', // Or 'pending' if admin approval is mandatory
  },
  // Consider adding an array for 'likes' or 'helpfulVotes' in the future
}, { timestamps: true });

// Index for faster querying of reviews for a specific Wisata
reviewSchema.index({ wisata: 1, status: 1 });
// Index for user's reviews
reviewSchema.index({ user: 1 });

// Static method to calculate average rating for a Wisata (optional, can be complex to maintain)
// reviewSchema.statics.calculateAverageRating = async function(wisataId) { ... }
// Example:
// reviewSchema.statics.calculateAverageRating = async function(wisataId) {
//   const stats = await this.aggregate([
//     { $match: { wisata: wisataId, status: 'approved' } },
//     { $group: { _id: '$wisata', averageRating: { $avg: '$rating' }, reviewCount: { $sum: 1 } } }
//   ]);
//   try {
//     if (stats.length > 0) {
//       await mongoose.model('Wisata').findByIdAndUpdate(wisataId, {
//         averageRating: stats[0].averageRating,
//         reviewCount: stats[0].reviewCount
//       });
//     } else {
//       await mongoose.model('Wisata').findByIdAndUpdate(wisataId, {
//         averageRating: 0, // Or null, or a default value
//         reviewCount: 0
//       });
//     }
//   } catch (err) {
//     console.error(err);
//   }
// };

// // After save or remove, trigger calculation (example, needs careful implementation to avoid race conditions or excessive calls)
// reviewSchema.post('save', async function() {
//   await this.constructor.calculateAverageRating(this.wisata);
// });
// reviewSchema.post('remove', async function() { // Mongoose 5.x 'remove' hook, or 'deleteOne'/'deleteMany' for Mongoose 6+
//   await this.constructor.calculateAverageRating(this.wisata);
// });


const Review = mongoose.model('Review', reviewSchema);
export default Review;
