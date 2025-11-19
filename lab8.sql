CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(100),
 dept_id INT,
 salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
 proj_id INT PRIMARY KEY,
 proj_name VARCHAR(100),
 budget DECIMAL(12,2),
 dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample data
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);


-- Part2
--2.1
create index emp_salary_idx on employees(salary);
-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE tablename = 'employees';
--2.2
create index emp_dept_idx on employees(dept_id);
--2.3
select tablename, indexname, indexdef
from pg_indexes
where schemaname = 'public'
order by tablename, indexname;


--Part3
--3.1
create index emp_dept_salary_idx on employees(dept_id, salary);
--3.2
create index emp_salary_dept_idx on employees(salary, dept_id);
--Part4
--4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

create unique index emp_email_unique_idx on employees(email);
--4.2
alter table employees add column phone varchar(20) unique;

select pg_indexes.indexname, pg_indexes.indexdef
from pg_indexes
where tablename = 'employees' and indexname like '%phone%';

--Part 5
--5.1
create index emp_salary_desc_idx on employees(salary desc);
--5.2
create index proj_budget_nulls_first_idx on projects(budget nulls first);

--Part 6
--6.1
create index emp_name_lower_idx on employees(lower(employees.emp_name));

--6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

create index emp_hire_year_idx on employees(extract(year from employees.hire_date));

--Part7
--7.1
alter index emp_salary_idx rename to employees_salary_index;

--7.2
drop index emp_salary_dept_idx;


--Part8
--8.1
create index emp_salary_filter_idx on employees(salary) where salary>50000;
--82.
create index proj_high_budget_idx on projects(budget) where budget>80000;

--8.3
explain select * from employees where salary > 52000;

--Part9
--9.1
create index dept_name_hash_idx on departments using hash (dept_name);
--9.2
create index proj_name_btree_idx on projects(proj_name);
create index proj_name_hash_idx on projects using hash (proj_name);

--10.1
select schemaname, tablename, indexname,
pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
from pg_indexes
where schemaname = 'public'
order by tablename, indexname;

--10.2
drop index if exists proj_name_hash_idx;
--10.3
create view index_documentation as
    select tablename, pg_indexes.indexname,'Improves salary-based queries' as purpose
from pg_indexes
where schemaname = 'public' and indexname like '%salary%';

select * from index_documentation;
