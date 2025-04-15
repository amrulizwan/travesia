import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import connectDB from './utils/db.js';
import authRoute from './routes/authRoute.js';

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
  res.send('API berjalan');
});
app.use('/api/auth', authRoute);

connectDB();
const PORT = process.env.PORT || 3009;
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
});
