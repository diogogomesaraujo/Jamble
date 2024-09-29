"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.spotifyCallback = exports.spotifyLogin = void 0;
const passport_1 = __importDefault(require("passport"));
const spotifyLogin = (req, res, next) => {
    passport_1.default.authenticate('spotify', { scope: ['user-read-email'] })(req, res, next);
};
exports.spotifyLogin = spotifyLogin;
const spotifyCallback = (req, res) => {
    const user = req.user;
    if (!user) {
        return res.status(400).json({ message: 'Authentication failed' });
    }
    res.status(200).json({
        message: 'Spotify authentication successful',
        token: user.token,
        user: user.user,
    });
};
exports.spotifyCallback = spotifyCallback;
