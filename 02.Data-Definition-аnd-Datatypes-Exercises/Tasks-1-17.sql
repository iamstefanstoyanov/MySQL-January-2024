CREATE DATABASE  `minions`;

CREATE TABLE minions (
    id INT AUTO_INCREMENT,
    name VARCHAR(80),
    age INT,
    CONSTRAINT pk_id
    PRIMARY KEY (id)
);
CREATE TABLE towns (
    town_id INT AUTO_INCREMENT,
    name VARCHAR(80),
    CONSTRAINT pk_town_id
    PRIMARY KEY (town_id)
);
ALTER TABLE towns
DROP COLUMN town_id;

ALTER TABLE towns
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE minions
ADD COLUMN town_id INT;

ALTER TABLE minions
ADD CONSTRAINT fk_town_id FOREIGN KEY (town_id) REFERENCES towns(id);

INSERT INTO towns(name) VALUES 
('Sofia'),
('Plovdiv'),
('Varna');

INSERT INTO minions(name,age,town_id) VALUES 
('Kevin', 22, 1),
('Bob', 15, 3),
('Steward', NULL, 2);

TRUNCATE `minions`;

DROP TABLE `minions`;
DROP TABLE `towns`; 

CREATE TABLE `people` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(200) NOT NULL,
    `picture` BLOB,
    `height` DOUBLE(5 , 2 ),
    `weight` DOUBLE(5 , 2 ),
    `gender` CHAR(1) NOT NULL,
    `birthdate` DATE NOT NULL,
    `biography` TEXT,
    CONSTRAINT `pk_people` PRIMARY KEY (`id`)
);
INSERT INTO `people` (`name`, `gender`, `birthdate`)
VALUES 
('Ivan', 'M', DATE(NOW())),
('Pecho', 'M', DATE(NOW())),
('Gosho', 'M', DATE(NOW())),
('Stefan', 'M', DATE(NOW())),
('Stasi', 'F', DATE(NOW()));

CREATE TABLE `users`(
`id` INT NOT NULL UNIQUE AUTO_INCREMENT,
`username` VARCHAR(30) UNIQUE NOT NULL,
`password` VARCHAR(26) NOT NULL,
`profile_picture` BLOB,
`last_login_time` DATETIME,
`is_deleted` BOOLEAN,
CONSTRAINT `pk_users`
PRIMARY KEY (`id`)
);
INSERT INTO `users` (`username`, `password`)
VALUES 
('User1', 'OK'),
('User2', 'OK'),
('User3', 'OK'),
('User4', 'OK'),
('User5', 'OK');

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT `pk_users`
PRIMARY KEY(`id`,`username`);

ALTER TABLE `users`
CHANGE COLUMN `last_login_time` `last_login_time` DATETIME DEFAULT NOW();

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT `pk_users`
PRIMARY KEY (`id`),
-- CHANGE COLUMN `username` `username` VARCHAR(30) NOT NULL UNIQUE,
ADD CONSTRAINT `uk_users`
UNIQUE (`id`);

