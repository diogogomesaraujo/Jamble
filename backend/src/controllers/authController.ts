import { Request, Response } from 'express';
import User from '../models/userModel'; // Import your Sequelize user model
import passport from 'passport';

export const spotifyLogin = (req: Request, res: Response, next: any) => {
    passport.authenticate('spotify', { scope: ['user-read-email', 'user-read-private'] })(req, res, next);
};

export const spotifyCallback = async (req: Request, res: Response) => {
    const spotifyProfile = req.user as { token: string; user: any };

    if (!spotifyProfile) {
        return res.status(400).json({ message: 'Authentication failed: no Spotify profile found' });
    }

    try {
        const spotifyEmail = spotifyProfile.user.emails[0].value;
        const spotifyUserId = spotifyProfile.user.id;

        // Log the Spotify profile for debugging purposes
        console.log('Spotify Profile:', spotifyProfile);

        // Check if the user is logged in (for sync case)
        const loggedInUser = req.user as { user_id: string } | null;

        if (loggedInUser) {
            // Syncing Spotify account to an existing non-Spotify user
            const existingUser = await User.findOne({ where: { user_id: loggedInUser.user_id } });

            if (!existingUser) {
                return res.status(404).json({ message: 'User not found for syncing' });
            }

            // Check if the Spotify account email is already linked to a different user
            const spotifyUser = await User.findOne({ where: { email: spotifyEmail } });

            if (spotifyUser && spotifyUser.user_id !== existingUser.user_id) {
                return res.status(400).json({ message: 'This Spotify account is already linked to another user' });
            }

            // Update the non-Spotify user with Spotify details
            existingUser.email = spotifyEmail;
            existingUser.is_spotify_account = true;
            existingUser.spotify_id = spotifyUserId;
            await existingUser.save();

            return res.status(200).json({
                message: 'Spotify account successfully synced',
                token: spotifyProfile.token,
                user: existingUser,
            });

        } else {
            // New registration via Spotify or logging in via Spotify
            const existingSpotifyUser = await User.findOne({ where: { email: spotifyEmail } });

            if (existingSpotifyUser) {
                // Existing user logging in via Spotify
                if (existingSpotifyUser.is_spotify_account) {
                    return res.status(200).json({
                        message: 'Spotify login successful',
                        token: spotifyProfile.token,
                        user: existingSpotifyUser,
                    });
                } else {
                    return res.status(400).json({ message: 'This email is already registered but not via Spotify. Try syncing your account.' });
                }
            } else {
                // New user registration via Spotify
                const newUser = await User.create({
                    email: spotifyEmail,
                    is_spotify_account: true,
                    spotify_id: spotifyUserId,
                    username: spotifyProfile.user.displayName || null, // Set to Spotify's display name
                });

                return res.status(201).json({
                    message: 'Spotify account successfully registered',
                    token: spotifyProfile.token,
                    user: newUser,
                });
            }
        }
    } catch (error) {
        console.error('Error during Spotify authentication:', error);
        return res.status(500).json({ message: 'Error handling Spotify authentication', error });
    }
};
