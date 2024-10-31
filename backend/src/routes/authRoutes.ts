import { Router, Request, Response } from 'express';
import passport from 'passport';
import axios from 'axios';
import { authenticateJWT } from '../middlewares/authMiddleware';
import User from '../models/userModel';

interface AuthenticatedUser extends Express.User {
  token: string;
  user: {
    user_id: string;
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
  scope: ['user-read-email', 'user-read-private', 'user-top-read'],
}));

// Route to handle Spotify callback
router.get('/spotify/callback',
  passport.authenticate('spotify', { failureRedirect: '/login' }),
  async (req: Request, res: Response) => {
    const user = req.user as AuthenticatedUser;  // Cast req.user to AuthenticatedUser type

    if (!user || !user.token || !user.user) {
      return res.status(400).json({ message: 'Spotify login failed', error: 'User or token missing from response' });
    }

    // Extract user details
    const { user_id, spotify_access_token, spotify_refresh_token } = user.user;

    try {
      // Update Spotify tokens in the database
      await User.update(
        {
          spotify_access_token,
          spotify_refresh_token,
        },
        { where: { user_id } }
      );

      console.log('Spotify tokens updated successfully for user:', user_id);
    } catch (error) {
      console.error('Error updating Spotify tokens:', error);
      return res.status(500).json({ message: 'Failed to update tokens', error: error instanceof Error ? error.message : 'Unknown error' });
    }

    // Construct a redirect URL with the token for the frontend app
    const redirectUrl = `myapp://callback?token=${user.token}`;
    console.log('Redirecting to:', redirectUrl);

    // Redirect the user back to the app with the token
    res.redirect(redirectUrl);
  }
);

// Route to get user's top artists from Spotify
router.get('/spotify/top-artists', authenticateJWT, async (req: Request, res: Response) => {
  const userId = (req.user as { user_id: string }).user_id;

  try {
    // Find the user in the database
    const user = await User.findOne({ where: { user_id: userId } });

    if (!user || !user.spotify_access_token || !user.spotify_refresh_token) {
      return res.status(400).json({ message: 'User or Spotify tokens not found' });
    }

    let accessToken = user.spotify_access_token;

    // Check if the access token is valid; if not, refresh it
    try {
      await axios.get('https://api.spotify.com/v1/me', {
        headers: { Authorization: `Bearer ${accessToken}` },
      });
    } catch (error: any) {
      if (error.response && error.response.status === 401) {
        // Refresh Spotify access token
        const refreshResponse = await axios.post('https://accounts.spotify.com/api/token', null, {
          params: {
            grant_type: 'refresh_token',
            refresh_token: user.spotify_refresh_token,
            client_id: process.env.SPOTIFY_CLIENT_ID!,
            client_secret: process.env.SPOTIFY_CLIENT_SECRET!,
          },
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        });

        accessToken = refreshResponse.data.access_token;

        // Update the refreshed access token in the database
        await User.update(
          { spotify_access_token: accessToken },
          { where: { user_id: userId } }
        );
      } else {
        console.error('Error verifying access token:', error);
        return res.status(500).json({ message: 'Failed to verify or refresh access token' });
      }
    }

    // Fetch the user's top artists from Spotify
    const topArtistsResponse = await axios.get('https://api.spotify.com/v1/me/top/artists', {
      headers: { Authorization: `Bearer ${accessToken}` },
      params: { limit: 50 },
    });

    res.status(200).json(topArtistsResponse.data);
  } catch (error) {
    console.error('Error fetching top artists:', error);
    res.status(500).json({ message: 'Failed to fetch top artists' });
  }
});

// Route to get user's top songs from Spotify
router.get('/spotify/top-songs', authenticateJWT, async (req: Request, res: Response) => {
  const userId = (req.user as { user_id: string }).user_id;

  try {
    // Find the user in the database
    const user = await User.findOne({ where: { user_id: userId } });

    if (!user || !user.spotify_access_token || !user.spotify_refresh_token) {
      return res.status(400).json({ message: 'User or Spotify tokens not found' });
    }

    let accessToken = user.spotify_access_token;

    // Check if the access token is valid; if not, refresh it
    try {
      await axios.get('https://api.spotify.com/v1/me', {
        headers: { Authorization: `Bearer ${accessToken}` },
      });
    } catch (error: any) {
      if (error.response && error.response.status === 401) {
        // Refresh Spotify access token
        const refreshResponse = await axios.post('https://accounts.spotify.com/api/token', null, {
          params: {
            grant_type: 'refresh_token',
            refresh_token: user.spotify_refresh_token,
            client_id: process.env.SPOTIFY_CLIENT_ID!,
            client_secret: process.env.SPOTIFY_CLIENT_SECRET!,
          },
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        });

        accessToken = refreshResponse.data.access_token;

        // Update the refreshed access token in the database
        await User.update(
          { spotify_access_token: accessToken },
          { where: { user_id: userId } }
        );
      } else {
        console.error('Error verifying access token:', error);
        return res.status(500).json({ message: 'Failed to verify or refresh access token' });
      }
    }

    // Fetch the user's top songs from Spotify
    const topSongsResponse = await axios.get('https://api.spotify.com/v1/me/top/tracks', {
      headers: { Authorization: `Bearer ${accessToken}` },
      params: { limit: 50 },
    });

    res.status(200).json(topSongsResponse.data);
  } catch (error) {
    console.error('Error fetching top songs:', error);
    res.status(500).json({ message: 'Failed to fetch top songs' });
  }
});

export default router;
