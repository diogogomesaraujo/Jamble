import { Router } from 'express';
import passport from 'passport';
import { getAllUsers, createUser, completeProfile, loginUser } from '../controllers/userController';
import { authenticateJWT } from '../middlewares/authMiddleware';

const router: Router = Router();

// Non-Spotify user registration route
router.post('/register', createUser);

// Complete profile for Spotify users (set username)
router.post('/complete-profile', authenticateJWT, completeProfile);

// Example route to get all users (for testing)
router.get('/users', getAllUsers);

// Login route (email or username + password)
router.post('/login', loginUser);

export default router;
