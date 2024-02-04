CREATE DATABASE `buhtig`;

CREATE TABLE `users` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `username` VARCHAR(30) UNIQUE NOT NULL,
    `password` VARCHAR(30) NOT NULL,
    `email` VARCHAR(50) NOT NULL
);

CREATE TABLE `repositories` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `repositories_contributors` (
    `repository_id` INT,
    `contributor_id` INT,
    CONSTRAINT `fk_repositories_contributors_repositories` FOREIGN KEY (`repository_id`)
        REFERENCES `repositories` (`id`),
    CONSTRAINT `fk_repositories_contributors_users` FOREIGN KEY (`contributor_id`)
        REFERENCES `users` (`id`)
);

CREATE TABLE `issues` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `issue_status` VARCHAR(6) NOT NULL,
    `repository_id` INT NOT NULL,
    `assignee_id` INT NOT NULL,
    CONSTRAINT `fk_issues_repositories` FOREIGN KEY (`repository_id`)
        REFERENCES `repositories` (`id`),
    CONSTRAINT `fk_issues_users` FOREIGN KEY (`assignee_id`)
        REFERENCES `users` (`id`)
);

CREATE TABLE `commits` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `message` VARCHAR(255) NOT NULL,
    `issue_id` INT,
    `repository_id` INT NOT NULL,
    `contributor_id` INT NOT NULL,
    CONSTRAINT `fk_commits_issues` FOREIGN KEY (`issue_id`)
        REFERENCES `issues` (`id`),
    CONSTRAINT `fk_commits_repositories` FOREIGN KEY (`repository_id`)
        REFERENCES `repositories` (`id`),
    CONSTRAINT `fk_commits_users` FOREIGN KEY (`contributor_id`)
        REFERENCES `users` (`id`)
);

CREATE TABLE `files` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `size` DECIMAL(10 , 2 ) NOT NULL,
    `parent_id` INT,
    `commit_id` INT NOT NULL,
    CONSTRAINT `fk_files_files` FOREIGN KEY (`parent_id`)
        REFERENCES `files` (`id`),
    CONSTRAINT `fk_files_commits` FOREIGN KEY (`commit_id`)
        REFERENCES `commits` (`id`)
);

INSERT INTO `issues` 
    (`title`, `issue_status`, `repository_id`, `assignee_id`) 
    SELECT
        CONCAT('Critical Problem With ', f.name, '!'),
        'open' AS 'issue_status',
        CEIL(f.id * 2 / 3) AS 'repository_id',
        c.contributor_id AS 'assignee_id'
    FROM
        `files` AS f
            JOIN
        `commits` AS c ON f.commit_id = c.id
    WHERE
        f.id BETWEEN 46 AND 50;
    
UPDATE `repositories_contributors` AS rc
        JOIN
    (SELECT 
        r.id AS 'repo'
    FROM
        `repositories` AS r
    WHERE
        r.id NOT IN (SELECT 
                repository_id
            FROM
                `repositories_contributors`)
    ORDER BY r.id
    LIMIT 1) AS d 
SET 
    rc.repository_id = d.repo
WHERE
    rc.contributor_id = rc.repository_id;

DELETE r FROM `repositories` AS r
        LEFT JOIN
    `issues` AS i ON r.id = i.repository_id 
WHERE
    i.id IS NULL;

SELECT 
    u.id, u.username
FROM
    `users` AS u
ORDER BY u.id;

SELECT 
    *
FROM
    `repositories_contributors` AS rc
WHERE
    rc.contributor_id = rc.repository_id
ORDER BY rc.repository_id;

SELECT 
    f.id, f.name, f.size
FROM
    `files` AS f
WHERE
    f.size > 1000 AND f.name LIKE '%html%'
ORDER BY f.size DESC;

SELECT 
    i.id,
    CONCAT_WS(' : ', u.username, i.title) AS 'issue_assignee'
FROM
    `issues` AS i
        JOIN
    `users` AS u ON i.assignee_id = u.id
ORDER BY i.id DESC;

SELECT 
    f.id, f.name, CONCAT(f.size, 'KB') AS 'size'
FROM
    `files` AS f
        LEFT JOIN
    `files` AS p ON f.id = p.parent_id
WHERE
    p.id IS NULL;

SELECT 
    r.id, r.name, COUNT(i.id) AS 'issues'
FROM
    `repositories` AS r
        JOIN
    `issues` AS i ON r.id = i.repository_id
GROUP BY r.id
ORDER BY `issues` DESC , r.id
LIMIT 5;

SELECT 
    cn.id, r.name, COUNT(c.id) AS 'commits', cn.contributors
FROM
    (SELECT 
        rc.repository_id AS 'id',
            COUNT(rc.contributor_id) AS 'contributors'
    FROM
        `repositories_contributors` AS rc
    GROUP BY rc.repository_id) AS cn
        JOIN
    `repositories` AS r ON cn.id = r.id
        LEFT JOIN
    `commits` AS c ON cn.id = c.repository_id
GROUP BY cn.id
ORDER BY `contributors` DESC , r.id
LIMIT 1;

SELECT 
    u.id,
    u.username,
    SUM(IF(c.contributor_id = u.id, 1, 0)) AS 'commits'
FROM
    `users` AS u
        LEFT JOIN
    `issues` AS i ON u.id = i.assignee_id
        LEFT JOIN
    `commits` AS c ON i.id = c.issue_id
GROUP BY u.id
ORDER BY `commits` DESC , u.id;

SELECT 
    SUBSTRING_INDEX(f.name, '.', 1) AS 'file',
    COUNT(NULLIF(LOCATE(f.name, c.message), 0)) AS 'recursive_count'
FROM
    `files` AS f
        JOIN
    `files` AS p ON f.parent_id = p.id
        JOIN
    `commits` AS c
WHERE
    f.id <> p.id AND f.parent_id = p.id
        AND p.parent_id = f.id
GROUP BY f.name
ORDER BY f.name;

SELECT 
    r.id, r.name, COUNT(DISTINCT (c.contributor_id)) AS 'users'
FROM
    `repositories` AS r
        LEFT JOIN
    `commits` AS c ON r.id = c.repository_id
GROUP BY r.id
ORDER BY `users` DESC , r.id;

DROP PROCEDURE IF EXISTS udp_commit;

DELIMITER $$
CREATE PROCEDURE udp_commit
    (username VARCHAR(30), password VARCHAR(30), message VARCHAR(255), issue_id INT)
BEGIN
    START TRANSACTION;
    
    IF ((SELECT COUNT(u.id) FROM `users` AS u WHERE u.username = username) = 0) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'No such user!';
        ROLLBACK;
    ELSEIF ((SELECT u.password FROM `users` AS u WHERE u.username = username) <> password) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Password is incorrect!';
        ROLLBACK;
    ELSEIF ((SELECT COUNT(i.id) FROM `issues` AS i WHERE i.id = issue_id) = 0) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'The issue does not exist!';
        ROLLBACK;
    ELSE
        INSERT INTO `commits` 
            (`message`, `issue_id`, `repository_id`, `contributor_id`)
        VALUES
            (message,
            issue_id,
            (SELECT i.repository_id FROM `issues` AS i WHERE i.id = issue_id),
            (SELECT u.id FROM `users` AS u WHERE u.username = username));
UPDATE `issues` AS i 
SET 
    i.issue_status = 'closed'
WHERE
    i.id = issue_id;
        COMMIT;
    END IF;
END $$
DELIMITER ;

CALL udp_commit('WhoDenoteBel', 'ajmISQi*', 'Fixed issue: blah', 2);

DROP PROCEDURE IF EXISTS udp_findbyextension;

DELIMITER $$
CREATE PROCEDURE udp_findbyextension(extension VARCHAR(100))
BEGIN
    SELECT 
        f.id, 
        f.name AS 'caption', 
        CONCAT(f.size, 'KB') AS 'user'
    FROM 
        `files` AS f 
    WHERE 
        f.name LIKE (CONCAT('%', extension))
    ORDER BY f.id;
END $$
DELIMITER ;

CALL udp_findbyextension('html');