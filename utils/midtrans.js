import midtransClient from 'midtrans-client';
import dotenv from 'dotenv';

dotenv.config();

// Create Snap API instance
const snap = new midtransClient.Snap({
    isProduction: false, // Set to true for production environment
    serverKey: process.env.MIDTRANS_SERVER_KEY,
    clientKey: process.env.MIDTRANS_CLIENT_KEY
});

// Create Core API instance (optional, if you need more direct API calls)
const core = new midtransClient.CoreApi({
    isProduction: false,
    serverKey: process.env.MIDTRANS_SERVER_KEY,
    clientKey: process.env.MIDTRANS_CLIENT_KEY
});

export { snap, core };
