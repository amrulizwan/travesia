import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  nama: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  telepon: { type: String },
  alamat: { type: String },
  fotoProfil: { type: String },
  role: {
    type: String,
    enum: ['admin', 'pengelola', 'pengunjung'],
    required: true,
  },
  statusAkun: {
    type: String,
    enum: ['aktif', 'nonaktif', 'banned'],
    default: 'aktif',
  },
  tempatWisata: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Wisata' }],
  favoritWisata: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Wisata' }],

  createdAt: { type: Date, default: Date.now },
});

const User = mongoose.model('User', userSchema);
export default User;
