import express from 'express';
import { createPost, deletePost, getPosts } from '../controllers/postController';
import { authenticateJWT } from '../middlewares/authMiddleware';

const router = express.Router();

// Route to create a post
router.post('/create', authenticateJWT, createPost);

// Route to retrieve all posts
router.get('/', authenticateJWT, getPosts);

// Route to delete a post by ID
router.delete('/:postId', authenticateJWT, deletePost);

export default router;
