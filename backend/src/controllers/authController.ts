import { Request, Response } from 'express';
import passport from 'passport';

export const spotifyLogin = (req: Request, res: Response, next: any) => {
    passport.authenticate('spotify', { scope: ['user-read-email'] })(req, res, next);
};

export const spotifyCallback = (req: Request, res: Response) => {
    const user = req.user as { token: string; user: any };

    if (!user) {
        return res.status(400).json({ message: 'Authentication failed' });
    }

    res.status(200).json({
        message: 'Spotify authentication successful',
        token: user.token,
        user: user.user,
    });
};
