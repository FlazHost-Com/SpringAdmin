-- =============================================================================
-- V1__create_initial_schema.sql
-- Canonical schema shared by NodeAdmin / GoAdmin / SpringAdmin.
-- Rules:
--   * id = VARCHAR(36) NOT NULL PRIMARY KEY  (no AUTO_INCREMENT)
--   * status = VARCHAR(20) NOT NULL DEFAULT 'Active'  (no ENUM)
--   * guard_name = VARCHAR(20) NOT NULL DEFAULT 'web'
--   * No ON UPDATE CURRENT_TIMESTAMP — handled in Java @PreUpdate
--   * permissions.name is NON-UNIQUE (only INDEX)
--   * join tables have composite PKs + FK ON DELETE CASCADE
-- Compatible with: MySQL 8+, PostgreSQL 14+, SQLite 3.x
-- =============================================================================

-- ---------------------------------------------------------------------------
-- roles
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
    id          VARCHAR(36)  NOT NULL,
    name        VARCHAR(255) NOT NULL,
    status      VARCHAR(20)  NOT NULL DEFAULT 'Active',
    `desc`      VARCHAR(255) NULL,
    created_by  VARCHAR(36)  NULL,
    updated_by  VARCHAR(36)  NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX IF NOT EXISTS roles__name   ON roles (name);
CREATE        INDEX IF NOT EXISTS roles__status ON roles (status);

-- ---------------------------------------------------------------------------
-- permissions
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS permissions (
    id          VARCHAR(36)  NOT NULL,
    name        VARCHAR(255) NOT NULL,
    guard_name  VARCHAR(20)  NOT NULL DEFAULT 'web',
    method      VARCHAR(255) NULL,
    status      VARCHAR(20)  NOT NULL DEFAULT 'Active',
    `desc`      VARCHAR(255) NULL,
    created_by  VARCHAR(36)  NULL,
    updated_by  VARCHAR(36)  NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- permissions.name is intentionally NON-UNIQUE (same action may exist per guard)
CREATE INDEX IF NOT EXISTS permissions__name   ON permissions (name);
CREATE INDEX IF NOT EXISTS permissions__method ON permissions (method);
CREATE INDEX IF NOT EXISTS permissions__status ON permissions (status);
CREATE INDEX IF NOT EXISTS permissions__guard  ON permissions (guard_name);

-- ---------------------------------------------------------------------------
-- users
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id                   VARCHAR(36)  NOT NULL,
    code                 VARCHAR(20)  NOT NULL,
    name                 VARCHAR(50)  NOT NULL,
    phone                VARCHAR(15)  NULL,
    email                VARCHAR(255) NOT NULL,
    email_verified_at    TIMESTAMP    NULL,
    password             VARCHAR(255) NOT NULL,
    password_otp         VARCHAR(50)  NULL,
    password_otp_expires BIGINT       NULL,
    status               VARCHAR(20)  NOT NULL DEFAULT 'Active',
    picture              VARCHAR(255) NULL,
    blocked              BOOLEAN      NOT NULL DEFAULT FALSE,
    blocked_reason       VARCHAR(255) NULL,
    timezone             VARCHAR(255) NOT NULL DEFAULT 'UTC',
    created_by           VARCHAR(36)  NULL,
    updated_by           VARCHAR(36)  NULL,
    created_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX IF NOT EXISTS users__code     ON users (code);
CREATE UNIQUE INDEX IF NOT EXISTS users__email    ON users (email);
CREATE        INDEX IF NOT EXISTS users__name     ON users (name);
CREATE        INDEX IF NOT EXISTS users__phone    ON users (phone);
CREATE        INDEX IF NOT EXISTS users__status   ON users (status);
CREATE        INDEX IF NOT EXISTS users__timezone ON users (timezone);
CREATE        INDEX IF NOT EXISTS users__blocked  ON users (blocked);

-- ---------------------------------------------------------------------------
-- settings
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS settings (
    id           VARCHAR(36)  NOT NULL,
    initial      VARCHAR(255) NULL,
    name         VARCHAR(255) NULL,
    description  TEXT         NULL,
    icon         VARCHAR(255) NULL,
    logo         VARCHAR(255) NULL,
    login_image  VARCHAR(255) NULL,
    phone        VARCHAR(255) NULL,
    address      VARCHAR(255) NULL,
    email        VARCHAR(255) NULL,
    copyright    VARCHAR(255) NULL,
    theme        VARCHAR(20)  NOT NULL DEFAULT 'Blue',
    fe_template  VARCHAR(80)  NOT NULL DEFAULT 'agency-consulting-002-creative-agency',
    created_by   VARCHAR(36)  NULL,
    updated_by   VARCHAR(36)  NULL,
    created_at   TIMESTAMP    NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS settings__initial       ON settings (initial);
CREATE INDEX IF NOT EXISTS settings__name          ON settings (name);
CREATE INDEX IF NOT EXISTS settings__icon          ON settings (icon);
CREATE INDEX IF NOT EXISTS settings__logo          ON settings (logo);
CREATE INDEX IF NOT EXISTS settings__login_image   ON settings (login_image);
CREATE INDEX IF NOT EXISTS settings__phone         ON settings (phone);
CREATE INDEX IF NOT EXISTS settings__setting_email ON settings (email);
CREATE INDEX IF NOT EXISTS settings__copyright     ON settings (copyright);

-- ---------------------------------------------------------------------------
-- roles_permissions  (join table — composite PK + FK ON DELETE CASCADE)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles_permissions (
    role_id       VARCHAR(36) NOT NULL,
    permission_id VARCHAR(36) NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_rp_role       FOREIGN KEY (role_id)       REFERENCES roles       (id) ON DELETE CASCADE,
    CONSTRAINT fk_rp_permission FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- users_roles  (join table — composite PK + FK ON DELETE CASCADE)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users_roles (
    user_id VARCHAR(36) NOT NULL,
    role_id VARCHAR(36) NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
);
