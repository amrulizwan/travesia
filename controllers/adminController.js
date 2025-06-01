import User from '../models/User.js'; // Adjust path as needed
import mongoose from 'mongoose';

// Admin: List all users with pagination and optional role filter
export const listUsers = async (req, res) => {
  try {
    const { page = 1, limit = 10, role } = req.query;
    const query = {};
    if (role) {
      query.role = role;
    }

    const users = await User.find(query)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .select('-password -resetPasswordOTP -resetPasswordExpires') // Exclude sensitive fields
      .exec();

    const count = await User.countDocuments(query);

    res.status(200).json({
      data: users,
      totalPages: Math.ceil(count / limit),
      currentPage: parseInt(page),
      totalUsers: count,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error listing users', error: error.message });
  }
};

// Admin: Get details of a specific user by ID
export const getUserById = async (req, res) => {
  try {
    const { userId } = req.params;
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: 'Invalid User ID format' });
    }
    const user = await User.findById(userId).select('-password -resetPasswordOTP -resetPasswordExpires');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.status(200).json({ data: user });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching user details', error: error.message });
  }
};

// Admin: Update a user's role
export const updateUserRole = async (req, res) => {
  try {
    const { userId } = req.params;
    const { role } = req.body;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: 'Invalid User ID format' });
    }

    if (!role || !['admin', 'pengelola', 'pengunjung'].includes(role)) {
      return res.status(400).json({ message: 'Invalid role specified. Must be admin, pengelola, or pengunjung.' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Optional: Prevent admin from changing their own role or last admin's role
    // if (user._id.equals(req.user._id) && user.role === 'admin') {
    //    const adminCount = await User.countDocuments({ role: 'admin' });
    //    if (adminCount <= 1) {
    //        return res.status(400).json({ message: 'Cannot change role of the last admin.' });
    //    }
    // }

    user.role = role;
    await user.save();
    // Exclude sensitive fields from response
    const userResponse = user.toObject();
    delete userResponse.password;
    delete userResponse.resetPasswordOTP;
    delete userResponse.resetPasswordExpires;

    res.status(200).json({ message: 'User role updated successfully', data: userResponse });
  } catch (error) {
    res.status(500).json({ message: 'Error updating user role', error: error.message });
  }
};

// Admin: Manage user account status (activate, deactivate, ban)
export const manageUserAccountStatus = async (req, res) => {
  try {
    const { userId } = req.params;
    const { statusAkun } = req.body;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: 'Invalid User ID format' });
    }

    if (!statusAkun || !['aktif', 'nonaktif', 'banned'].includes(statusAkun)) {
      return res.status(400).json({ message: 'Invalid account status. Must be aktif, nonaktif, or banned.' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Optional: Prevent admin from banning themselves
    // if (user._id.equals(req.user._id) && statusAkun === 'banned') {
    //   return res.status(400).json({ message: 'Admin cannot ban themselves.' });
    // }

    user.statusAkun = statusAkun;
    await user.save();
    // Exclude sensitive fields from response
    const userResponse = user.toObject();
    delete userResponse.password;
    delete userResponse.resetPasswordOTP;
    delete userResponse.resetPasswordExpires;

    res.status(200).json({ message: `User account status updated to ${statusAkun}`, data: userResponse });
  } catch (error) {
    res.status(500).json({ message: 'Error managing user account status', error: error.message });
  }
};
