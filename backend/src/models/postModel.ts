// postModel.ts
import { Sequelize, DataTypes, Model, Optional } from 'sequelize';
import User from './userModel';
import dotenv from 'dotenv';

dotenv.config();

const sequelize = new Sequelize(process.env.DATABASE_URL as string);

// Define PostAttributes to represent the structure of a post
interface PostAttributes {
    post_id: string;
    user_id: string;
    content: string;
    type: 'song' | 'album' | 'artist';
    reference_id: string;
    createdAt?: Date;
    updatedAt?: Date;
}

// Allow partial post creation, excluding 'post_id'
interface PostCreationAttributes extends Optional<PostAttributes, 'post_id'> {}

// Define the Post model
class Post extends Model<PostAttributes, PostCreationAttributes> implements PostAttributes {
    public post_id!: string;
    public user_id!: string;
    public content!: string;
    public type!: 'song' | 'album' | 'artist';
    public reference_id!: string;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

// Initialize the Post model
Post.init(
    {
        post_id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        user_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: {
                model: User,
                key: 'user_id',
            },
        },
        content: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        type: {
            type: DataTypes.ENUM('song', 'album', 'artist'),
            allowNull: false,
        },
        reference_id: {
            type: DataTypes.STRING,
            allowNull: false,
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
        tableName: 'posts',
        timestamps: true,
    }
);

export default Post;
