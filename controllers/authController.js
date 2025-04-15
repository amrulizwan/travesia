import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';

export const register = async (req, res) => {
  try {
    const { nama, email, password, telepon, alamat, role } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) return res.status(400).json({ message: 'Email sudah digunakan' });

    const hashedPassword = await bcrypt.hash(password, 10);

    let finalRole = role;
    if (role === 'pengelola' && (!req.user || req.user.role !== 'admin')) {
      return res.status(403).json({ message: 'Hanya admin yang bisa menambahkan pengelola' });
    } else if (!role || role === 'pengunjung') {
      finalRole = 'pengunjung';
    }

    let fotoProfil = req.file ? `/uploads/profile/${req.file.filename}` : null;

    const newUser = new User({
      nama,
      email,
      password: hashedPassword,
      telepon,
      alamat,
      fotoProfil,
      role: finalRole,
    });

    await newUser.save();
    res.status(201).json({ message: 'Registrasi berhasil', user: newUser });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: 'Email tidak ditemukan' });

    if (user.statusAkun === 'banned') {
      return res.status(403).json({ message: 'Akun Anda telah diblokir' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Password salah' });

    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, {
      expiresIn: '7d',
    });

    res.status(200).json({ message: 'Login berhasil', token, user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
