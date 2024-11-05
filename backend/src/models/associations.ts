// associations.ts
import User from './userModel';
import Post from './postModel';

export function setupAssociations() {
    User.hasMany(Post, { foreignKey: 'user_id', as: 'posts' });
    Post.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
}
