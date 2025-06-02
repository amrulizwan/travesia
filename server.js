import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import connectDB from './utils/db.js';
import authRoute from './routes/authRoute.js';
import wisataRoute from './routes/wisataRoute.js';
import ticketRoute from './routes/ticketRoute.js';
import adminUserRoute from './routes/adminUserRoute.js';
import reviewRoute from './routes/reviewRoute.js'; // Add this
import provinceRoute from './routes/provinceRoute.js';

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
  res.send('API berjalan');
});
app.use('/api/auth', authRoute);
app.use('/api/wisata', wisataRoute);
app.use('/api/tickets', ticketRoute);
app.use('/api/admin/users', adminUserRoute);
app.use('/api/reviews', reviewRoute); // Add this line
app.use('/api/provinces', provinceRoute);

connectDB();
const PORT = process.env.PORT || 3009;
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
});
