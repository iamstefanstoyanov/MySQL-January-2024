SELECT 
    employee_id,
    CONCAT(first_name, ' ',last_name) AS `full_name`,
    departments.department_id,
    name AS `department_name`
FROM
    departments
        JOIN
    employees ON departments.manager_id = employees.employee_id
ORDER BY employee_id
LIMIT 5;

SELECT t.town_id, t.name, a.address_text 
FROM towns AS t
JOIN addresses AS a
ON t.town_id = a.town_id
WHERE t.name IN ('San Francisco', 'Sofia', 'Carnation')
ORDER BY t.town_id, a.address_id;

SELECT employee_id, first_name, last_name, department_id, salary 
FROM employees
WHERE manager_id IS NULL;

SELECT COUNT(*) AS count 
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);