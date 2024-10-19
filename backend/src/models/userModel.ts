import { Sequelize, DataTypes, Model, Optional } from 'sequelize';
import dotenv from 'dotenv';

dotenv.config();

const sequelize = new Sequelize(process.env.DATABASE_URL as string);

// UserAttributes interface to represent the structure of a user
interface UserAttributes {
    user_id: string;
    username: string | null;
    email: string;
    password?: string;
    is_spotify_account: boolean;
    spotify_id?: string | null;  // Spotify ID for users logging in via Spotify
    spotify_access_token?: string | null;  // Spotify access token
    spotify_refresh_token?: string | null;  // Spotify refresh token
    small_description?: string | null;
    user_image?: string | null;
    user_wallpaper?: string | null;
    favorite_albums?: string[] | null;
    createdAt?: Date;  // Use camelCase for consistency
    updatedAt?: Date;
}

// Allow partial user creation, excluding 'user_id'
interface UserCreationAttributes extends Optional<UserAttributes, 'user_id'> {}

// Define the User model
class User extends Model<UserAttributes, UserCreationAttributes> implements UserAttributes {
    public user_id!: string;
    public username!: string | null;
    public email!: string;
    public password?: string;
    public is_spotify_account!: boolean;
    public spotify_id?: string | null;
    public spotify_access_token?: string | null;
    public spotify_refresh_token?: string | null;
    public small_description?: string | null;
    public user_image?: string | null;
    public user_wallpaper?: string | null;
    public favorite_albums?: string[] | null;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

// Initialize the User model
User.init(
    {
        user_id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,  // Automatically generates UUID
            primaryKey: true,
        },
        username: {
            type: DataTypes.STRING,
            allowNull: true,  // Spotify users may not have a username initially
        },
        email: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,  // Enforce unique emails
            validate: {
                isEmail: true,  // Ensure valid email format
            },
        },
        password: {
            type: DataTypes.STRING,
            allowNull: true,  // Password can be null for Spotify users
        },
        is_spotify_account: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
        },
        spotify_id: {
            type: DataTypes.STRING,
            allowNull: true,
            unique: true,  // Enforce unique Spotify ID
        },
        spotify_access_token: {
            type: DataTypes.STRING,
            allowNull: true,  // Access token to interact with Spotify API
        },
        spotify_refresh_token: {
            type: DataTypes.STRING,
            allowNull: true,  // Refresh token to get new access tokens
        },
        small_description: {
            type: DataTypes.STRING,
            allowNull: true,
            validate: {
                len: [0, 255],  // Limit description length to 255 characters
            },
        },
        user_image: {
            type: DataTypes.STRING,
            allowNull: true,  // URL or base64 image for the user's avatar
            validate: {
                isUrl: true,  // Ensure it's a valid URL (if using URL)
            },
        },
        user_wallpaper: {
            type: DataTypes.STRING,
            allowNull: true,  // URL or base64 image for user wallpaper
            validate: {
                isUrl: true,  // Ensure it's a valid URL (if using URL)
            },
        },
        favorite_albums: {
            type: DataTypes.ARRAY(DataTypes.STRING),
            allowNull: true,  // List of favorite albums (limited to 5)
            validate: {
                len: [0, 5],  // Limit to 5 favorite albums
            },
        },
        createdAt: {
            type: DataTypes.DATE,
            defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
        },
        updatedAt: {
            type: DataTypes.DATE,
            defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
        },
    },
    {
        sequelize,
        tableName: 'users',
        timestamps: true,  // Automatically handle `createdAt` and `updatedAt`
    }
);

export default User;
