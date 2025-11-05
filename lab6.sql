-- PART1
-- Create table: employees
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);

-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- PART2 cross join
--2.1 basic cross joint
select employees.emp_name, departments.dept_name
from employees cross join departments;
--2.2 alternative syntax for cross joint
select employees.emp_name, departments.dept_name
from employees inner join departments on true;
--2.3
select employees.emp_name, projects.project_name
from employees cross join projects;

--PART3
--3.1 Basic Inner Joint with ON  ##### ... on a.id = b.id
select e.emp_name, d.dept_name, d.location
from employees e inner join departments d on e.dept_id = d.dept_id;
--3.2 Inner Join with Using      ##### ... using (id)
select employees.emp_name, departments.dept_name, departments.location
from employees inner join departments using (dept_id);
--3.3 Natural Inner Join         ##### compared all columns and find the match, like "oh, these two tables has 'id' column, so I will use it to join"
select employees.emp_name, departments.dept_name, departments.location
from employees natural inner join departments;
--3.4 Multi-table Inner Join
select e.emp_name, d.dept_name, p.project_name
from employees e
inner join departments d on e.dept_id = d.dept_id
inner join projects p on e.dept_id = p.dept_id;

--PART4
--4.1 Basic Left Join       ANSWER: Tom Brown is shown as null in all columns
select e.emp_name, e.dept_id as emp_dept, d.dept_id as dept_dept, d.dept_name
from employees e left join departments d on e.dept_id = d.dept_id;
--4.2 Left Join with using
select e.emp_name, e.dept_id as emp_dept, d.dept_id as dept_dept, d.dept_name
from employees e left join departments d using (dept_id);
--4.3 Find Unmatched Records
select e.emp_name, e.dept_id
from employees e left join departments d using (dept_id)
where d.dept_id is null;
--4.3 Left Join with Aggregation
select d.dept_name, count(e.emp_id) as employee_count
from departments d left join employees e on d.dept_id=e.dept_id
group by d.dept_id, d.dept_name
order by employee_count desc;

--PART5
--5.1 Basic Right Join
select departments.dept_name as Deparment, employees.emp_name as Employee
from employees right join departments using (dept_id) order by dept_name;
--5.2 Convert to Left Join
select departments.dept_name as department, employees.emp_name as employee
from departments left join employees using (dept_id);
--5.3 Find Departments without employees
select departments.dept_name
from employees right join departments using (dept_id)
where employees.dept_id is null;

--PART6
--6.1 Basic Full Join
select e.emp_name, e.dept_id as emp_dept, d.dept_id as dept_dept, d.dept_name
from employees e full join departments d on e.dept_id = d.dept_id;
--6.2 Full Join ith Projects
select departments.dept_name, projects.project_name, projects.budget
from departments full join projects using (dept_id);
--6.3 Find Orphaned Records
select departments.dept_name, employees.emp_name
from departments full join employees using (dept_id)
where dept_id is null or emp_id is null;
-- Official solution:
SELECT
 CASE
 WHEN e.emp_id IS NULL THEN 'Department without employees'
 WHEN d.dept_id IS NULL THEN 'Employee without department'
 ELSE 'Matched'
 END AS record_status,
 e.emp_name,
 d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

--PART7 ON vs Where clause
--7.1 Filtering in ON clause (Outer Join)
select e.emp_name, d.dept_name, e.salary
from employees e left join departments d on e.dept_id = d.dept_id
and d.location = 'Building A';

--7.2 Filtering in Where Clause (outer join)
select e.emp_name,d.dept_name, e.salary
from employees e left join departments d on e.dept_id=d.dept_id
where d.location = 'Building A';

--7.3 ON vs Where with inner join
select e.emp_name, d.dept_name, e.salary
from employees e inner join departments d on e.dept_id=d.dept_id
and d.location = 'Building A';

select e.emp_name, d.dept_name, e.salary
from employees e inner join departments d on e.dept_id=d.dept_id
where d.location = 'Building A';

--PART8
--8.1 Multiple Joins with Different types
select departments.dept_name, employees.emp_name, employees.salary, projects.project_name, projects.budget
from departments left join employees using (dept_id)
left join projects using (dept_id)
order by departments.dept_name, employees.emp_name;
--8.2 Self join
--table editing
alter table employees add column manager_id int;

update employees set manager_id = 3 where emp_id=1;
update employees set manager_id = 3 where emp_id=2;
update employees set manager_id = null where emp_id=3;
update employees set manager_id = 3 where emp_id=4;
update employees set manager_id = 3 where emp_id=5;
--actual task
select
    e.emp_name as employee,
    m.emp_name as manager
from employees e
left join employees m on e.manager_id=m.emp_id;

--8.3 Join with Subquery
select d.dept_name, avg(e.salary) as avg_salary
from departments d inner join employees e using (dept_id)
group by d.dept_id, d.dept_name
having avg(e.salary)>50000;

-- During class
-- the queries were deleted and replaced with instructor's own task of rewriting the 2nd problem again
select d.dept_name, count(e.emp_id) as num_employees, avg(e.salary) as avg_salary,
       count(p.project_id) as num_projects
from departments d left join employees e using (dept_id)
left join projects p using (dept_id)
group by d.dept_id, d.dept_name;
