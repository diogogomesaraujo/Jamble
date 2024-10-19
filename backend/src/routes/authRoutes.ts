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
    spotify_access_token?: string;
    spotify_refresh_token?: string;
  };
}

const router = Router();

// Route to initiate Spotify login
router.get('/spotify', passport.authenticate('spotify', {
  scope: ['user-read-email', 'user-read-private']
}));

// Route to handle Spotify callback
router.get('/spotify/callback',
  passport.authenticate('spotify', { failureRedirect: '/login' }),
  (req: Request, res: Response) => {
    const user = req.user as AuthenticatedUser;  // Cast req.user to AuthenticatedUser type

    if (!user || !user.token || !user.user) {
      return res.status(400).json({ message: 'Spotify login failed', error: 'User or token missing from response' });
    }

    // Handle undefined fields and ensure favorite_albums are formatted properly
    const username = user.user.username ?? '';  // Default to empty string if null or undefined
    const email = user.user.email ?? '';
    const isSpotifyAccount = user.user.is_spotify_account;
    const spotifyId = user.user.spotify_id ?? '';
    const smallDescription = user.user.small_description ?? '';
    const userImage = user.user.user_image ?? '';
    const userWallpaper = user.user.user_wallpaper ?? '';
    const favoriteAlbums = user.user.favorite_albums ? user.user.favorite_albums.join(',') : '';  // Convert array to comma-separated string

    // Add the new Spotify parameters
    const spotifyAccessToken = user.user.spotify_access_token ?? '';
    const spotifyRefreshToken = user.user.spotify_refresh_token ?? '';

    // Construct a redirect URL with the token and relevant user info
    const redirectUrl = `myapp://callback?token=${user.token}`;

    console.log('Redirect URL:', redirectUrl);

    // Redirect the user back to the app
    res.redirect(redirectUrl);
  }
);

export default router;
