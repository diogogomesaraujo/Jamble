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

// Helper function to send standardized error responses
const sendErrorResponse = (res: Response, statusCode: number, message: string, error?: any) => {
    return res.status(statusCode).json({
        success: false,
        message,
        ...(error && { error: error.message || error.toString() }),
    });
};

// Helper function to send standardized success responses
const sendSuccessResponse = (res: Response, statusCode: number, message: string, data?: any) => {
    return res.status(statusCode).json({
        success: true,
        message,
        ...(data && { data }),
    });
};

// Get all users
export const getAllUsers = async (req: Request, res: Response): Promise<Response> => {
    try {
        const users = await User.findAll({
            attributes: ['user_id', 'username', 'email', 'is_spotify_account', 'created_at', 'updated_at'],
        });
        return sendSuccessResponse(res, 200, 'Users retrieved successfully', users);
    } catch (error) {
        return sendErrorResponse(res, 500, 'Error retrieving users', error);
    }
};

// Non-Spotify user registration
export const createUser = async (req: Request, res: Response): Promise<Response> => {
    const { username, email, password } = req.body;

    // Validate input
    if (!username || username.length < 3) {
        return sendErrorResponse(res, 400, 'Username must be at least 3 characters long');
    }
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        return sendErrorResponse(res, 400, 'Please provide a valid email address');
    }
    if (!password || password.length < 8) {
        return sendErrorResponse(res, 400, 'Password must be at least 8 characters long');
    }

    try {
        // Check if a user with this email or username already exists
        const existingUser = await User.findOne({
            where: {
                [Op.or]: [{ email }, { username }],
            },
        });

        if (existingUser) {
            return sendErrorResponse(res, 409, 'User with this email or username already exists');
        }

        // Hash the password and create the user
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = await User.create({
            username,
            email,
            password: hashedPassword,
            is_spotify_account: false,
        });

        const token = generateToken(newUser.user_id);
        return sendSuccessResponse(res, 201, 'User created successfully', { user: newUser, token });
    } catch (error) {
        return sendErrorResponse(res, 500, 'Server error during user registration', error);
    }
};

// Complete profile for Spotify users after registration
export const completeProfile = async (req: Request, res: Response): Promise<Response> => {
    const { username } = req.body;
    const userId = (req.user as { user_id: string }).user_id;

    // Validate username input
    if (!username || username.length < 3) {
        return sendErrorResponse(res, 400, 'Username must be at least 3 characters long');
    }

    try {
        // Check if username is already taken
        const existingUser = await User.findOne({ where: { username } });
        if (existingUser) {
            return sendErrorResponse(res, 409, 'Username is already taken');
        }

        // Update user profile
        const user = await User.findOne({ where: { user_id: userId } });
        if (!user) {
            return sendErrorResponse(res, 404, 'User not found');
        }

        user.username = username;
        await user.save();

        return sendSuccessResponse(res, 200, 'Profile updated successfully', user);
    } catch (error) {
        return sendErrorResponse(res, 500, 'Server error during profile update', error);
    }
};

// User login function
export const loginUser = async (req: Request, res: Response): Promise<Response> => {
    const { emailOrUsername, password } = req.body;

    // Validate input
    if (!emailOrUsername || !password) {
        return sendErrorResponse(res, 400, 'Please provide an email/username and password');
    }

    try {
        // Find user by email or username
        const user = await User.findOne({
            where: {
                [Op.or]: [{ email: emailOrUsername }, { username: emailOrUsername }],
            },
        });

        if (!user) {
            return sendErrorResponse(res, 404, 'User not found');
        }

        // Compare passwords
        const isPasswordValid = await bcrypt.compare(password, user.password || '');
        if (!isPasswordValid) {
            return sendErrorResponse(res, 401, 'Invalid password');
        }

        // Generate JWT token
        const token = generateToken(user.user_id);
        return sendSuccessResponse(res, 200, 'Login successful', { token, user });
    } catch (error) {
        return sendErrorResponse(res, 500, 'Server error during login', error);
    }
};
