// postRoutes.ts
import express from 'express';
import { createPost, getPosts } from '../controllers/postController';
import { authenticateJWT } from '../middlewares/authMiddleware';

const router = express.Router();

router.post('/create', authenticateJWT, createPost);
router.get('/all', getPosts);

export default router;
