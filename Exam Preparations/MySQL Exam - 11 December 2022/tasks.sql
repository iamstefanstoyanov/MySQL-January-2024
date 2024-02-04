CREATE TABLE countries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    description TEXT,
    currency VARCHAR(5) NOT NULL
);
CREATE TABLE airplanes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(50) NOT NULL UNIQUE,
    passengers_capacity INT NOT NULL,
    tank_capacity DECIMAL(19,2) NOT NULL,
    cost DECIMAL(19,2) NOT NULL
);
CREATE TABLE passengers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES countries(id)
);
CREATE TABLE flights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flight_code VARCHAR(30) NOT NULL UNIQUE,
    departure_country INT NOT NULL,
    destination_country INT NOT NULL,
    airplane_id INT NOT NULL,
    has_delay BOOLEAN,
    departure DATETIME,
    FOREIGN KEY (departure_country) REFERENCES countries(id),
    FOREIGN KEY (destination_country) REFERENCES countries(id),
    FOREIGN KEY (airplane_id) REFERENCES airplanes(id)
);
CREATE TABLE flights_passengers (
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES flights(id),
    FOREIGN KEY (passenger_id) REFERENCES passengers(id)
);

INSERT INTO airplanes (model, passengers_capacity, tank_capacity, cost)
SELECT 
    CONCAT(REVERSE(p.first_name), '797') AS model,
    LENGTH(p.last_name) * 17 AS passengers_capacity,
    p.id * 790 AS tank_capacity,
    LENGTH(p.first_name) * 50.6 AS cost
FROM passengers p
WHERE p.id <= 5;

UPDATE flights
SET airplane_id = airplane_id + 1
WHERE departure_country = (SELECT id FROM countries WHERE name = 'Armenia');

DELETE FROM flights
WHERE id NOT IN (SELECT flight_id FROM flights_passengers);

SELECT
    id,
    model,
    passengers_capacity,
    tank_capacity,
    cost
FROM airplanes
ORDER BY cost DESC, id DESC;

SELECT
    flight_code,
    departure_country,
    airplane_id,
    departure
FROM flights
WHERE YEAR(departure) = 2022
ORDER BY airplane_id ASC, flight_code ASC
LIMIT 20;

SELECT
    CONCAT(UPPER(SUBSTRING(p.last_name, 1, 2)), p.country_id) AS flight_code,
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    p.country_id
FROM passengers p
LEFT JOIN flights_passengers fp ON p.id = fp.passenger_id
WHERE fp.passenger_id IS NULL
ORDER BY p.country_id ASC;

SELECT
    c.name AS country,
    c.currency,
    COUNT(fp.passenger_id) AS booked_tickets
FROM countries c
JOIN flights f ON c.id = f.destination_country
LEFT JOIN flights_passengers fp ON f.id = fp.flight_id
GROUP BY c.id, c.name, c.currency
HAVING booked_tickets >= 20
ORDER BY booked_tickets DESC;

SELECT
    flight_code,
    departure,
    CASE
        WHEN HOUR(departure) >= 5 AND HOUR(departure) < 12 THEN 'Morning'
        WHEN HOUR(departure) >= 12 AND HOUR(departure) < 17 THEN 'Afternoon'
        WHEN HOUR(departure) >= 17 AND HOUR(departure) < 21 THEN 'Evening'
        ELSE 'Night'
    END AS day_part
FROM flights
ORDER BY flight_code DESC;

DELIMITER //

CREATE FUNCTION `udf_count_flights_from_country`(`country` VARCHAR(50)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE flights_count INT;

    SELECT COUNT(*) INTO flights_count
    FROM flights f
    JOIN countries c ON f.departure_country = c.id
    WHERE c.name = country;

    RETURN flights_count;
END //

DELIMITER ;

SELECT udf_count_flights_from_country('Brazil') AS 'flights_count';

DELIMITER //

CREATE PROCEDURE udp_delay_flight(`code` VARCHAR(50))
BEGIN
    DECLARE has_delay_before INT;
    DECLARE departure_before DATETIME;
    DECLARE departure_after DATETIME;

    SELECT has_delay, departure INTO has_delay_before, departure_before
    FROM flights
    WHERE flight_code = `code`;

    UPDATE flights
    SET has_delay = 1, departure = departure_before + INTERVAL 30 MINUTE
    WHERE flight_code = `code`;
    
END //

DELIMITER ;

CALL udp_delay_flight('ZP-782');