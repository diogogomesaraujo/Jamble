import passport from 'passport';
import { Strategy as SpotifyStrategy } from 'passport-spotify';
import jwt from 'jsonwebtoken';
import User from '../models/userModel'; // Sequelize User model
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables

// JWT Token Generation
const generateToken = (userId: string): string => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables');
  }

  return jwt.sign({ user_id: userId }, process.env.JWT_SECRET, {
    expiresIn: '1h', // Token expires in 1 hour
  });
};

// Spotify OAuth Strategy
passport.use(
  new SpotifyStrategy(
    {
      clientID: process.env.SPOTIFY_CLIENT_ID as string,
      clientSecret: process.env.SPOTIFY_CLIENT_SECRET as string,
      callbackURL: process.env.SPOTIFY_REDIRECT_URI as string,
    },
    async (accessToken, refreshToken, expires_in, profile, done) => {
      try {
        // Validate profile and email
        if (!profile || !profile.emails || !profile.emails.length) {
          console.error('Profile information is incomplete or missing emails.');
          return done(new Error('No email found for this Spotify profile'), undefined);
        }

        const email = profile.emails[0].value;

        // Check if user exists, if not, create a new one
        let user = await User.findOne({ where: { email } });
        if (!user) {
          console.log('Creating new user for email:', email);

          user = await User.create({
            email,
            spotify_id: profile.id,
            username: profile.displayName || undefined,
            is_spotify_account: true,
          });
        } else {
          console.log('User already exists for email:', email);
        }

        // Generate JWT token
        const token = generateToken(user.user_id);

        // Return user and token
        return done(null, { token, user });
      } catch (error) {
        console.error('Error during Spotify authentication:', error);
        return done(error as Error, undefined);
      }
    }
  )
);

// Optional: Serialize and Deserialize for session-based authentication
passport.serializeUser((user: any, done) => {
  done(null, user.user_id);
});

passport.deserializeUser(async (user_id: string, done) => {
  try {
    const user = await User.findByPk(user_id);
    if (!user) {
      return done(new Error('User not found'), undefined);
    }
    done(null, user);
  } catch (error) {
    console.error('Error deserializing user:', error);
    done(error, undefined);
  }
});

export default passport;
