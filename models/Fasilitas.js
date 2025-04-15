import mongoose from 'mongoose';

const fasilitasSchema = new mongoose.Schema({
  nama: { type: String, required: true, unique: true },
  deskripsi: String,
  berbayar: { type: Boolean, default: false },
  harga: { type: Number, default: 0 },
  foto: [
    {
      url: { type: String, required: true },
      deskripsi: String,
      uploadedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      tanggalUpload: { type: Date, default: Date.now },
    },
  ],
});

const Fasilitas = mongoose.model('Fasilitas', fasilitasSchema);
export default Fasilitas;
