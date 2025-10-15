--initial data
CREATE TABLE employees (
 employee_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 department VARCHAR(50),
 salary NUMERIC(10,2),
 hire_date DATE,
 manager_id INTEGER,
 email VARCHAR(100)
);
CREATE TABLE projects (
 project_id SERIAL PRIMARY KEY,
 project_name VARCHAR(100),
 budget NUMERIC(12,2),
 start_date DATE,
 end_date DATE,
 status VARCHAR(20)
);
CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);

INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');
INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');
--task 1.1
SELECT first_name || ' ' || last_name AS full_name, department, salary
FROM employees;

--task 1.2
SELECT DISTINCT department
FROM employees;

--task 1.3
SELECT project_name, budget,
       CASE
           WHEN budget > 150000 THEN 'Large'
           WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
           ELSE 'Small'
       END AS budget_category
FROM projects;

--task 1.4
SELECT first_name || ' ' || last_name AS full_name, COALESCE(email, 'No email provided') AS email
FROM employees;

--task 2.1
SELECT *
FROM employees
WHERE hire_date > '2020-01-01';

--task 2.2
SELECT *
FROM employees
WHERE salary BETWEEN 60000 AND 70000;

--task 2.3
SELECT *
FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';

--task 2.4
SELECT *
FROM employees
WHERE manager_id IS NOT NULL AND department = 'IT';

--task 3.1
SELECT
    UPPER(first_name || ' ' || last_name) AS full_name,
    LENGTH(last_name) AS last_name_length,
    SUBSTRING(email FROM 1 FOR 3) AS email_prefix
FROM employees;

--task 3.2
SELECT
    first_name,
    last_name,
    salary * 12 AS annual_salary,
    ROUND(salary / 12, 2) AS monthly_salary,
    salary * 0.10 AS raise_amount
FROM employees;

--task 3.3
SELECT FORMAT('Project: %s Budget: $%s Status: %s', project_name, budget, status) AS project_details
FROM projects;

--task 3.4
SELECT
    first_name,
    last_name,
    DATE_PART('year', AGE(CURRENT_DATE, hire_date)) AS years_with_company
FROM employees;

--task 4.1
SELECT department, AVG(salary) AS average_salary
FROM employees
GROUP BY department;

--task 4.2
SELECT
    p.project_name,
    SUM(a.hours_worked) AS total_hours
FROM assignments a
JOIN projects p ON a.project_id = p.project_id
GROUP BY p.project_name;

--task 4.3
SELECT department, COUNT(employee_id) AS number_of_employees
FROM employees
GROUP BY department
HAVING COUNT(employee_id) > 1;

--task 4.4
SELECT
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    SUM(salary) AS total_payroll
FROM employees;

--task 5.1
(SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > 65000)
UNION
(SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE hire_date > '2020-01-01');

--task 5.2
SELECT employee_id, first_name, last_name FROM employees WHERE department = 'IT'
INTERSECT
SELECT employee_id, first_name, last_name FROM employees WHERE salary > 65000;

--task 5.3
SELECT employee_id, first_name, last_name FROM employees
EXCEPT
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id;

--task 6.1
SELECT employee_id, first_name, last_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM assignments a WHERE a.employee_id = e.employee_id
);

--task 6.2
SELECT employee_id, first_name, last_name
FROM employees
WHERE employee_id IN (
    SELECT DISTINCT employee_id
    FROM assignments
    WHERE project_id IN (
        SELECT project_id FROM projects WHERE status = 'Active'
    )
);

--task 6.3
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary FROM employees WHERE department = 'Sales'
);

--task 7.1
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    AVG(a.hours_worked) AS avg_hours,
    RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS salary_rank
FROM employees e
LEFT JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.department
ORDER BY e.department, salary_rank;

--task 7.2
SELECT
    p.project_name,
    SUM(a.hours_worked) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS num_employees
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;

--task 7.3
WITH DepartmentStats AS (
    SELECT
        department,
        COUNT(employee_id) AS total_employees,
        AVG(salary) AS average_salary,
        MAX(salary) AS max_salary,
        MIN(salary) AS min_salary
    FROM employees
    GROUP BY department
),
HighestPaid AS (
    SELECT
        department,
        first_name || ' ' || last_name AS employee_name,
        ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC) as rn
    FROM employees
)
SELECT
    ds.department,
    ds.total_employees,
    ds.average_salary,
    hp.employee_name AS highest_paid_employee_name,
    LEAST(ds.min_salary, 60000) as min_salary_comparison,
    GREATEST(ds.max_salary, 70000) as max_salary_comparison
FROM DepartmentStats ds
JOIN HighestPaid hp ON ds.department = hp.department AND hp.rn = 1;



-- TASK DURING THE CLASS

CREATE TABLE products(
     product_id SERIAL PRIMARY KEY,
     product_name VARCHAR(50),
     category VARCHAR(50),
     unit_price NUMERIC(10,2),
     stock_level INT,
    supplier_name VARCHAR(50),
    rating INT
);

CREATE TABLE customers(
    customer_id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(50),
    join_date DATE,
    loyalty_points INT,
        preferred_payment VARCHAR(50),
    city VARCHAR(50)
);

CREATE Table sales(
    sale_id SERIAL Primary Key,
    customer_id INT,
    product_id INT,
    sale_date DATE,
    quantity_sold INT,
    discount_applied INT
);


SELECT LOWER(product_name), category || ' (Category)', RIGHT(supplier_name, 3)
FROM products;

SELECT
    product_name,
    rating,
    CASE
        WHEN rating >= 4.5 THEN 'Top Rated'
        WHEN rating BETWEEN 3.0 AND 4.5 THEN 'Good'
        ELSE 'Poor'
    END AS rating_class
FROM products;

SELECT *
FROM customers
WHERE username LIKE '%123' OR username LIKE '%456';

SELECT *
FROM products
WHERE stock_level < 20 AND unit_price > 50;

SELECT
    s.sale_id,
    p.unit_price * s.quantity_sold * (1 - s.discount_applied / 100.0) AS final_price
FROM sales s
JOIN products p ON s.product_id = p.product_id;

SELECT *
FROM customers
WHERE join_date > '2023-01-01' OR loyalty_points > 1000;

SELECT *
FROM sales
WHERE discount_applied BETWEEN 10 AND 30;

SELECT
    category,
    COUNT(product_id) AS product_count
FROM products
GROUP BY category;

SELECT
    city,
    AVG(loyalty_points) AS avg_loyalty
FROM customers
GROUP BY city
HAVING AVG(loyalty_points) > 500;

SELECT
    product_id,
    SUM(quantity_sold) AS total_quantity_sold
FROM sales
GROUP BY product_id;

SELECT
    supplier_name,
    MIN(unit_price) AS min_price,
    MAX(unit_price) AS max_price
FROM products
GROUP BY supplier_name;
-- D
SELECT
    product_id,
    product_name
FROM products p
WHERE EXISTS (
    SELECT 1 FROM sales s WHERE s.product_id = p.product_id
);

SELECT *
FROM customers
WHERE loyalty_points < ALL (SELECT loyalty_points FROM customers WHERE city == 'Seattle');