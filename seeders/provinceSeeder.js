import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Province from '../models/Province.js';
import path from 'path';
import { fileURLToPath } from 'url';

// Setup for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load env variables - specify path to .env
dotenv.config({ path: path.join(__dirname, '..', '.env') });

const provinces = [
  {
    name: 'Aceh',
    code: 'AC',
    image: `${process.env.CLOUDFLARE_R2_ENDPOINT}/provinces/aceh.jpg`,
  },
  {
    name: 'Sumatera Utara',
    code: 'SU',
    image: `${process.env.CLOUDFLARE_R2_ENDPOINT}/provinces/sumut.jpg`,
  },
  {
    name: 'Sumatera Barat',
    code: 'SB',
    image: `${process.env.CLOUDFLARE_R2_ENDPOINT}/provinces/sumbar.jpg`,
  },
  // ...add more provinces
];

const seedProvinces = async () => {
  try {
    // Check if MONGO_URI exists
    if (!process.env.MONGO_URI) {
      throw new Error('MONGO_URI is not defined in environment variables');
    }

    // Connect to MongoDB
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    // Clear existing provinces
    await Province.deleteMany({});
    console.log('Cleared existing provinces');

    // Insert new provinces
    await Province.insertMany(provinces);
    console.log('Provinces seeded successfully!');
  } catch (error) {
    console.error('Error seeding provinces:', error);
    process.exit(1);
  } finally {
    // Close the connection
    await mongoose.connection.close();
    process.exit(0);
  }
};

// Run the seeder
seedProvinces();
