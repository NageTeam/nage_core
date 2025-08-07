CREATE TABLE IF NOT EXISTS `users` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    discord VARCHAR(50),
    steam_name VARCHAR(100),
    steam_id VARCHAR(50),
    license VARCHAR(50) NOT NULL UNIQUE,
    fivem_id VARCHAR(50),
    money INT DEFAULT 0,
    `rank` VARCHAR(50) DEFAULT 'user',
    last_connected VARCHAR(50) DEFAULT 'Never'
);
