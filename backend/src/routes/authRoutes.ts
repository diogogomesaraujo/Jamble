import { Router, Request, Response } from 'express';
import passport from 'passport';

interface AuthenticatedUser extends Express.User {
  token: string;
  user: {
    id: string;
    email: string;
    username?: string;
    spotify_id?: string;
  };
}

const router = Router();

// Route to initiate Spotify login
router.get('/spotify', passport.authenticate('spotify', { scope: ['user-read-email', 'user-read-private'] }));

// Route to handle Spotify callback
router.get(
  '/spotify/callback',
  passport.authenticate('spotify', { failureRedirect: '/login' }),
  (req: Request, res: Response) => {
    const user = req.user as AuthenticatedUser;  // Cast req.user to AuthenticatedUser type

    if (!user || !user.token || !user.user) {
      return res.status(400).json({ message: 'Spotify login failed', error: 'User or token missing from response' });
    }

    // Construct a redirect URL with the token and user info
    const redirectUrl = `myapp://callback?token=${user.token}&email=${user.user.email}`;

    // Redirect the user back to the app
    res.redirect(redirectUrl);
  }
);

export default router;
