import express, { Application } from 'express';
import passport from 'passport';
import session from 'express-session';
import cors from 'cors';  // Import CORS package
import authRoutes from './routes/authRoutes';
import userRoutes from './routes/userRoutes';
import postRoutes from './routes/postRoutes';
import './services/spotifyAuthService';  // Import Spotify service to initialize passport strategy
import dotenv from 'dotenv';

dotenv.config();

const app: Application = express();

// Middleware
app.use(express.json());

// Configure express-session
app.use(
    session({
        secret: process.env.SESSION_SECRET || 'your_secret_key',  // Use a secure session secret from env
        resave: false,
        saveUninitialized: true,
        cookie: { 
            secure: process.env.NODE_ENV === 'production',  // Set to true in production if using HTTPS
            httpOnly: true,  // Ensure the cookie is only accessible by the web server
            maxAge: 24 * 60 * 60 * 1000  // Session expires after 24 hours
        },
    })
);

// Configure CORS to allow requests from Flutter app
app.use(cors({
    origin: '*',  // You can restrict this to specific origins for security (e.g., http://localhost:8080 or IP address)
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));

// Initialize Passport with session support
app.use(passport.initialize());
app.use(passport.session());  // Enable persistent login sessions

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/posts', postRoutes);

export default app;
