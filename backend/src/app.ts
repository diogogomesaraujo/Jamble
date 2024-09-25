import express, { Application } from 'express';
import passport from 'passport';
import session from 'express-session';  // Import express-session for session management
import authRoutes from './routes/authRoutes';
import userRoutes from './routes/userRoutes';
import './services/spotifyAuthService';  // Import Spotify service to initialize passport strategy
import dotenv from 'dotenv';

dotenv.config();

const app: Application = express();

// Middleware
app.use(express.json());

// Configure express-session
app.use(
    session({
        secret: process.env.SESSION_SECRET || 'your_secret_key',  // Use a secure session secret
        resave: false,
        saveUninitialized: true,
        cookie: { secure: false },  // Set to true in production if using HTTPS
    })
);

// Initialize Passport with session support
app.use(passport.initialize());
app.use(passport.session());  // Enable persistent login sessions

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

export default app;
