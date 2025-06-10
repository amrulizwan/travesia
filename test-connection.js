import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

const testConnection = async () => {
  try {
    console.log('Testing MongoDB connection...');
    console.log('Connection URI:', process.env.MONGO_URI.replace(/\/\/([^:]+):([^@]+)@/, '//$1:****@')); // Hide password

    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      authSource: 'admin',
      retryWrites: true,
      w: 'majority',
      serverSelectionTimeoutMS: 10000,
      connectTimeoutMS: 10000,
    });

    console.log('✅ MongoDB connection successful!');

    // Test basic database operations
    const collections = await mongoose.connection.db.listCollections().toArray();
    console.log(
      'Available collections:',
      collections.map((c) => c.name)
    );
  } catch (error) {
    console.error('❌ MongoDB connection failed:');
    console.error('Error code:', error.code);
    console.error('Error message:', error.message);

    if (error.code === 18) {
      console.error('\n🔍 Authentication failed. Possible causes:');
      console.error('1. Incorrect username or password');
      console.error('2. User does not have access to the specified database');
      console.error('3. Authentication source is incorrect');
      console.error('4. Database server is not accessible');
    }
  } finally {
    await mongoose.disconnect();
    console.log('Connection closed.');
    process.exit(0);
  }
};

testConnection();
