CREATE DATABASE advanced_lab;
-- 1 Creating tables
CREATE TABLE employees(
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    department VARCHAR(50),
    salary INT,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INT,
    manager_id INT
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(150),
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT
);

-- 2 Inserting Data
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'Kazybek', 'Kydyrbay', 'IT'),
       (2, 'Nick', 'Taylorson', 'Marketing'),
       (3, 'Michel', 'Jackson', 'Music Production');

-- 3 Inserting default data
INSERT INTO employees (emp_id,first_name, last_name, hire_date, salary, status)
VALUES ( 4,'Jane', 'Smith', '2008-07-08', DEFAULT, DEFAULT);

-- 4 Multi-inserting into Departments
INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('IT', 15000000, 2),
       ('Marketing', 2000000, 1),
       ('Quality Control', 1000000, 4);

-- 5 Adding person
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Mariya', 'Kabdol', 'IT', 50000*1.1, CURRENT_TIME);

-- 6 Insert with select
CREATE TABLE temp_employees AS TABLE employees WITH NO DATA;
INSERT INTO temp_employees SELECT * from employees where department = 'IT';

-- 7 10% increase
UPDATE employees SET salary = salary * 1.1;

--8 Senior update
UPDATE employees SET status = 'Senior' WHERE salary >60000 AND hire_date < '2020-01-01';

--9 Case
UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;

--10 Update default null value
UPDATE employees
SET department = NULL
WHERE status = 'Inactive';

--11 Budget update 1.2 of avg. sal.
UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.2
    FROM employees e
    WHERE e.department = d.dept_name
);

--12 Sales dep salary update
UPDATE employees
SET salary = salary * 1.15, status = 'Promoted'
WHERE department = 'Sales';

--13 Termination
DELETE FROM employees WHERE status = 'Terminated';

-- 14 multi-conditional deletion
DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

-- 15
DELETE FROM departments
WHERE dept_name NOT IN (SELECT DISTINCT department from employees WHERE department IS NOT NULL);

--16
DELETE FROM projects WHERE end_date < '2023-01-01' RETURNING *;

--17
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Tester', 'Test', NULL, NULL);

--18
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

--19
DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

--20
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Maria', 'Garcia', 'HR', 60000, '2022-08-01')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

--21
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary AS new_salary;

--22
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

--23
INSERT INTO employees (first_name, last_name, department)
SELECT 'Kairat', 'Nurtas', 'Entertainment'
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'kairat' AND last_name = 'Nurtas'
);

--24
UPDATE employees e
SET salary = salary *
    CASE
        WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000
        THEN 1.10 -- Повышение на 10%
        ELSE 1.05 -- Повышение на 5%
    END;

--25
INSERT INTO employees (first_name, last_name, department, salary) VALUES
('Aya', 'One', 'Temp', 50000),
('Aya', 'Two', 'Temp', 91000),
('Aya', 'Three', 'Temp', 42500),
('Aya', 'Four', 'Temp', 44000),
('Aya', 'Five', 'Temp', 78000);
UPDATE employees
SET salary = salary * 1.1
WHERE department = 'Temp';

--26
CREATE TABLE employee_archive (LIKE employees INCLUDING ALL);

WITH moved_rows AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved_rows;

--27
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000 AND (
    SELECT COUNT(*)
    FROM employees e
    JOIN departments d ON e.department = d.dept_name
    WHERE d.dept_id = p.dept_id) > 3;





