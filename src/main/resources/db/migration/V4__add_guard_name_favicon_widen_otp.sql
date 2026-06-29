-- =============================================================================
-- V4__add_guard_name_favicon_widen_otp.sql
-- Align SpringAdmin schema with NodeAdmin standard:
--   1. roles.guard_name  (missing from V1)
--   2. settings.favicon  (missing from V1)
--   3. users.password_otp widened to VARCHAR(255) for bcrypt hashes (MySQL only)
--      SQLite ignores VARCHAR length constraints so no ALTER needed there.
-- =============================================================================

-- 1. Add guard_name to roles (compatible with MySQL, PostgreSQL, SQLite)
ALTER TABLE roles ADD COLUMN guard_name VARCHAR(20) NOT NULL DEFAULT 'web';

-- 2. Add favicon to settings (compatible with MySQL, PostgreSQL, SQLite)
ALTER TABLE settings ADD COLUMN favicon VARCHAR(255) NULL;

-- 3. Widen password_otp for bcrypt storage (bcrypt = 60 chars; old = VARCHAR(50))
--    MySQL/PostgreSQL: run the line below.
--    SQLite: VARCHAR length is advisory only — skip this if running SQLite.
-- ALTER TABLE users MODIFY COLUMN password_otp VARCHAR(255) NULL;  -- MySQL
-- ALTER TABLE users ALTER COLUMN password_otp TYPE VARCHAR(255);   -- PostgreSQL
