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

CREATE TABLE `users` (
    `id` INT NOT NULL UNIQUE AUTO_INCREMENT,
    `username` VARCHAR(30) UNIQUE NOT NULL,
    `password` VARCHAR(26) NOT NULL,
    `profile_picture` BLOB,
    `last_login_time` DATETIME,
    `is_deleted` BOOLEAN,
    CONSTRAINT `pk_users` PRIMARY KEY (`id`)
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

CREATE DATABASE movies;

CREATE TABLE `directors` (
    `id` INT AUTO_INCREMENT,
    `director_name` VARCHAR(50) NOT NULL,
    `notes` TEXT,
    CONSTRAINT `pk_directors` PRIMARY KEY (`id`)
);

CREATE TABLE `genres` (
    `id` INT AUTO_INCREMENT,
    `genre_name` VARCHAR(50) NOT NULL,
    `notes` TEXT,
    CONSTRAINT `pk_genres` PRIMARY KEY (`id`)
);
CREATE TABLE `categories` (
    `id` INT AUTO_INCREMENT,
    `category_name` VARCHAR(50) NOT NULL,
    `notes` TEXT,
    CONSTRAINT `pk_categories` PRIMARY KEY (`id`)
);
CREATE TABLE `movies` (
    `id` INT AUTO_INCREMENT,
    `title` VARCHAR(50) NOT NULL,
    `director_id` INT,
    `copyright_year` YEAR,
    `length` INT,
    `genre_id` INT,
    `category_id` INT,
    `rating` DECIMAL(5 , 2 ),
    `notes` TEXT,
    CONSTRAINT `pk_movies` PRIMARY KEY (`id`)
);
INSERT INTO `directors`(`director_name`, `notes`)
VALUES 
('Name1', 'NOTES......'),
('Name2', 'NOTES......'),
('Name3', 'NOTES......'),
('Name4', 'NOTES......'),
('Name5', 'NOTES......');

INSERT INTO `genres`(`genre_name`, `notes`)
VALUES 
('Name1', 'NOTES......'),
('Name2', 'NOTES......'),
('Name3', 'NOTES......'),
('Name4', 'NOTES......'),
('Name5', 'NOTES......');

INSERT INTO `categories`(`category_name`, `notes`)
VALUES 
('Name1', 'NOTES......'),
('Name2', 'NOTES......'),
('Name3', 'NOTES......'),
('Name4', 'NOTES......'),
('Name5', 'NOTES......');

INSERT INTO `movies` (`title`)
VALUES 
('Movie1'),
('Movie2'),
('Movie3'),
('Movie4'),
('Movie5');

CREATE DATABASE car_rental;

CREATE TABLE `categories` (
    `id` INT AUTO_INCREMENT,
    `category` VARCHAR(50),
    `daily_rate` DOUBLE,
    `weekly_rate` DOUBLE,
    `monthly_rate` DOUBLE,
    `weekend_rate` DOUBLE,
    CONSTRAINT `pk_categories` PRIMARY KEY (`id`)
);

INSERT INTO `categories` (`category`) VALUES
('category1'),
('category2'),
('category3'); 

CREATE TABLE `cars` (
    `id` INT AUTO_INCREMENT,
    `plate_number` VARCHAR(20) UNIQUE,
    `make` VARCHAR(20),
    `model` VARCHAR(20),
    `car_year` YEAR,
    `category_id` INT,
    `doors` INT,
    `picture` BLOB,
    `car_condition` VARCHAR(50),
    `available` BOOLEAN,
    CONSTRAINT `pk_cars` PRIMARY KEY (`id`)
);

INSERT INTO `cars` (`plate_number`)
VALUES 
('CA1313SH'),
('CA1213SH'),
('CA4313SH');

CREATE TABLE `employees` (
    `id` INT AUTO_INCREMENT,
    `first_name` VARCHAR(30),
    `last_name` VARCHAR(30),
    `title` VARCHAR(30),
    `notes` TEXT,
    CONSTRAINT `pk_employees` PRIMARY KEY (`id`)
);
INSERT INTO `employees` (`first_name`, `last_name`)
VALUES 
('Stefan', 'Stefan'),
('Stasi', 'Stasi'),
('Misho', 'TestName3Misho');

CREATE TABLE `customers` (
    `id` INT AUTO_INCREMENT,
    `driver_licence_number` INT UNIQUE,
    `full_name` VARCHAR(80),
    `address` VARCHAR(80),
    `city` VARCHAR(20),
    `zip_code` VARCHAR(10),
    `notes` TEXT,
    CONSTRAINT `pk_customers` PRIMARY KEY (`id`)
);

INSERT INTO `customers` (`driver_licence_number`, `full_name`)
VALUES 
('789453215', 'Stefan'),
('789222215', 'Stasi'),
('783333315', 'Misho');

CREATE TABLE `rental_orders` (
    `id` INT AUTO_INCREMENT,
    `employee_id` INT,
    `customer_id` INT,
    `car_id` INT,
    `car_condition` VARCHAR(30),
    `tank_level` VARCHAR(30),
    `kilometrage_start` INT,
    `kilometrage_end` INT,
    `total_kilometrage` INT,
    `start_date` DATE,
    `end_date` DATE,
    `total_days` INT,
    `rate_applied` DOUBLE,
    `tax_rate` DOUBLE,
    `order_status` BOOLEAN,
    `notes` TEXT,
    CONSTRAINT `pk_rental_orders` PRIMARY KEY (`id`)
);

INSERT INTO `rental_orders` (`employee_id`, `customer_id`)
VALUES 
(1, 2),
(2, 3),
(3, 1);

CREATE DATABASE `soft_uni`;

CREATE TABLE `towns` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL,
    CONSTRAINT `pk_towns` PRIMARY KEY (`id`)
);
CREATE TABLE `addresses` (
    `id` INT AUTO_INCREMENT,
    `address_text` VARCHAR(45) NOT NULL,
    `town_id` INT,
    CONSTRAINT `pk_addresses` PRIMARY KEY (`id`),
    CONSTRAINT `fk_addresses_towns` FOREIGN KEY (`town_id`)
        REFERENCES `towns` (`id`)
);
CREATE TABLE `departments` (
    `id` INT AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL,
    CONSTRAINT `pk_departments` PRIMARY KEY (`id`)
);
CREATE TABLE `employees` (
    `id` INT AUTO_INCREMENT,
    `first_name` VARCHAR(30) NOT NULL,
    `middle_name` VARCHAR(30),
    `last_name` VARCHAR(30) NOT NULL,
    `job_title` VARCHAR(30),
    `department_id` INT NOT NULL,
    `hire_date` DATE,
    `salary` DECIMAL(19 , 2 ),
    `address_id` INT,
    CONSTRAINT `pk_employees` PRIMARY KEY (`id`),
    CONSTRAINT `fk_employees_departments` FOREIGN KEY (`department_id`)
        REFERENCES `departments` (`id`),
    CONSTRAINT `fk_employees_addresses` FOREIGN KEY (`address_id`)
        REFERENCES `addresses` (`id`)
);

INSERT INTO `departments` (`name`)
VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance');

INSERT INTO `towns` (`name`)
VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas');

INSERT INTO `employees` (`first_name`, `middle_name`, `last_name`, `job_title`, `department_id`, `hire_date`,`salary`)
VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
('Georgi', 'Terziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88);

SELECT * FROM `towns`;
SELECT * FROM `departments`;
SELECT * FROM `employees`;

SELECT * FROM `towns` ORDER BY `name`;
SELECT * FROM `departments` ORDER BY `name`;
SELECT * FROM `employees` ORDER BY `salary` DESC;

SELECT `name` FROM `towns` ORDER BY `name`;
SELECT `name` FROM `departments` ORDER BY `name`;
SELECT `first_name`, `last_name`, `job_title`, `salary` FROM `employees` ORDER BY `salary` DESC;

UPDATE `employees`
SET `salary` = `salary` * 1.1; 

SELECT `salary` FROM `employees`;