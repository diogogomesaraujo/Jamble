"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const passport_1 = __importDefault(require("passport"));
const userController_1 = require("../controllers/userController");
const authMiddleware_1 = require("../middlewares/authMiddleware");
const router = (0, express_1.Router)();
// Route to initiate Spotify login (redirects to Spotify login page)
router.get('/spotify', passport_1.default.authenticate('spotify', { scope: ['user-read-email'] }));
// Spotify callback route (handles authentication and token generation)
router.get('/spotify/callback', passport_1.default.authenticate('spotify', { failureRedirect: '/', session: false }), // Disable session
(req, res) => {
    const user = req.user;
    if (!user) {
        return res.status(400).json({ message: 'Authentication failed' });
    }
    // Send back the JWT token and user data after successful Spotify login
    res.status(200).json({
        message: 'Spotify authentication successful',
        token: user.token, // JWT token
        user: user.user, // User info
    });
});
// Route to complete profile (set username)
router.post('/complete-profile', authMiddleware_1.authenticateJWT, userController_1.completeProfile);
// Non-Spotify user registration
router.post('/register', userController_1.createUser);
exports.default = router;
