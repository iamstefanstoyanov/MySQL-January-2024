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

