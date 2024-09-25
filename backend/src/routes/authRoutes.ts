import { Router } from 'express';
import passport from 'passport';
import { completeProfile, createUser } from '../controllers/userController';
import { authenticateJWT } from '../middlewares/authMiddleware';

const router = Router();

// Route to initiate Spotify login (redirects to Spotify login page)
router.get('/spotify', passport.authenticate('spotify', { scope: ['user-read-email'] }));

// Spotify callback route (handles authentication and token generation)
router.get(
    '/spotify/callback',
    passport.authenticate('spotify', { failureRedirect: '/', session: false }),  // Disable session
    (req, res) => {
        const user = req.user as { token: string; user: any };

        if (!user) {
            return res.status(400).json({ message: 'Authentication failed' });
        }

        // Send back the JWT token and user data after successful Spotify login
        res.status(200).json({
            message: 'Spotify authentication successful',
            token: user.token,  // JWT token
            user: user.user,    // User info
        });
    }
);

// Route to complete profile (set username)
router.post('/complete-profile', authenticateJWT, completeProfile);

// Non-Spotify user registration
router.post('/register', createUser);

export default router;
