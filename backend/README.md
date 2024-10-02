# Jamble Backend

This is the backend for the Jamble project, a social media app that integrates Spotify authentication. The backend is built using Node.js, Express, Sequelize, and PostgreSQL. It provides functionality for user authentication (via email/password or Spotify), user management, and syncing Spotify accounts.

## Project Structure

```
backend/
│
├── config/               # Configuration files
├── dist/                 # Compiled output files
├── node_modules/         # Node.js dependencies
│
└── src/
    ├── controllers/      # Express controllers for handling requests
    │   ├── authController.ts
    │   └── userController.ts
    ├── middlewares/      # Middlewares for authentication, etc.
    │   └── authMiddleware.ts
    ├── models/           # Sequelize models (e.g., User model)
    │   └── userModel.ts
    ├── routes/           # API routes for authentication and user management
    │   ├── authRoutes.ts
    │   └── userRoutes.ts
    ├── services/         # Service logic for Spotify authentication, etc.
    │   └── spotifyAuthService.ts
    ├── app.ts            # Express app configuration
    ├── db.ts             # Sequelize initialization and DB connection
    └── server.ts         # Main server entry point
│
├── .env                  # Environment variables
├── .gitignore            # Git ignore rules
├── nodemon.json          # Nodemon configuration
├── package.json          # Project dependencies and scripts
├── tsconfig.json         # TypeScript configuration
└── package-lock.json     # Exact versions of installed dependencies
```

## Prerequisites

- **Node.js** (v14 or higher)
- **npm** (v6 or higher)
- **PostgreSQL** database

Make sure PostgreSQL is installed and running locally or on a server, and create a new database for the project.

## Environment Variables

Create a `.env` file in the root directory of the project, with the following variables:

```bash
DATABASE_URL=postgres://username:password@localhost:5432/jamble_db
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
SPOTIFY_REDIRECT_URI=http://localhost:3000/api/auth/spotify/callback
JWT_SECRET=your_jwt_secret_key
SESSION_SECRET=your_session_secret_key
PORT=3000
```

- **DATABASE_URL**: The connection string for the PostgreSQL database.
- **SPOTIFY_CLIENT_ID**: Your Spotify client ID.
- **SPOTIFY_CLIENT_SECRET**: Your Spotify client secret.
- **SPOTIFY_REDIRECT_URI**: The URI Spotify will redirect to after authentication.
- **JWT_SECRET**: Secret for signing JWT tokens.
- **SESSION_SECRET**: Secret for managing express-session.
- **PORT**: The port your backend server will run on.

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/jamble-backend.git
   cd jamble-backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

## Database Initialization

The database is initialized using Sequelize. To sync your models with the database and create the necessary tables, make sure your `DATABASE_URL` is correctly configured in the `.env` file.

Run the following command to synchronize the database:

```bash
npx ts-node ./src/db.ts
```

This will connect to your PostgreSQL database and synchronize the models, creating tables if they don't already exist.

## Running the Backend

To start the server in development mode, run:

```bash
npx nodemon
```

Nodemon will watch for changes in the `src` directory and automatically restart the server.

### Nodemon Configuration

Nodemon is configured in the `nodemon.json` file as follows:

```json
{
  "watch": ["src"],
  "ext": "ts",
  "ignore": ["src/**/*.spec.ts"],
  "exec": "ts-node ./src/server.ts"
}
```

This will watch for changes in the `src` directory, and execute `ts-node` to run the `server.ts` file.

## API Endpoints

### Authentication

- `POST /api/auth/register`: Register a new user with email and password.
- `POST /api/auth/login`: Log in with email or username and password.
- `GET /api/auth/spotify`: Start Spotify OAuth flow.
- `GET /api/auth/spotify/callback`: Spotify OAuth callback.
- `POST /api/auth/complete-profile`: Complete profile for Spotify users (set username).

### User Management

- `GET /api/users`: Fetch all users (for testing purposes).
- `POST /api/users/complete-profile`: Complete the profile for Spotify users (set username).

## Spotify Integration

This project uses **passport-spotify** strategy to authenticate users via Spotify. Users can either sign up directly using Spotify or sync their Spotify account later if they originally registered with email and password.

## Technologies Used

- **Node.js**: JavaScript runtime for building server-side applications.
- **Express.js**: Web framework for Node.js.
- **Sequelize**: ORM for interacting with the PostgreSQL database.
- **PostgreSQL**: Relational database used to store user data.
- **TypeScript**: JavaScript with type safety.
- **Passport.js**: Authentication middleware for Node.js.
- **Spotify Web API**: Integration with Spotify for user authentication and fetching user data.

## Troubleshooting

- Ensure PostgreSQL is running, and the connection string is correctly configured in `.env`.
- Make sure to create your Spotify Developer Application and configure the `SPOTIFY_CLIENT_ID`, `SPOTIFY_CLIENT_SECRET`, and `SPOTIFY_REDIRECT_URI` in the `.env` file.
- If you encounter database connection issues, verify that the credentials and connection string in `DATABASE_URL` are correct.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
