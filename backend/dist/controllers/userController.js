"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.loginUser = exports.completeProfile = exports.createUser = exports.getAllUsers = void 0;
const bcrypt_1 = __importDefault(require("bcrypt"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const userModel_1 = __importDefault(require("../models/userModel"));
const sequelize_1 = require("sequelize");
// Helper function to generate JWT token
const generateToken = (user_id) => {
    return jsonwebtoken_1.default.sign({ user_id }, process.env.JWT_SECRET, {
        expiresIn: '1h',
    });
};
// Get all users
const getAllUsers = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const users = yield userModel_1.default.findAll({
            attributes: ['user_id', 'username', 'email', 'is_spotify_account', 'created_at', 'updated_at'],
        });
        return res.status(200).json(users); // Return statement added here to match the expected return type
    }
    catch (error) {
        return res.status(500).json({ message: 'Error retrieving users', error });
    }
});
exports.getAllUsers = getAllUsers;
// Non-Spotify user registration
const createUser = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { username, email, password } = req.body;
    try {
        if (!username || username.length < 3 || !email || password.length < 8) {
            return res.status(400).json({
                message: 'Invalid input data. Username must be at least 3 characters long and password must be at least 8 characters long.',
            });
        }
        const existingUser = yield userModel_1.default.findOne({ where: { email } });
        if (existingUser) {
            return res.status(400).json({ message: 'User with this email already exists' });
        }
        const hashedPassword = yield bcrypt_1.default.hash(password, 10);
        const newUser = yield userModel_1.default.create({
            username,
            email,
            password: hashedPassword,
            is_spotify_account: false,
        });
        const token = generateToken(newUser.user_id);
        return res.status(201).json({ message: 'User created successfully', user: newUser, token });
    }
    catch (error) {
        return res.status(500).json({ message: 'Server error', error });
    }
});
exports.createUser = createUser;
// Complete profile for Spotify users after registration
const completeProfile = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { username } = req.body;
    const userId = req.user.user_id;
    if (!username || username.length < 3) {
        return res.status(400).json({ message: 'Username must be at least 3 characters long' });
    }
    try {
        const existingUser = yield userModel_1.default.findOne({ where: { username } });
        if (existingUser) {
            return res.status(400).json({ message: 'Username is already taken' });
        }
        const user = yield userModel_1.default.findOne({ where: { user_id: userId } });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        user.username = username;
        yield user.save();
        return res.status(200).json({ message: 'Profile updated successfully', user });
    }
    catch (error) {
        return res.status(500).json({ message: 'Server error', error });
    }
});
exports.completeProfile = completeProfile;
// User login function
const loginUser = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { emailOrUsername, password } = req.body;
    try {
        // Input validation
        if (!emailOrUsername || !password) {
            return res.status(400).json({ message: 'Please provide an email or username and password' });
        }
        // Find the user by either email or username
        const user = yield userModel_1.default.findOne({
            where: {
                [sequelize_1.Op.or]: [{ email: emailOrUsername }, { username: emailOrUsername }],
            }
        });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        // Compare the entered password with the stored hashed password
        const isPasswordValid = yield bcrypt_1.default.compare(password, user.password || '');
        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Invalid password' });
        }
        // Generate JWT token
        const token = generateToken(user.user_id);
        return res.status(200).json({ message: 'Login successful', token, user });
    }
    catch (error) {
        return res.status(500).json({ message: 'Server error', error });
    }
});
exports.loginUser = loginUser;
