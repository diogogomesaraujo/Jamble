import { Request, Response } from 'express';
import Post from '../models/postModel';
import User from '../models/userModel';

// Function to create a post
export const createPost = async (req: Request, res: Response): Promise<Response> => {
    try {
        // Retrieve user ID from the authenticated request
        const userId = (req.user as { user_id: string })?.user_id;
        if (!userId) {
            return res.status(401).json({ message: 'User not authenticated' });
        }

        const { content, type, reference_id } = req.body;

        // Validate the required fields
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

// Function to retrieve all posts for the authenticated user
export const getPosts = async (req: Request, res: Response): Promise<Response> => {
    try {
        // Retrieve user ID from the authenticated request
        const userId = (req.user as { user_id: string })?.user_id;

        if (!userId) {
            return res.status(401).json({ message: 'Unauthorized access' });
        }

        // Fetch posts for the authenticated user
        const posts = await Post.findAll({
            where: { user_id: userId },
            order: [['createdAt', 'DESC']], // Order by the most recent
        });

        return res.status(200).json(posts);
    } catch (error) {
        console.error('Error retrieving posts:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

// Function to delete a post
export const deletePost = async (req: Request, res: Response): Promise<Response> => {
    try {
        // Retrieve the user ID from the authenticated request
        const userId = (req.user as { user_id: string })?.user_id;
        if (!userId) {
            return res.status(401).json({ message: 'User not authenticated' });
        }

        // Retrieve the post ID from the request parameters
        const { postId } = req.params;

        if (!postId) {
            return res.status(400).json({ message: 'Post ID is required' });
        }

        // Find the post to ensure it exists and belongs to the authenticated user
        const post = await Post.findOne({ where: { post_id: postId, user_id: userId } }); // Correct field name

        if (!post) {
            return res.status(404).json({ message: 'Post not found or unauthorized' });
        }

        // Delete the post
        await post.destroy();

        return res.status(200).json({ message: 'Post deleted successfully' });
    } catch (error) {
        console.error('Error deleting post:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};
