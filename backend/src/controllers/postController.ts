import { Request, Response } from 'express';
import Post from '../models/postModel';
import User from '../models/userModel';

// Function to create a post
export const createPost = async (req: Request, res: Response): Promise<Response> => {
    try {
        // Check if user ID is available in the request object from the auth middleware
        const userId = (req.user as { user_id: string }).user_id;        
        if (!userId) {
            return res.status(401).json({ message: 'User not authenticated' });
        }

        const { content, type, reference_id } = req.body;

        // Validate post data
        if (!content || !type || !reference_id) {
            return res.status(400).json({ message: 'All fields are required: content, type, reference_id' });
        }

        // Create the post
        const post = await Post.create({
            user_id: userId,
            content,
            type,
            reference_id,
        });

        return res.status(201).json(post);
    } catch (error) {
        console.error('Error creating post:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

export const getPosts = async (req: Request, res: Response): Promise<Response> => {
    try {
        // Retrieve user_id from the JWT token (added by auth middleware)
        const userId = (req.user as { user_id: string })?.user_id;

        if (!userId) {
            return res.status(401).json({ message: 'Unauthorized access' });
        }

        // Fetch posts for the authenticated user
        const posts = await Post.findAll({
            where: { user_id: userId }, // Ensure it matches user_id field in Post model
            order: [['createdAt', 'DESC']], // Order posts by most recent
        });

        return res.status(200).json(posts);
    } catch (error) {
        console.error('Error retrieving posts:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};
