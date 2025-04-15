import Wisata from '../models/Wisata.js';

export const tambahWisata = async (req, res) => {
  try {
    const { nama, deskripsi, lokasi, hargaTiket, kontak, jamOperasional } = req.body;

    if (req.user.role !== 'admin' && req.user.role !== 'pengelola') {
      return res.status(403).json({ message: 'Akses ditolak!' });
    }

    const wisataBaru = new Wisata({
      nama,
      deskripsi,
      lokasi,
      hargaTiket,
      kontak,
      jamOperasional,
      pengelola: req.user._id,
    });

    await wisataBaru.save();
    res.status(201).json({ message: 'Wisata berhasil ditambahkan!', data: wisataBaru });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan!', error });
  }
};

export const updateWisata = async (req, res) => {
  try {
    const { id } = req.params;
    const wisata = await Wisata.findById(id);

    if (!wisata) return res.status(404).json({ message: 'Wisata tidak ditemukan!' });

    if (req.user.role !== 'admin' && wisata.pengelola.toString() !== req.user._id) {
      return res.status(403).json({ message: 'Akses ditolak!' });
    }

    const updatedWisata = await Wisata.findByIdAndUpdate(id, req.body, { new: true });
    res.json({ message: 'Wisata berhasil diperbarui!', data: updatedWisata });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan!', error });
  }
};

// 🔹 Hapus wisata (hanya admin atau pemilik)
export const hapusWisata = async (req, res) => {
  try {
    const { id } = req.params;
    const wisata = await Wisata.findById(id);

    if (!wisata) return res.status(404).json({ message: 'Wisata tidak ditemukan!' });

    // Hanya admin atau pemilik wisata yang bisa menghapus
    if (req.user.role !== 'admin' && wisata.pengelola.toString() !== req.user._id) {
      return res.status(403).json({ message: 'Akses ditolak!' });
    }

    await Wisata.findByIdAndDelete(id);
    res.json({ message: 'Wisata berhasil dihapus!' });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan!', error });
  }
};

// 🔹 Tambah gambar ke galeri wisata (hanya pengelola atau admin)
export const tambahGambarGaleri = async (req, res) => {
  try {
    const { id } = req.params; // ID wisata
    const wisata = await Wisata.findById(id);

    if (!wisata) return res.status(404).json({ message: 'Wisata tidak ditemukan!' });

    if (req.user.role !== 'admin' && wisata.pengelola.toString() !== req.user._id) {
      return res.status(403).json({ message: 'Akses ditolak!' });
    }

    const gambarBaru = {
      url: `/uploads/gallery/${req.file.filename}`,
      deskripsi: req.body.deskripsi || '',
      uploadedBy: req.user._id,
      status: 'pending',
    };

    wisata.galeri.push(gambarBaru);
    await wisata.save();

    res.status(201).json({ message: 'Gambar berhasil ditambahkan!', data: gambarBaru });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan!', error });
  }
};

// 🔹 Verifikasi atau tolak gambar galeri (hanya admin)
export const verifikasiGambarGaleri = async (req, res) => {
  try {
    const { wisataId, gambarId } = req.params;
    const { status } = req.body; // 'verified' atau 'rejected'

    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Akses ditolak!' });
    }

    const wisata = await Wisata.findById(wisataId);
    if (!wisata) return res.status(404).json({ message: 'Wisata tidak ditemukan!' });

    const gambar = wisata.galeri.id(gambarId);
    if (!gambar) return res.status(404).json({ message: 'Gambar tidak ditemukan!' });

    gambar.status = status;
    await wisata.save();

    res.json({ message: `Gambar berhasil ${status === 'verified' ? 'diverifikasi' : 'ditolak'}!` });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan!', error });
  }
};

// 🔹 Ambil semua wisata (admin lihat semua, pengelola lihat miliknya)
export const getAllWisata = async (req, res) => {
  try {
    let wisataList;

    if (req.user.role === 'admin') {
      wisataList = await Wisata.find().populate('pengelola fasilitas');
    } else {
      wisataList = await Wisata.find({ pengelola: req.user._id }).populate('fasilitas');
    }

    res.json({ data: wisataList });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan!', error });
  }
};

// 🔹 Ambil detail wisata berdasarkan ID
export const getWisataById = async (req, res) => {
  try {
    const wisata = await Wisata.findById(req.params.id).populate('pengelola fasilitas');

    if (!wisata) return res.status(404).json({ message: 'Wisata tidak ditemukan!' });

    res.json({ data: wisata });
  } catch (error) {
    res.status(500).json({ message: 'Terjadi kesalahan!', error });
  }
};
