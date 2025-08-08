CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `discord` VARCHAR(50) DEFAULT NULL,
    `steam_name` VARCHAR(100) DEFAULT NULL,
    `steam_id` VARCHAR(50) DEFAULT NULL,
    `license` VARCHAR(50) NOT NULL UNIQUE,
    `fivem_id` VARCHAR(50) DEFAULT NULL,
    `money` INT DEFAULT 0,
    `rank` VARCHAR(50) DEFAULT 'user',
    `last_connected` VARCHAR(50) DEFAULT 'Never',
    `total_played` INT DEFAULT 0
);
