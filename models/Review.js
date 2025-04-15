import mongoose from 'mongoose';

const reviewSchema = new mongoose.Schema({
  wisata: { type: mongoose.Schema.Types.ObjectId, ref: 'Wisata', required: true },
  pengguna: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  rating: { type: Number, min: 1, max: 5, required: true },
  komentar: String,
  gambar: [String],
  tanggal: { type: Date, default: Date.now },
});

const Review = mongoose.model('Review', reviewSchema);
export default Review;
