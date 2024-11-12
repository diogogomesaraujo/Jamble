# Jamble - A Social Network with Spotify Integration 🎶✨

## About

**Jamble** is a super fun social network where you can share your music tastes with friends through Spotify integration! 🎧 Users can log in with Spotify or create a traditional account using email and password.

## Screenshots 📸

Coming soon! Stay tuned to see how awesome Jamble looks in action! 🚀

## Project Structure 📂

```
jamble/
├── backend/  # Node.js + Express + TypeScript server
└── frontend/ # Flutter application
```

## Requirements 🛠️

- Node.js (v14 or higher)
- npm (v6 or higher)
- PostgreSQL
- Flutter SDK
- Spotify Developer Account

## Setting Up the Backend 🚀

### Set Up the Database

Create the PostgreSQL database:

```bash
createdb jamble_db
```

### Configure Environment Variables

Create a `.env` file in the `backend/` folder:

```
DATABASE_URL=postgres://username:password@localhost:5432/jamble_db
SPOTIFY_CLIENT_ID=your_client_id
SPOTIFY_CLIENT_SECRET=your_client_secret
SPOTIFY_REDIRECT_URI=http://localhost:3000/api/auth/spotify/callback
JWT_SECRET=your_secret_key
SESSION_SECRET=your_session_key
PORT=3000
```

### Install Dependencies and Start

```bash
cd backend
npm install
npx nodemon
```

## Setting Up the Frontend 📱

### Set the Backend URL

In the file `lib/services/spotify.dart`, make sure the backend URL is correct:

```dart
const backendUrl = 'http://127.0.0.1:3000';
```

### Install Dependencies and Run

```bash
cd frontend
flutter pub get
flutter run
```

## Main Features 🌟

- Login via Spotify or email/password
- View your top 50 artists and songs
- Customizable profile with description and favorite albums
- Post and interact with other users' music tastes

## Code Structure 🗂️

### Backend

- `controllers/`: Business logic
- `models/`: Database models
- `routes/`: API routes
- `middlewares/`: Authentication middlewares
- `services/`: External services (Spotify)

### Frontend

- `lib/screens/`: App screens
- `lib/services/`: Services and API calls
- `lib/widgets/`: Reusable components
- `lib/models/`: Data models

## Important Notes ⚠️

- Make sure you have a Spotify Developer account and set up the credentials properly
- The backend must be running before starting the frontend
- For local development, use your local IP address instead of `localhost` on the frontend

## License 📄

This project is licensed under the [MIT License](./LICENSE).

For more details about the implementation, check the documentation in the respective `backend/` and `frontend/` directories.
