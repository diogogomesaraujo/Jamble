"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const userController_1 = require("../controllers/userController");
const authMiddleware_1 = require("../middlewares/authMiddleware");
const router = (0, express_1.Router)();
// Non-Spotify user registration route
router.post('/register', userController_1.createUser);
// Complete profile for Spotify users (set username)
router.post('/complete-profile', authMiddleware_1.authenticateJWT, userController_1.completeProfile);
// Example route to get all users (for testing)
router.get('/users', userController_1.getAllUsers);
// Login route (email or username + password)
router.post('/login', userController_1.loginUser);
exports.default = router;
