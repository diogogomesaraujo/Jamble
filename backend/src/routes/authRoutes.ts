import { Router, Request, Response } from 'express';
import passport from 'passport';

interface AuthenticatedUser extends Express.User {
  token: string;
  user: {
    id: string;
    email: string;
    username?: string;
    spotify_id?: string;
    small_description?: string;
    user_image?: string;
    user_wallpaper?: string;
    favorite_albums?: string[];
    is_spotify_account: boolean;
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

    // Construct a redirect URL with the token and relevant user info, excluding password, user_id, createdAt, and updatedAt
    const redirectUrl = `myapp://callback?token=${user.token}&username=${user.user.username}&email=${user.user.email}&is_spotify_account=${user.user.is_spotify_account}&spotify_id=${user.user.spotify_id}&small_description=${user.user.small_description}&user_image=${user.user.user_image}&user_wallpaper=${user.user.user_wallpaper}&favorite_albums=${user.user.favorite_albums?.join(',')}`;

    // Redirect the user back to the app
    res.redirect(redirectUrl);
  }
);

export default router;
