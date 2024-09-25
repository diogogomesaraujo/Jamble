-- 003_alter_users_add_columns.sql
ALTER TABLE users
    ADD COLUMN post TEXT[],
    ADD COLUMN top_albums TEXT[],
    ADD COLUMN list TEXT[],
    ADD COLUMN follower UUID[],
    ADD COLUMN following UUID[];
