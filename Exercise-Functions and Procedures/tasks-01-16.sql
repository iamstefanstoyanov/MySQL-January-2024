DELIMITER //
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
	SELECT first_name, last_name FROM employees
    WHERE salary > 35000
    ORDER BY first_name,last_name,employee_id;
END//

DELIMITER ;

CALL usp_get_employees_salary_above_35000();

DELIMITER //
CREATE PROCEDURE usp_get_employees_salary_above(target_salary DECIMAL(10,4))
BEGIN
	SELECT first_name, last_name FROM employees
    WHERE salary >= target_salary
    ORDER BY first_name,last_name,employee_id;
END//

DELIMITER ;

DELIMITER //
CREATE PROCEDURE usp_get_towns_starting_with(symbol VARCHAR(20))
BEGIN
	SELECT name FROM towns
    WHERE name LIKE CONCAT(symbol, '%')
    ORDER BY name;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE usp_get_employees_from_town (town_name VARCHAR(50))
BEGIN
	SELECT e.first_name,e.last_name FROM employees e
    JOIN addresses a ON e.address_id = a.address_id
    JOIN towns t ON a.town_id = t.town_id
    WHERE t.name = town_name
    ORDER BY e.first_name,e.last_name,e.employee_id;
END//

DELIMITER ;

DELIMITER //

CREATE FUNCTION ufn_get_salary_level (salary DECIMAL(10,4))
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
	DECLARE result VARCHAR(20);
    IF(salary<30000) THEN
    SET result := 'Low';
    ELSEIF (salary >= 30000 AND salary<= 50000) THEN
    SET result := 'Average';
    ELSE 
		SET result := 'High';
        END IF;
    RETURN result;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE usp_get_employees_by_salary_level (salary_level VARCHAR(10))
BEGIN
	SELECT first_name,last_name FROM employees
    WHERE salary_level = ufn_get_salary_level (salary)
    ORDER BY first_name DESC, last_name DESC;
END//

DELIMITER ;

DELIMITER //

CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS TINYINT
DETERMINISTIC
BEGIN
	RETURN word REGEXP CONCAT('^[',set_of_letters,']+$');
END//

DELIMITER ; 