"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const passport_1 = __importDefault(require("passport"));
const authController_1 = require("../controllers/authController");
const router = (0, express_1.Router)();
// Route to initiate Spotify login (redirects to Spotify login page)
router.get('/spotify', authController_1.spotifyLogin);
// Spotify callback route (handles authentication and token generation)
router.get('/spotify/callback', passport_1.default.authenticate('spotify', { failureRedirect: '/', session: false }), // Disable session
authController_1.spotifyCallback // Delegate logic to the controller
);
exports.default = router;
