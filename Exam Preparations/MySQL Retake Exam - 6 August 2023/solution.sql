CREATE DATABASE real_estate_db;

CREATE TABLE cities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE property_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(40) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE properties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(80) NOT NULL UNIQUE,
    price DECIMAL(19, 2) NOT NULL,
    area DECIMAL(19, 2),
    property_type_id INT,
    city_id INT,
    FOREIGN KEY (property_type_id) REFERENCES property_types(id),
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE agents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE buyers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE property_offers (
    property_id INT NOT NULL,
    agent_id INT NOT NULL,
    price DECIMAL(19, 2) NOT NULL,
    offer_datetime DATETIME,
    FOREIGN KEY (property_id) REFERENCES properties(id),
    FOREIGN KEY (agent_id) REFERENCES agents(id)
);

CREATE TABLE property_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    buyer_id INT NOT NULL,
    transaction_date DATE,
    bank_name VARCHAR(30),
    iban VARCHAR(40) UNIQUE,
    is_successful BOOLEAN,
    FOREIGN KEY (property_id) REFERENCES properties(id),
    FOREIGN KEY (buyer_id) REFERENCES buyers(id)
);

INSERT INTO property_transactions (property_id, buyer_id, transaction_date, bank_name, iban, is_successful)
SELECT
    po.agent_id + DAY(po.offer_datetime) AS property_id,
    po.agent_id + MONTH(po.offer_datetime) AS buyer_id,
    DATE(po.offer_datetime) AS transaction_date,
    CONCAT('Bank ', po.agent_id) AS bank_name,
    CONCAT('BG', po.price, po.agent_id) AS iban,
    true AS is_successful
FROM property_offers po
WHERE po.agent_id <= 2;

UPDATE properties
SET price = price - 50000
WHERE price >= 800000;

DELETE FROM property_transactions
WHERE is_successful <> true;

SELECT
    id,
    first_name,
    last_name,
    phone,
    email,
    city_id
FROM agents
ORDER BY city_id DESC, phone DESC;

SELECT
    property_id,
    agent_id,
    price,
    offer_datetime
FROM property_offers
WHERE YEAR(offer_datetime) = 2021
ORDER BY price ASC
LIMIT 10;

SELECT
    SUBSTRING(address, 1, 6) AS agent_name,
    LENGTH(address) * 5430 AS price
FROM properties
WHERE id NOT IN (SELECT DISTINCT property_id FROM property_offers)
ORDER BY agent_name DESC, price DESC;

SELECT
    bank_name,
    COUNT(DISTINCT iban) AS count
FROM property_transactions
WHERE iban IS NOT NULL
GROUP BY bank_name
HAVING count >= 9
ORDER BY count DESC, bank_name ASC;

SELECT
    address,
    area,
    CASE
        WHEN area <= 100 THEN 'small'
        WHEN area <= 200 THEN 'medium'
        WHEN area <= 500 THEN 'large'
        ELSE 'extra large'
    END AS size
FROM properties
ORDER BY area ASC, address DESC;

DELIMITER //

CREATE FUNCTION udf_offers_from_city_name(cityName VARCHAR(50)) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE totalOffers INT;
    
    SELECT COUNT(*) INTO totalOffers
    FROM property_offers po
    JOIN properties p ON po.property_id = p.id
    JOIN cities c ON p.city_id = c.id
    WHERE c.name = cityName;

    RETURN totalOffers;
END //

DELIMITER ;

SELECT udf_offers_from_city_name('Vienna') AS 'offers_count';

DELIMITER //

CREATE PROCEDURE udp_special_offer(agent_first_name VARCHAR(50))
BEGIN
    DECLARE agent_id INT;

    SELECT id INTO agent_id
    FROM agents
    WHERE first_name = agent_first_name;

    UPDATE property_offers
    SET price = price * 0.9
    WHERE agent_id = agent_id;
END //

DELIMITER ;

CALL udp_special_offer('Hans');