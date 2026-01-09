import mongoose from 'mongoose';
import bcryptjs from 'bcryptjs';
import dotenv from 'dotenv';

dotenv.config();

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name: String,
  age: Number,
  gender: String,
  bio: String,
  photos: [String],
  tier: { type: String, default: 'free' },
  emailVerified: { type: Boolean, default: true },
  suspended: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);

async function seed() {
  try {
    console.log('?? Seeding database...');
    
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/meengle');
    console.log('? Connected to MongoDB');

    // Create admin user
    const adminPassword = await bcryptjs.hash('Admin123456', 10);
    const adminExists = await User.findOne({ email: 'admin@meengle.app' });

    if (!adminExists) {
      await User.create({
        email: 'admin@meengle.app',
        password: adminPassword,
        name: 'Admin',
        tier: 'platinum',
        emailVerified: true
      });
      console.log('? Admin user created: admin@meengle.app / Admin123456');
    } else {
      console.log('??  Admin user already exists');
    }

    // Create test users
    const testPassword = await bcryptjs.hash('Test123456', 10);
    const testUsers = [
      { email: 'test1@meengle.app', name: 'Test User 1', gender: 'male' },
      { email: 'test2@meengle.app', name: 'Test User 2', gender: 'female' },
      { email: 'test3@meengle.app', name: 'Test User 3', gender: 'male' }
    ];

    for (const testUser of testUsers) {
      const exists = await User.findOne({ email: testUser.email });
      if (!exists) {
        await User.create({
          email: testUser.email,
          password: testPassword,
          name: testUser.name,
          gender: testUser.gender,
          tier: 'free',
          emailVerified: true
        });
        console.log(`? Test user created: ${testUser.email} / Test123456`);
      }
    }

    console.log('\n? Database seeding complete\n');
    process.exit(0);
  } catch (error) {
    console.error('? Seed error:', error);
    process.exit(1);
  }
}

seed();
