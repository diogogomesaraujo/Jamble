import { Sequelize } from 'sequelize';
import User from './models/userModel'; // Ensure this is the correct path

const sequelize = new Sequelize(process.env.DATABASE_URL as string, {
  dialect: 'postgres',
});

async function syncDatabase() {
  try {
    await sequelize.authenticate();  // Verify connection
    console.log('Connection has been established successfully.');
    
    // Sync all models
    await User.sync({ force: true });  // force: true will drop the table if it already exists and create a new one
    console.log('User table has been synced.');
    
  } catch (error) {
    console.error('Unable to connect to the database:', error);
  } finally {
    await sequelize.close();
  }
}

syncDatabase();
