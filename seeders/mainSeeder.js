import mongoose from 'mongoose';
import { faker } from '@faker-js/faker/locale/id_ID';
import bcrypt from 'bcryptjs';
import User from '../models/User.js';
import Wisata from '../models/Wisata.js';
import Review from '../models/Review.js';
import Ticket from '../models/Ticket.js';
import Province from '../models/Province.js';
import { getRandomImage } from './utils.js';
import { setGlobalDispatcher, Agent } from 'undici';

const NUM_PENGELOLA = 60;
const NUM_PENGUNJUNG = 100;
const NUM_WISATA = 80;
const NUM_REVIEWS = 100;
const NUM_TICKETS = 100;

const INDONESIA_WISATA = [
  { name: 'Candi Borobudur', category: 'Sejarah & Budaya' },
  { name: 'Candi Prambanan', category: 'Sejarah & Budaya' },
  { name: 'Malioboro', category: 'Wisata Kota' },
  { name: 'Kawah Ijen', category: 'Alam' },
  { name: 'Gunung Bromo', category: 'Alam' },
  { name: 'Taman Mini Indonesia Indah', category: 'Edukasi' },
  { name: 'Dufan Ancol', category: 'Hiburan' },
  { name: 'Pantai Parangtritis', category: 'Pantai' },
  { name: 'Keraton Yogyakarta', category: 'Sejarah & Budaya' },

  // Bali
  { name: 'Pantai Kuta', category: 'Pantai' },
  { name: 'Tanah Lot', category: 'Sejarah & Budaya' },
  { name: 'Uluwatu', category: 'Sejarah & Budaya' },
  { name: 'Ubud Monkey Forest', category: 'Alam' },
  { name: 'Tegalalang Rice Terrace', category: 'Alam' },

  // Sumatera
  { name: 'Danau Toba', category: 'Alam' },
  { name: 'Jam Gadang', category: 'Sejarah & Budaya' },
  { name: 'Istana Maimun', category: 'Sejarah & Budaya' },
  { name: 'Bukit Tinggi', category: 'Wisata Kota' },
  { name: 'Pulau Samosir', category: 'Alam' },

  // Kalimantan
  { name: 'Taman Nasional Tanjung Puting', category: 'Alam' },
  { name: 'Pulau Derawan', category: 'Pantai' },
  { name: 'Sungai Kapuas', category: 'Alam' },

  // Sulawesi
  { name: 'Tana Toraja', category: 'Sejarah & Budaya' },
  { name: 'Bunaken', category: 'Pantai' },
  { name: 'Fort Rotterdam', category: 'Sejarah & Budaya' },

  // NTT & NTB
  { name: 'Pulau Komodo', category: 'Alam' },
  { name: 'Pantai Pink', category: 'Pantai' },
  { name: 'Gunung Rinjani', category: 'Alam' },
  { name: 'Gili Trawangan', category: 'Pantai' },

  // Papua
  { name: 'Raja Ampat', category: 'Pantai' },
  { name: 'Danau Sentani', category: 'Alam' },
  { name: 'Taman Nasional Lorentz', category: 'Alam' },
];

// Configure max sockets
setGlobalDispatcher(
  new Agent({
    connections: 100, // Increase max connections
  })
);

const generateUsers = async () => {
  // Generate Pengelola
  const pengelola = await Promise.all(
    [...Array(NUM_PENGELOLA)].map(async () => {
      const user = new User({
        nama: faker.person.fullName(),
        email: faker.internet.email(),
        password: await bcrypt.hash('password123', 10),
        telepon: faker.phone.number(),
        alamat: faker.location.streetAddress(),
        fotoProfil: await getRandomImage('profiles'),
        role: 'pengelola',
        statusAkun: 'aktif',
      });
      return user.save();
    })
  );

  // Generate Pengunjung
  const pengunjung = await Promise.all(
    [...Array(NUM_PENGUNJUNG)].map(async () => {
      const user = new User({
        nama: faker.person.fullName(),
        email: faker.internet.email(),
        password: await bcrypt.hash('password123', 10),
        telepon: faker.phone.number(),
        alamat: faker.location.streetAddress(),
        fotoProfil: await getRandomImage('profiles'),
        role: 'pengunjung',
        statusAkun: 'aktif',
      });
      return user.save();
    })
  );

  return { pengelola, pengunjung };
};

const generateWisata = async (pengelola) => {
  const provinces = await Province.find({});

  if (provinces.length === 0) {
    throw new Error('No provinces found. Please run province seeder first.');
  }

  // Generate additional random wisata names to meet the NUM_WISATA requirement
  const additionalWisata = [...Array(NUM_WISATA - INDONESIA_WISATA.length)].map(() => ({
    name: `Wisata ${faker.location.city()}`,
    category: faker.helpers.arrayElement(['Alam', 'Pantai', 'Sejarah & Budaya', 'Wisata Kota', 'Hiburan', 'Edukasi']),
  }));

  const allWisata = [...INDONESIA_WISATA, ...additionalWisata];

  const wisataList = await Promise.all(
    allWisata.map(async (wisataData) => {
      const galeri = await Promise.all(
        [...Array(faker.number.int({ min: 4, max: 6 }))].map(async () => ({
          url: await getRandomImage('gallery'),
          deskripsi: faker.lorem.sentence(),
          uploadedBy: pengelola[faker.number.int({ min: 0, max: pengelola.length - 1 })]._id,
          status: 'verified',
        }))
      );

      const wisata = new Wisata({
        nama: wisataData.name,
        kategori: wisataData.category,
        deskripsi: faker.lorem.paragraphs(2),
        province: provinces[faker.number.int({ min: 0, max: provinces.length - 1 })]._id,
        lokasi: {
          alamat: faker.location.streetAddress(),
          koordinat: {
            lat: faker.location.latitude(),
            lng: faker.location.longitude(),
          },
        },
        status: faker.helpers.arrayElement(['buka', 'tutup', 'libur', 'perbaikan']),
        ticketTypes: [
          {
            name: 'Dewasa',
            price: faker.number.int({ min: 10000, max: 100000 }),
            description: 'Tiket untuk pengunjung dewasa',
          },
          {
            name: 'Anak-anak',
            price: faker.number.int({ min: 5000, max: 50000 }),
            description: 'Tiket untuk anak-anak di bawah 12 tahun',
          },
        ],
        galeri,
        kontak: {
          telepon: faker.phone.number(),
          email: faker.internet.email(),
          website: faker.internet.url(),
        },
        jamOperasional: {
          senin: '08:00 - 17:00',
          selasa: '08:00 - 17:00',
          rabu: '08:00 - 17:00',
          kamis: '08:00 - 17:00',
          jumat: '08:00 - 17:00',
          sabtu: '08:00 - 20:00',
          minggu: '08:00 - 20:00',
        },
        pengelola: pengelola[faker.number.int({ min: 0, max: pengelola.length - 1 })]._id,
      });
      return wisata.save();
    })
  );

  return wisataList;
};

const generateReviewsAndTickets = async (wisataList, pengunjung) => {
  // Generate Reviews
  const reviews = await Promise.all(
    [...Array(NUM_REVIEWS)].map(async () => {
      const review = new Review({
        user: pengunjung[faker.number.int({ min: 0, max: pengunjung.length - 1 })]._id,
        wisata: wisataList[faker.number.int({ min: 0, max: wisataList.length - 1 })]._id,
        rating: faker.number.int({ min: 1, max: 5 }),
        comment: faker.lorem.paragraph(),
        status: 'approved',
      });
      return review.save();
    })
  );

  // Generate Tickets
  const tickets = await Promise.all(
    [...Array(NUM_TICKETS)].map(async () => {
      const selectedWisata = wisataList[faker.number.int({ min: 0, max: wisataList.length - 1 })];
      const ticketType = selectedWisata.ticketTypes[faker.number.int({ min: 0, max: 1 })];
      const quantity = faker.number.int({ min: 1, max: 5 });
      const orderId = `ORDER-${Date.now()}-${faker.string.alphanumeric(6)}`;

      const ticket = new Ticket({
        user: pengunjung[faker.number.int({ min: 0, max: pengunjung.length - 1 })]._id,
        wisata: selectedWisata._id,
        orderId,
        purchasedItems: [
          {
            ticketTypeId: ticketType._id,
            name: ticketType.name,
            priceAtPurchase: ticketType.price,
            quantity,
            description: ticketType.description,
          },
        ],
        totalPrice: ticketType.price * quantity,
        paymentStatus: faker.helpers.arrayElement(['pending', 'success', 'failed']),
        paymentMethod: faker.helpers.arrayElement(['credit_card', 'gopay', 'bank_transfer']),
      });
      return ticket.save();
    })
  );

  return { reviews, tickets };
};

// Modify the seedAll function to ensure provinces exist
const seedAll = async () => {
  try {
    await mongoose.connect('mongodb://127.0.0.1:27017/travesia');

    // Check if provinces exist
    const provinceCount = await Province.countDocuments();
    if (provinceCount === 0) {
      throw new Error('No provinces found. Please run province seeder first using: node seeders/provinceSeeder.js');
    }

    // Clear existing data
    await Promise.all([User.deleteMany({}), Wisata.deleteMany({}), Review.deleteMany({}), Ticket.deleteMany({})]);

    console.log('Generating users...');
    const { pengelola, pengunjung } = await generateUsers();

    console.log('Generating wisata...');
    const wisataList = await generateWisata(pengelola);

    console.log('Generating reviews and tickets...');
    await generateReviewsAndTickets(wisataList, pengunjung);

    console.log('Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding data:', error);
    process.exit(1);
  }
};

seedAll();
