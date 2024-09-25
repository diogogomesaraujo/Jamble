"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const passport_1 = __importDefault(require("passport"));
const express_session_1 = __importDefault(require("express-session")); // Import express-session for session management
const authRoutes_1 = __importDefault(require("./routes/authRoutes"));
const userRoutes_1 = __importDefault(require("./routes/userRoutes"));
require("./services/spotifyAuthService"); // Import Spotify service to initialize passport strategy
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app = (0, express_1.default)();
// Middleware
app.use(express_1.default.json());
// Configure express-session
app.use((0, express_session_1.default)({
    secret: process.env.SESSION_SECRET || 'your_secret_key', // Use a secure session secret
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false }, // Set to true in production if using HTTPS
}));
// Initialize Passport with session support
app.use(passport_1.default.initialize());
app.use(passport_1.default.session()); // Enable persistent login sessions
// Routes
app.use('/api/auth', authRoutes_1.default);
app.use('/api/users', userRoutes_1.default);
exports.default = app;
