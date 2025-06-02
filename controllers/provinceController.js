import Province from '../models/Province.js';

export const getAllProvinces = async (req, res) => {
  try {
    const provinces = await Province.find().sort('name');
    res.status(200).json({ data: provinces });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const addProvince = async (req, res) => {
  try {
    const { name, code } = req.body;
    const image = req.file?.location;

    if (!name || !code || !image) {
      return res.status(400).json({
        message: 'Nama, kode, dan gambar provinsi harus diisi',
      });
    }

    const existingProvince = await Province.findOne({
      $or: [{ name }, { code }],
    });

    if (existingProvince) {
      return res.status(400).json({
        message: 'Provinsi atau kode sudah terdaftar',
      });
    }

    const province = new Province({ name, code, image });
    await province.save();

    res.status(201).json({
      message: 'Provinsi berhasil ditambahkan',
      data: province,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateProvince = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, code } = req.body;
    const image = req.file?.location;

    const province = await Province.findById(id);
    if (!province) {
      return res.status(404).json({ message: 'Provinsi tidak ditemukan' });
    }

    if (name) province.name = name;
    if (code) province.code = code;
    if (image) province.image = image;

    await province.save();
    res.json({
      message: 'Provinsi berhasil diperbarui',
      data: province,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const deleteProvince = async (req, res) => {
  try {
    const { id } = req.params;
    const province = await Province.findById(id);

    if (!province) {
      return res.status(404).json({ message: 'Provinsi tidak ditemukan' });
    }

    await province.deleteOne();
    res.json({ message: 'Provinsi berhasil dihapus' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
