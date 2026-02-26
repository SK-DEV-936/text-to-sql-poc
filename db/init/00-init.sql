-- Minimal schema for the Boons text-to-SQL POC.
-- We use ORDER_SCHEMAS.sql for the main tables.

-- Read-only user for the agent (matches defaults in config.py).
CREATE USER IF NOT EXISTS 'boons_readonly'@'%' IDENTIFIED BY 'change-me';
GRANT SELECT ON boons.* TO 'boons_readonly'@'%';
FLUSH PRIVILEGES;

