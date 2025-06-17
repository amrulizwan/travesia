import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import path from 'path'; // Added
import { fileURLToPath } from 'url'; // Added
import connectDB from './utils/db.js';
import authRoute from './routes/authRoute.js';
import wisataRoute from './routes/wisataRoute.js';
import ticketRoute from './routes/ticketRoute.js';
import adminUserRoute from './routes/adminUserRoute.js';
import reviewRoute from './routes/reviewRoute.js';
import provinceRoute from './routes/provinceRoute.js';

// Define __dirname for ES modules
const __filename = fileURLToPath(import.meta.url); // Added
const __dirname = path.dirname(__filename); // Added

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files for the admin dashboard
app.use('/admin', express.static(path.join(__dirname, 'views/admin'))); // Added

// Redirect /admin to /admin/dashboard.html
app.get('/admin', (req, res) => { // Added
    res.redirect('/admin/dashboard.html');
});

app.get('/', (req, res) => {
  res.send('API berjalan');
});

app.use('/api/auth', authRoute);
app.use('/api/wisata', wisataRoute);
app.use('/api/tickets', ticketRoute);
app.use('/api/admin/users', adminUserRoute);
app.use('/api/reviews', reviewRoute);
app.use('/api/provinces', provinceRoute);

connectDB();
const PORT = process.env.PORT || 3009;
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
});
