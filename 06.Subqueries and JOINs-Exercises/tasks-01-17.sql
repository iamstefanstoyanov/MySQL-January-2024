SELECT e.employee_id, e.job_title, a.address_id, a.address_text
FROM employees e
JOIN addresses a ON e.address_id = a.address_id
ORDER BY a.address_id
LIMIT 5;

SELECT e.first_name, e.last_name, t.name, a.address_text
FROM employees e
JOIN addresses a ON e.address_id = a.address_id
JOIN towns t ON a.town_id = t.town_id
ORDER BY e.first_name , e.last_name
LIMIT 5;

SELECT e.employee_id, e.first_name, e.last_name, d.name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id
WHERE d.name = 'Sales'
ORDER BY e.employee_id DESC;

SELECT e.employee_id, e.first_name, e.salary, d.name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id
WHERE e.salary > 15000
ORDER BY d.department_id DESC
LIMIT 5;

SELECT employee_id, first_name 
FROM employees AS e
WHERE e.employee_id NOT IN (SELECT employee_id FROM employees_projects)
ORDER BY employee_id DESC
LIMIT 3;