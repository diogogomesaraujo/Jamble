import passport from 'passport';
import { Strategy as SpotifyStrategy, Profile } from 'passport-spotify';
import jwt from 'jsonwebtoken';
import User from '../models/userModel';
import dotenv from 'dotenv';
import axios from 'axios';

dotenv.config();

// Function to generate a JWT token for the user
const generateToken = (user_id: string): string => {
    if (!process.env.JWT_SECRET) {
        throw new Error('JWT_SECRET is not defined in environment variables');
    }
    return jwt.sign({ user_id }, process.env.JWT_SECRET, {
        expiresIn: '1h', // Token expires in 1 hour
    });
};

// Function to refresh Spotify access token
const refreshSpotifyToken = async (refreshToken: string): Promise<string> => {
    const response = await axios.post(
        'https://accounts.spotify.com/api/token',
        new URLSearchParams({
            grant_type: 'refresh_token',
            refresh_token: refreshToken,
            client_id: process.env.SPOTIFY_CLIENT_ID as string,
            client_secret: process.env.SPOTIFY_CLIENT_SECRET as string,
        }).toString(),
        {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
        }
    );
    if (response.status === 200) {
        return response.data.access_token;
    } else {
        throw new Error(`Failed to refresh access token: ${response.status} - ${response.data}`);
    }
};

passport.use(
    new SpotifyStrategy(
        {
            clientID: process.env.SPOTIFY_CLIENT_ID as string,
            clientSecret: process.env.SPOTIFY_CLIENT_SECRET as string,
            callbackURL: process.env.SPOTIFY_REDIRECT_URI as string,
        },
        async (accessToken, refreshToken, expires_in, profile: Profile, done) => {
            try {
                const email = profile.emails?.[0]?.value || '';
                if (!email) {
                    return done(new Error('No email found for this Spotify profile'), undefined);
                }

                let user = await User.findOne({ where: { email } });

                // If the user does not exist, create a new one
                if (!user) {
                    user = await User.create({
                        email,
                        is_spotify_account: true,
                        spotify_id: profile.id,
                        spotify_access_token: accessToken,
                        spotify_refresh_token: refreshToken,
                    });
                } else {
                    // Attempt to refresh token if access token is invalid
                    try {
                        await axios.get('https://api.spotify.com/v1/me', {
                            headers: { Authorization: `Bearer ${user.spotify_access_token}` },
                        });
                    } catch {
                        // If access token expired, refresh it
                        if (user.spotify_refresh_token) {
                            accessToken = await refreshSpotifyToken(user.spotify_refresh_token);
                            user.spotify_access_token = accessToken;
                            await user.save();
                        } else {
                            return done(new Error('Missing refresh token'), undefined);
                        }
                    }
                    user.spotify_id = profile.id;
                    await user.save();
                }

                // Generate a JWT for the user
                const token = generateToken(user.user_id);
                return done(null, { token, user });
            } catch (error) {
                return done(error as Error, undefined);
            }
        }
    )
);

// Serialize the user into the session
passport.serializeUser((user: any, done) => {
    done(null, user);
});

// Deserialize the user out of the session
passport.deserializeUser((user: any, done) => {
    done(null, user);
});
