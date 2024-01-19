SELECT `first_name`,`last_name` 
FROM `employees` 
WHERE
SUBSTRING(`first_name`, 1, 2) = "Sa"
ORDER BY `employee_id`;

SELECT `first_name`,`last_name` 
FROM `employees`
WHERE
LOCATE("ei",`last_name`)
ORDER BY `employee_id`;

SELECT `first_name`
FROM `employees`
WHERE (`department_id` = 3 OR `department_id` = 10)
  AND EXTRACT(YEAR FROM `hire_date`) BETWEEN 1995 AND 2005
ORDER BY `employee_id`;

SELECT `first_name`,`last_name` 
FROM `employees` 
WHERE LOWER(`job_title`) NOT LIKE '%engineer%'
ORDER BY `employee_id`;

SELECT `name` from `towns`
WHERE length(`name`) IN ( 5, 6)
ORDER BY `name`;