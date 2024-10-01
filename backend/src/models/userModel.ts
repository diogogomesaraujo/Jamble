import { Sequelize, DataTypes, Model, Optional } from 'sequelize';
import dotenv from 'dotenv';

dotenv.config();

const sequelize = new Sequelize(process.env.DATABASE_URL as string);

interface UserAttributes {
    user_id: string;
    username: string | null;
    email: string;
    password?: string;
    is_spotify_account: boolean;
    small_description?: string | null;
    user_image?: string | null;
    user_wallpaper?: string | null;
    favorite_albums?: string[] | null;
    created_at?: Date;
    updated_at?: Date;
}

interface UserCreationAttributes extends Optional<UserAttributes, 'user_id'> {}

class User extends Model<UserAttributes, UserCreationAttributes> implements UserAttributes {
    public user_id!: string;
    public username!: string | null;
    public email!: string;
    public password?: string;
    public is_spotify_account!: boolean;
    public small_description?: string | null;
    public user_image?: string | null;
    public user_wallpaper?: string | null;
    public favorite_albums?: string[] | null;
    public readonly created_at!: Date;
    public readonly updated_at!: Date;
}

User.init(
    {
        user_id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        username: {
            type: DataTypes.STRING,
            allowNull: true,  // Initially null for Spotify users
        },
        email: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
        },
        password: {
            type: DataTypes.STRING,  // Nullable for Spotify users
        },
        is_spotify_account: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
        },
        small_description: {
            type: DataTypes.STRING,  // Short user bio/description
            allowNull: true,
        },
        user_image: {
            type: DataTypes.STRING,  // URL or path to user profile image
            allowNull: true,
        },
        user_wallpaper: {
            type: DataTypes.STRING,  // URL or path to user wallpaper
            allowNull: true,
        },
        favorite_albums: {
            type: DataTypes.ARRAY(DataTypes.STRING),  // Array to store Spotify album IDs or names
            allowNull: true,
            validate: {
                len: [0, 5],  // Limit to 5 favorite albums
            },
        },
        created_at: {
            type: DataTypes.DATE,
            defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
        },
        updated_at: {
            type: DataTypes.DATE,
            defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
        },
    },
    {
        sequelize,
        tableName: 'users',
        timestamps: false,  // Sequelize will manage created_at and updated_at
    }
);

export default User;
