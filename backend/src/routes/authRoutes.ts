import { Router } from 'express';
import passport from 'passport';
import { spotifyCallback, spotifyLogin } from '../controllers/authController';


const router = Router();

// Route to initiate Spotify login (redirects to Spotify login page)
router.get('/spotify', spotifyLogin);

// Spotify callback route (handles authentication and token generation)
router.get(
    '/spotify/callback',
    passport.authenticate('spotify', { failureRedirect: '/', session: false }), // Disable session
    spotifyCallback // Delegate logic to the controller
);

export default router;
