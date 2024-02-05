CREATE DATABASE softuni_imdb;

CREATE TABLE countries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    continent VARCHAR(30) NOT NULL,
    currency VARCHAR(5) NOT NULL
);

CREATE TABLE genres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE actors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birthdate DATE NOT NULL,
    height INT,
    awards INT,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES countries(id)
);

CREATE TABLE movies_additional_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rating DECIMAL(10,2) NOT NULL,
    runtime INT NOT NULL,
    picture_url VARCHAR(80) NOT NULL,
    budget DECIMAL(10,2),
    release_date DATE NOT NULL,
    has_subtitles BOOLEAN,
    description TEXT
);

CREATE TABLE movies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(70) NOT NULL UNIQUE,
    country_id INT NOT NULL,
    movie_info_id INT NOT NULL UNIQUE ,
    FOREIGN KEY (country_id) REFERENCES countries(id),
    FOREIGN KEY (movie_info_id) REFERENCES movies_additional_info(id)
);

CREATE TABLE movies_actors (
    movie_id INT,
    actor_id INT,
    FOREIGN KEY (movie_id) REFERENCES movies(id),
    FOREIGN KEY (actor_id) REFERENCES actors(id)
);

CREATE TABLE genres_movies (
    genre_id INT,
    movie_id INT,
    FOREIGN KEY (genre_id) REFERENCES genres(id),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

INSERT INTO actors (first_name, last_name, birthdate, height, awards, country_id)
    (SELECT REVERSE(first_name),
            REVERSE(last_name),
            DATE_ADD(birthdate, INTERVAL -2 DAY),
            height + 10,
            country_id,
            (SELECT id FROM countries WHERE name = 'Armenia')

     FROM actors a
              JOIN countries c ON a.country_id = c.id
     WHERE a.id <= 10);
     
UPDATE movies_additional_info
SET runtime = runtime - 10
WHERE id >= 15 AND id <= 25;

DELETE FROM countries
WHERE id NOT IN (SELECT DISTINCT country_id FROM movies);

SELECT id, name, continent, currency
FROM countries
ORDER BY currency DESC, id;

SELECT mai.id, m.title, mai.runtime, mai.budget, mai.release_date
FROM movies_additional_info mai
JOIN movies m ON mai.id = m.movie_info_id
WHERE YEAR(mai.release_date) BETWEEN 1996 AND 1999
ORDER BY mai.runtime, mai.id
LIMIT 20;

SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    CONCAT(REVERSE(last_name),
            CHAR_LENGTH(last_name),
            '@cast.com') AS email,
    2022 - YEAR(birthdate) AS age,
    height
FROM
    actors
WHERE
    id NOT IN (SELECT DISTINCT
            actor_id
        FROM
            movies_actors)
ORDER BY height ASC;

SELECT 
    c.name AS country_name, COUNT(m.id) AS number_of_movies
FROM
    countries c
        JOIN
    movies m ON c.id = m.country_id
GROUP BY c.id , c.name
HAVING number_of_movies >= 7
ORDER BY country_name DESC;

SELECT
    m.title,
    CASE
        WHEN mai.rating <= 4 THEN 'poor'
        WHEN mai.rating <= 7 THEN 'good'
        ELSE 'excellent'
    END AS rating_category,
    CASE
        WHEN mai.has_subtitles THEN 'english'
        ELSE '-'
    END AS subtitles,
    mai.budget
FROM
    movies_additional_info mai
JOIN
    movies m ON m.movie_info_id = mai.id
ORDER BY
    mai.budget DESC;
    
DELIMITER //

CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_count INT;

    SELECT COUNT(DISTINCT m.id)
    INTO total_count
    FROM movies m
    JOIN movies_actors ma ON m.id = ma.movie_id
    JOIN actors a ON ma.actor_id = a.id
    JOIN genres_movies gm ON m.id = gm.movie_id
    JOIN genres g ON gm.genre_id = g.id
    WHERE CONCAT(a.first_name, ' ', a.last_name) = full_name
    AND g.name = 'History';

    RETURN total_count;
END //

DELIMITER ;

SELECT udf_actor_history_movies_count('Stephan Lundberg')  AS 'history_movies';

DELIMITER //

CREATE PROCEDURE udp_award_movie(movie_title VARCHAR(50))
BEGIN
    DECLARE movie_id INT;
    SELECT id INTO movie_id FROM movies WHERE title = movie_title;
    UPDATE actors
    SET awards = awards + 1
    WHERE id IN (SELECT actor_id FROM movies_actors WHERE movie_id = movie_id);

END //

DELIMITER ;
CALL udp_award_movie('Tea For Two');