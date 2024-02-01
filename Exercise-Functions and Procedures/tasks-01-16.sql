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

DELIMITER //

CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
	SELECT CONCAT(first_name,' ',last_name) AS full_name
    FROM account_holders
    ORDER BY full_name, id;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE usp_get_holders_with_balance_higher_than (target_salary DECIMAL (19,4))
BEGIN
	SELECT ah.first_name,ah.last_name FROM account_holders ah
    JOIN accounts a ON ah.id = a.account_holder_id
    WHERE target_salary < (SELECT SUM(balance) 
FROM accounts
WHERE account_holder_id = ah.id
GROUP BY account_holder_id)
GROUP BY ah.id
ORDER BY ah.id;
END//

DELIMITER ;

DELIMITER //

CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19, 4), interest_rate DOUBLE, years INT)
RETURNS DECIMAL(19, 4)
DETERMINISTIC
RETURN sum*POW(1+interest_rate, years);

DELIMITER ;

DELIMITER //

CREATE PROCEDURE usp_calculate_future_value_for_account(id INT, interest_rate DECIMAL(19, 4))
DETERMINISTIC
BEGIN
SELECT a.id, first_name, last_name, balance AS current_balance, ufn_calculate_future_value(balance, interest_rate, 5) AS balance_in_5_years
FROM accounts a
JOIN account_holders ah ON a.account_holder_id = ah.id
WHERE a.id = id;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
	START TRANSACTION;
	IF((SELECT count(a.id) FROM accounts AS a WHERE a.id = account_id) != 1 OR money_amount < 0) THEN
	ROLLBACK;
	ELSE
		UPDATE accounts 
        SET balance = balance + money_amount
		WHERE accounts.id = account_id;
	END IF; 
END

DELIMITER ;

DELIMITER //

CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
	START TRANSACTION;
	IF((SELECT count(a.id) FROM accounts a WHERE a.id = account_id) != 1 
    OR money_amount < 0 
    OR (SELECT balance FROM accounts a WHERE a.id = account_id) < money_amount) THEN
	ROLLBACK;
	ELSE
		UPDATE accounts 
        SET balance = balance - money_amount
		WHERE accounts.id = account_id;
	END IF; 
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19, 4))
BEGIN
	START TRANSACTION;
	IF((SELECT count(a.id) FROM accounts a WHERE a.id = to_account_id) != 1 
    OR (SELECT count(a.id) FROM accounts a WHERE a.id = from_account_id) != 1 
    OR amount < 0 
    OR (SELECT balance FROM accounts a WHERE a.id = from_account_id) < amount
    OR from_account_id = to_account_id
    ) 
    THEN
	ROLLBACK;
	ELSE
		UPDATE accounts 
        SET balance = balance - amount
		WHERE accounts.id = from_account_id;
UPDATE accounts 
SET 
    balance = balance + amount
WHERE
    accounts.id = to_account_id;
	END IF; 
END//

CREATE TABLE `logs`(
log_id INT AUTO_INCREMENT PRIMARY KEY,
account_id INT,
old_sum DECIMAL(19, 4),
new_sum DECIMAL(19, 4)
);

DELIMITER //

CREATE TRIGGER log_accounts_trigger BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
IF(OLD.balance != NEW.balance) THEN 
INSERT INTO `logs` (account_id, old_sum, new_sum)
VALUES (NEW.id, OLD.balance, NEW.balance); 
END IF;
END//

DELIMITER ;

CREATE TABLE notification_emails (
id INT AUTO_INCREMENT PRIMARY KEY,
recipient INT, 
`subject` TEXT, 
body TEXT);

DELIMITER //

CREATE TRIGGER log_logs_trigger AFTER INSERT ON `logs`
FOR EACH ROW
BEGIN
INSERT INTO notification_emails (recipient, `subject`, body)
SELECT account_id, 
CONCAT('Balance change for account: ', account_id), 
CONCAT('On ', DATE_FORMAT(NOW(), '%b %d %Y at %r'), ' your balance was changed from ', 
ROUND(old_sum, 2), ' to ', ROUND(new_sum, 2))
FROM `logs`
ORDER BY log_id DESC 
LIMIT 1; 
END//

DELIMITER ;