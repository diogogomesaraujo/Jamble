import { Request, Response } from 'express';
import User from '../models/userModel'; // Import your Sequelize user model
import axios from 'axios';
import passport from 'passport';
import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';

dotenv.config(); // Load environment variables

// Helper function to generate JWT token
const generateToken = (user_id: string): string => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables');
  }
  return jwt.sign({ user_id }, process.env.JWT_SECRET, {
    expiresIn: '1h', // Token valid for 1 hour
  });
};

// Route to initiate Spotify login
export const spotifyLogin = (req: Request, res: Response, next: any) => {
  passport.authenticate('spotify', {
    scope: ['user-read-email', 'user-read-private'],
    session: false,
  })(req, res, next);
};

// Spotify Callback Endpoint for processing the OAuth response
export const spotifyCallback = async (req: Request, res: Response) => {
  const code = req.query.code as string;  // Coerce to string
  const userId = req.query.state as string;  // Assuming state is used to pass userId

  // Validate if authorization code is provided
  if (!code) {
    return res.status(400).json({ message: 'Authorization code is missing' });
  }

  // Ensure environment variables are defined
  const clientId = process.env.SPOTIFY_CLIENT_ID;
  const clientSecret = process.env.SPOTIFY_CLIENT_SECRET;
  const redirectUri = process.env.SPOTIFY_REDIRECT_URI;

  if (!clientId || !clientSecret || !redirectUri) {
    return res.status(500).json({ message: 'Spotify credentials are not properly configured' });
  }

  try {
    // Exchange authorization code for access token
    const tokenResponse = await axios.post('https://accounts.spotify.com/api/token', new URLSearchParams({
      code,  // Already coerced to string
      redirect_uri: redirectUri,
      grant_type: 'authorization_code',
      client_id: clientId,
      client_secret: clientSecret,
    }).toString(), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });

    const { access_token, refresh_token } = tokenResponse.data;

    if (!access_token) {
      return res.status(400).json({ message: 'Failed to obtain access token' });
    }

    // Fetch user profile from Spotify using the access token
    const spotifyUserProfile = await axios.get('https://api.spotify.com/v1/me', {
      headers: {
        Authorization: `Bearer ${access_token}`,
      },
    });

    const spotifyUserData = spotifyUserProfile.data;
    const spotifyEmail = spotifyUserData.email;
    const spotifyUserId = spotifyUserData.id;

    // Ensure required data from Spotify is present
    if (!spotifyUserId || !spotifyEmail) {
      return res.status(400).json({ message: 'Spotify ID or email is missing from Spotify response' });
    }

    // Check if the user exists in your database by email
    let user = await User.findOne({ where: { email: spotifyEmail } });

    if (!user) {
      // If the user does not exist, check if a non-Spotify account is being synced
      if (userId) {
        const nonSpotifyUser = await User.findByPk(userId);

        if (!nonSpotifyUser) {
          return res.status(404).json({ message: 'Non-Spotify user not found' });
        }

        // Handle email mismatch
        if (nonSpotifyUser.email !== spotifyEmail) {
          return res.status(409).json({
            message: 'Email mismatch between Spotify and your current account. Confirm if you want to sync.',
            currentEmail: nonSpotifyUser.email,
            spotifyEmail,
          });
        }

        // Sync Spotify data with non-Spotify account
        nonSpotifyUser.spotify_id = spotifyUserId;
        nonSpotifyUser.is_spotify_account = true;
        nonSpotifyUser.spotify_access_token = access_token; // Store access token
        nonSpotifyUser.spotify_refresh_token = refresh_token; // Store refresh token

        await nonSpotifyUser.save();

        // Generate JWT token
        const token = generateToken(nonSpotifyUser.user_id);

        return res.status(200).json({
          message: 'Spotify account synced successfully',
          user: nonSpotifyUser,
          token,
          refresh_token,
        });
      } else {
        // Create a new Spotify user if no userId is provided
        user = await User.create({
          email: spotifyEmail,
          spotify_id: spotifyUserId,
          is_spotify_account: true,
          spotify_access_token: access_token,
          spotify_refresh_token: refresh_token,
        });

        // Generate JWT token for the new user
        const token = generateToken(user.user_id);

        return res.status(201).json({
          message: 'Spotify account successfully registered',
          user,
          token,
          refresh_token,
        });
      }
    }

    // Check if the existing user is not a Spotify account
    if (!user.is_spotify_account) {
      return res.status(400).json({
        message: 'This email is already registered but not via Spotify. Try syncing your Spotify account.',
      });
    }

    // Update access and refresh tokens if they exist
    user.spotify_access_token = access_token;
    user.spotify_refresh_token = refresh_token;
    await user.save();

    // User exists and is a Spotify account, proceed to login
    const token = generateToken(user.user_id);
    return res.status(200).json({
      message: 'Spotify login successful',
      user,
      token,
      refresh_token,
    });
  } catch (error) {
    if (axios.isAxiosError(error)) {
      // Handle Spotify API errors
      console.error('Spotify API error:', error.response?.data);
      return res.status(500).json({
        message: 'Error fetching user data from Spotify',
        error: error.response?.data || error.message,
      });
    } else {
      console.error('Error during Spotify authentication:', error);
      return res.status(500).json({
        message: 'Error handling Spotify authentication',
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }
};

// Route for refreshing tokens
export const refreshSpotifyToken = async (req: Request, res: Response) => {
  const { refresh_token } = req.body;

  if (!refresh_token) {
    return res.status(400).json({ message: 'Refresh token is missing' });
  }

  const clientId = process.env.SPOTIFY_CLIENT_ID;
  const clientSecret = process.env.SPOTIFY_CLIENT_SECRET;

  if (!clientId || !clientSecret) {
    return res.status(500).json({ message: 'Spotify credentials are not properly configured' });
  }

  try {
    // Use refresh token to obtain a new access token
    const tokenResponse = await axios.post('https://accounts.spotify.com/api/token', new URLSearchParams({
      refresh_token,
      grant_type: 'refresh_token',
      client_id: clientId,
      client_secret: clientSecret,
    }).toString(), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });

    const { access_token, expires_in } = tokenResponse.data;

    return res.status(200).json({
      message: 'Access token refreshed successfully',
      access_token,
      expires_in,
    });
  } catch (error) {
    if (axios.isAxiosError(error)) {
      console.error('Spotify API error during token refresh:', error.response?.data);
      return res.status(500).json({
        message: 'Failed to refresh access token',
        error: error.response?.data || error.message,
      });
    } else {
      console.error('Error during token refresh:', error);
      return res.status(500).json({
        message: 'Error handling token refresh',
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }
};
