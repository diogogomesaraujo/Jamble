-- 002_create_oauth_tokens_table.sql
CREATE TABLE oauth_tokens (
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    spotify_access_token TEXT NOT NULL,
    spotify_refresh_token TEXT,
    token_type VARCHAR(50),
    expires_in INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
