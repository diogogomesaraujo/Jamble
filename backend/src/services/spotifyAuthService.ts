import passport from 'passport';
import { Strategy as SpotifyStrategy, Profile } from 'passport-spotify';
import jwt from 'jsonwebtoken';
import User from '../models/userModel';
import dotenv from 'dotenv';

dotenv.config();

// Function to generate a JWT token for the user
const generateToken = (user_id: string): string => {
    return jwt.sign({ user_id }, process.env.JWT_SECRET as string, {
        expiresIn: '1h', // Token expires in 1 hour
    });
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

                if (!user) {
                    // Create a new user if they don't exist
                    user = await User.create({
                        email,
                        is_spotify_account: true,
                        username: null,  // Let them set the username later
                    });
                }

                // Generate JWT token
                const token = generateToken(user.user_id);

                return done(null, { token, user });
            } catch (error) {
                return done(error as Error, undefined);
            }
        }
    )
);

passport.serializeUser((user: any, done) => {
    done(null, user);
});

passport.deserializeUser((user: any, done) => {
    done(null, user);
});
