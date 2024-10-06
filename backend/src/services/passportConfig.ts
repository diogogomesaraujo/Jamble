import passport from 'passport';
import { Strategy as SpotifyStrategy } from 'passport-spotify';
import jwt from 'jsonwebtoken';
import User from '../models/userModel'; // Sequelize User model
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables

// Generate JWT token
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
    async (accessToken, refreshToken, expires_in, profile, done) => {
      try {
        const email = profile.emails && profile.emails[0] ? profile.emails[0].value : null;

        if (!email) {
          console.error('No email found for this Spotify profile:', profile);
          return done(new Error('No email found for this Spotify profile'), undefined);
        }

        // Find or create user
        let user = await User.findOne({ where: { email } });
        if (!user) {
          user = await User.create({
            email,
            spotify_id: profile.id,
            username: profile.displayName || null,
            is_spotify_account: true,
          });
        }

        const token = generateToken(user.user_id);
        return done(null, { token, user });
      } catch (error) {
        return done(error as Error, undefined);
      }
    }
  )
);

// Optional: Serialize and deserialize for session-based authentication
passport.serializeUser((user: any, done) => {
  done(null, user.user_id);
});

passport.deserializeUser(async (user_id: string, done) => {
  try {
    const user = await User.findByPk(user_id);
    done(null, user);
  } catch (error) {
    done(error, null);
  }
});

export default passport;
