CREATE DATABASE gamebar;

CREATE TABLE `gamebar`.`employees`(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL
);
CREATE TABLE `gamebar`.`categories`(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL
);
CREATE TABLE `gamebar`.`products`(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL,
category_id INT NOT NULL
);

INSERT INTO employees(first_name,last_name) VALUES("Pesho","Pesho");
INSERT INTO employees(first_name,last_name) VALUES("Gosho","Gosho");
INSERT INTO employees(first_name,last_name) VALUES("Ivan","Ivan");

ALTER TABLE employees
ADD COLUMN middle_name VARCHAR(50) NOT NULL;

ALTER TABLE `products`
ADD CONSTRAINT `fk_products_categories`
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`);

ALTER TABLE `employees`
MODIFY COLUMN `middle_name` VARCHAR(100);