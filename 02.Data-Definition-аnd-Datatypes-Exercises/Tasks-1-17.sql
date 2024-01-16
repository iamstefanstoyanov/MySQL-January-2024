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

