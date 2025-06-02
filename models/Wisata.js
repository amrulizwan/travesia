import mongoose from 'mongoose';

const wisataSchema = new mongoose.Schema({
  nama: { type: String, required: true },
  deskripsi: { type: String, required: true },
  lokasi: {
    alamat: { type: String, required: true },
    koordinat: {
      lat: { type: Number, required: true },
      lng: { type: Number, required: true },
    },
  },
  status: {
    type: String,
    enum: ['buka', 'tutup', 'libur', 'perbaikan'],
    default: 'buka',
  },
  fasilitas: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Fasilitas' }],
  // Old hargaTiket field removed
  ticketTypes: [
    {
      _id: { type: mongoose.Schema.Types.ObjectId, auto: true }, // Auto-generated ID for each ticket type
      name: { type: String, required: true }, // e.g., "Dewasa", "Anak-Anak", "Pelajar", "VIP"
      price: { type: Number, required: true, min: 0 },
      description: { type: String }, // Optional description
    },
  ],
  galeri: [
    {
      url: { type: String, required: true },
      deskripsi: String,
      uploadedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      tanggalUpload: { type: Date, default: Date.now },
      status: {
        type: String,
        enum: ['pending', 'verified', 'rejected'],
        default: 'pending',
      },
    },
  ],
  kontak: {
    telepon: String,
    email: String,
    website: String,
  },
  jamOperasional: {
    senin: String,
    selasa: String,
    rabu: String,
    kamis: String,
    jumat: String,
    sabtu: String,
    minggu: String,
  },
  pengelola: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  province: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Province',
    required: true,
  },
});

const Wisata = mongoose.model('Wisata', wisataSchema);
export default Wisata;
