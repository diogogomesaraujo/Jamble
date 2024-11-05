// syncDatabase.ts
import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';
import User from './models/userModel';
import Post from './models/postModel';
import { setupAssociations } from './models/associations';

dotenv.config();

const sequelize = new Sequelize(process.env.DATABASE_URL as string, {
  dialect: 'postgres',
});

setupAssociations();  // Set up associations after models are imported

async function syncDatabase() {
  try {
    await sequelize.authenticate();
    console.log('Connection has been established successfully.');
    
    // Sync models
    await User.sync({ force: true });
    await Post.sync({ force: true });
    console.log('User and Post tables have been synced.');
    
  } catch (error) {
    console.error('Unable to connect to the database:', error);
  } finally {
    await sequelize.close();
  }
}

syncDatabase();
