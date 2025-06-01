import mongoose from 'mongoose';

const ticketSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  wisata: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Wisata',
    required: true,
  },
  transactionId: { // From Midtrans, after successful payment or if available earlier
    type: String,
    // index: true, // Consider indexing if frequently queried
  },
  orderId: { // Your internal unique order ID, also sent to Midtrans
    type: String,
    required: true,
    unique: true,
    index: true,
  },
  quantity: {
    dewasa: { type: Number, required: true, min: 0 },
    anakAnak: { type: Number, required: true, min: 0 },
  },
  totalPrice: {
    type: Number,
    required: true,
    min: 0,
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'success', 'failed', 'expired', 'cancelled', 'refunded'],
    default: 'pending',
    required: true,
    index: true,
  },
  paymentMethod: { // e.g., 'credit_card', 'gopay', 'bank_transfer'
    type: String,
  },
  transactionTimestamp: { // When the Midtrans transaction was initiated
    type: Date,
    default: Date.now,
  },
  paidAt: { // When payment was confirmed
    type: Date,
  },
  snapToken: { // Midtrans Snap token for frontend payment UI
    type: String,
  },
  // Optional: Add details about the tickets themselves if needed,
  // like seat numbers if applicable, or just rely on quantity.
  // For this case, quantity is likely sufficient.
}, { timestamps: true }); // Adds createdAt and updatedAt automatically

// Ensure that a user cannot purchase the same Wisata again if there's already a pending/successful ticket.
// This is a business rule to consider. For now, we allow multiple tickets per user per wisata.
// If needed, a compound index could be added:
// ticketSchema.index({ user: 1, wisata: 1, paymentStatus: 1 });

const Ticket = mongoose.model('Ticket', ticketSchema);
export default Ticket;
