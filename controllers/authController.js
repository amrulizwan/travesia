import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';
import { sendResetOTP } from '../utils/mailer.js';

export const register = async (req, res) => {
  try {
    const { nama, email, password, role } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) return res.status(400).json({ message: 'Email sudah digunakan' });

    const hashedPassword = await bcrypt.hash(password, 10);

    let finalRole = role;
    if (role === 'pengelola' && (!req.user || req.user.role !== 'admin')) {
      return res.status(403).json({ message: 'Hanya admin yang bisa menambahkan pengelola' });
    } else if (!role || role === 'pengunjung') {
      finalRole = 'pengunjung';
    }

    const fotoProfil = req.file ? req.file.location : null;

    const newUser = new User({
      nama,
      email,
      password: hashedPassword,
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

    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });

    const refreshToken = jwt.sign({ id: user._id }, process.env.JWT_REFRESH_SECRET, { expiresIn: '30d' });

    res.status(200).json({
      message: 'Login berhasil',
      token,
      refreshToken,
      user: {
        id: user._id,
        nama: user.nama,
        email: user.email,
        role: user.role,
        fotoProfil: user.fotoProfil,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const requestResetPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'Email tidak ditemukan' });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 5 * 60 * 1000); // 5 menit

    user.resetPasswordOTP = otp;
    user.resetPasswordExpires = otpExpires;
    await user.save();

    await sendResetOTP(email, 'Reset Password OTP', otp);

    res.status(200).json({ message: 'OTP telah dikirim ke email Anda' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const verifyResetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    const user = await User.findOne({
      email,
      resetPasswordOTP: otp,
      resetPasswordExpires: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ message: 'OTP tidak valid atau sudah kadaluarsa' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    user.resetPasswordOTP = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    res.status(200).json({ message: 'Password berhasil direset' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
