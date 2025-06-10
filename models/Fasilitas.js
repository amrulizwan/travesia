import mongoose from 'mongoose';

const fasilitasSchema = new mongoose.Schema({
  nama: { type: String, required: true },
  icon: { type: String }, // opsional, misal URL icon fasilitas
  deskripsi: { type: String },
});

const Fasilitas = mongoose.model('Fasilitas', fasilitasSchema);
export default Fasilitas;
