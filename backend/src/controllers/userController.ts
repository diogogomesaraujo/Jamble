import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import User from '../models/userModel';
import { Op } from 'sequelize';

// Helper function to generate JWT token
const generateToken = (user_id: string): string => {
    return jwt.sign({ user_id }, process.env.JWT_SECRET as string, {
        expiresIn: '1h',
    });
};

// Get all users
export const getAllUsers = async (req: Request, res: Response): Promise<Response> => {
    try {
        const users = await User.findAll({
            attributes: ['user_id', 'username', 'email', 'is_spotify_account', 'created_at', 'updated_at'],
        });

        return res.status(200).json(users); // Return statement added here to match the expected return type
    } catch (error) {
        return res.status(500).json({ message: 'Error retrieving users', error });
    }
};

// Non-Spotify user registration
export const createUser = async (req: Request, res: Response): Promise<Response> => {
    const { username, email, password } = req.body;

    try {
        if (!username || username.length < 3 || !email || password.length < 8) {
            return res.status(400).json({
                message: 'Invalid input data. Username must be at least 3 characters long and password must be at least 8 characters long.',
            });
        }

        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
            return res.status(400).json({ message: 'User with this email already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = await User.create({
            username,
            email,
            password: hashedPassword,
            is_spotify_account: false,
        });

        const token = generateToken(newUser.user_id);
        return res.status(201).json({ message: 'User created successfully', user: newUser, token });
    } catch (error) {
        return res.status(500).json({ message: 'Server error', error });
    }
};

// Complete profile for Spotify users after registration
export const completeProfile = async (req: Request, res: Response): Promise<Response> => {
    const { username } = req.body;
    const userId = (req.user as { user_id: string }).user_id;

    if (!username || username.length < 3) {
        return res.status(400).json({ message: 'Username must be at least 3 characters long' });
    }

    try {
        const existingUser = await User.findOne({ where: { username } });
        if (existingUser) {
            return res.status(400).json({ message: 'Username is already taken' });
        }

        const user = await User.findOne({ where: { user_id: userId } });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.username = username;
        await user.save();

        return res.status(200).json({ message: 'Profile updated successfully', user });
    } catch (error) {
        return res.status(500).json({ message: 'Server error', error });
    }
};

// User login function
export const loginUser = async (req: Request, res: Response): Promise<Response> => {
    const { emailOrUsername, password } = req.body;

    try {
        // Input validation
        if (!emailOrUsername || !password) {
            return res.status(400).json({ message: 'Please provide an email or username and password' });
        }

        // Find the user by either email or username
        const user = await User.findOne({
            where: {
                [Op.or]: [{ email: emailOrUsername }, { username: emailOrUsername }],
            }
        });

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Compare the entered password with the stored hashed password
        const isPasswordValid = await bcrypt.compare(password, user.password || '');
        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Invalid password' });
        }

        // Generate JWT token
        const token = generateToken(user.user_id);

        return res.status(200).json({ message: 'Login successful', token, user });
    } catch (error) {
        return res.status(500).json({ message: 'Server error', error });
    }
};
