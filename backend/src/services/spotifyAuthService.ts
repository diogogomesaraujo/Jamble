import passport from 'passport';
import { Strategy as SpotifyStrategy, Profile } from 'passport-spotify';
import jwt from 'jsonwebtoken';
import User from '../models/userModel';
import dotenv from 'dotenv';

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
                    return done(new Error('No email found for this Spotify profile'), undefined);  // Fixed: undefined instead of null
                }

                let user = await User.findOne({ where: { email } });

                if (!user) {
                    // Create a new user if they don't exist
                    user = await User.create({
                        email,
                        is_spotify_account: true,
                        username: profile.displayName || null,  // Use display name from Spotify
                        spotify_id: profile.id,                 // Store Spotify ID
                        spotify_access_token: accessToken,      // Store access token
                        spotify_refresh_token: refreshToken,    // Store refresh token
                    });
                } else {
                    // Update Spotify tokens if the user already exists
                    user.spotify_access_token = accessToken;
                    user.spotify_refresh_token = refreshToken;
                    user.spotify_id = profile.id;  // Ensure Spotify ID is up-to-date
                    await user.save();
                }

                // Generate a JWT token for the user
                const token = generateToken(user.user_id);

                // Return the user and token via Passport's `done` function
                return done(null, { token, user });  // Pass `null` directly to indicate no error
            } catch (error) {
                // Handle any errors that occur during the authentication process
                return done(error as Error, undefined);  // Fixed: Pass undefined instead of null
            }
        }
    )
);

// Serialize the user into the session
passport.serializeUser((user: any, done) => {
    done(null, user);  // Here, you could just serialize user.id if using session-based auth
});

// Deserialize the user out of the session
passport.deserializeUser((user: any, done) => {
    done(null, user);  // Fetch user details if using session-based auth
});
