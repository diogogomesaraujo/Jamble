import { Request, Response } from 'express';
import passport from 'passport';
import User from '../models/userModel';  // Import your user model

export const spotifyLogin = (req: Request, res: Response, next: any) => {
    passport.authenticate('spotify', { scope: ['user-read-email'] })(req, res, next);
};

export const spotifyCallback = async (req: Request, res: Response) => {
    const spotifyProfile = req.user as { token: string; user: any };

    if (!spotifyProfile) {
        return res.status(400).json({ message: 'Authentication failed' });
    }

    try {
        const spotifyEmail = spotifyProfile.user.email;
        const spotifyUserId = spotifyProfile.user.id;

        // Check if the user is logged in (for sync case)
        const loggedInUser = req.user as { user_id: string } | null;

        if (loggedInUser) {
            // Case 3: Syncing Spotify account to an existing non-Spotify user
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
            existingUser.email = spotifyEmail;  // Sync the email if it's different
            existingUser.is_spotify_account = true;
            existingUser.spotify_id = spotifyUserId;  // Add Spotify ID to the user record (if applicable)
            await existingUser.save();

            return res.status(200).json({
                message: 'Spotify account successfully synced',
                token: spotifyProfile.token,
                user: existingUser,
            });

        } else {
            // Case 1 & 2: New registration via Spotify or logging in via Spotify
            const existingSpotifyUser = await User.findOne({ where: { email: spotifyEmail } });

            if (existingSpotifyUser) {
                // Case 2: Existing user logging in via Spotify
                if (existingSpotifyUser.is_spotify_account) {
                    // User already has a Spotify account in the system, log them in
                    return res.status(200).json({
                        message: 'Spotify login successful',
                        token: spotifyProfile.token,
                        user: existingSpotifyUser,
                    });
                } else {
                    return res.status(400).json({ message: 'This email is already registered but not via Spotify. Try syncing your account.' });
                }
            } else {
                // Case 1: New user registration via Spotify
                const newUser = await User.create({
                    email: spotifyEmail,
                    is_spotify_account: true,
                    spotify_id: spotifyUserId,  // Store the Spotify ID
                    username: null,  // Set to null for now, until user sets it up
                });

                return res.status(201).json({
                    message: 'Spotify account successfully registered',
                    token: spotifyProfile.token,
                    user: newUser,
                });
            }
        }
    } catch (error) {
        return res.status(500).json({ message: 'Error handling Spotify authentication', error });
    }
};
