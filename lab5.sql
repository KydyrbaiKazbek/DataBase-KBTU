-- Kazybek Kydyrbay, 24B031144


-- Task 1.1: Basic CHECK Constraint
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age >= 18 AND age <= 65),
    salary NUMERIC CHECK (salary > 0)
);

-- Task 1.2: Named CHECK Constraint
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (regular_price > 0 AND discount_price > 0 AND discount_price < regular_price)
);

-- Task 1.3: Multiple Column CHECK
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER,
    CHECK (num_guests >= 1 AND num_guests <= 10),
    CHECK (check_out_date > check_in_date)
);

-- Task 1.4: Testing CHECK Constraints
-- Correct
INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES 
(1, 'John', 'Doe', 30, 50000),
(2, 'Jane', 'Smith', 25, 60000);
-- With errors 
INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES 
(3, 'Peter', 'Jones', 17, 40000), -- error: age < 18
(4, 'Mary', 'Williams', 70, 80000), -- error: age > 65
(5, 'Tom', 'Brown', 40, -100); -- error: salary <= 0


-- products_catalog table
INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES
(1, 'Laptop', 1200, 1000),
(2, 'Mouse', 25, 20);
-- Wwith errors
INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES 
(3, 'Keyboard', -50, -40), -- error: regular_price <= 0
(4, 'Monitor', 200, -10), -- error: discount_price <= 0
(5, 'Webcam', 80, 90); -- error: discount_price >= regular_price

-- Table: bookings
-- Valid data
INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests) VALUES
(1, '2025-11-01', '2025-11-05', 2),
(2, '2025-12-10', '2025-12-15', 5);
-- Invalid data
INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests) VALUES
(3, '2025-10-20', '2025-10-25', 0), -- error: num_guests < 1
(4, '2025-09-15', '2025-09-20', 11), -- error: num_guests > 10
(5, '2025-08-10', '2025-08-09', 2); -- error: check_out_date <= check_in_date




-- Part 2: NOT NULL Constraints
-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Testing NOT NULL
-- Table: customers
INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
(1, 'test@example.com', '123-456-7890', '2025-01-15'),
(2, 'another@example.com', NULL, '2025-02-20');
-- With error:
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (3, NULL, '987-654-3210', '2025-03-10'); -- error: email IS NULL

-- Table: inventory
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated) VALUES
(1, 'Item A', 100, 10.50, NOW()),
(2, 'Item B', 0, 25.00, NOW());
-- With error
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated) VALUES (3, NULL, 50, 5.75, NOW()); -- error: item_name IS NULL




-- Part 3: UNIQUE Constraints

-- Task 3.1: Single Column UNIQUE
CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);

-- Task 3.3: Named UNIQUE Constraints
ALTER TABLE users DROP CONSTRAINT users_username_key, DROP CONSTRAINT users_email_key;
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

-- Testing duplicate insertion
INSERT INTO users (user_id, username, email, created_at) VALUES (1, 'john_doe', 'john.doe@example.com', NOW());
-- INSERT INTO users (user_id, username, email, created_at) VALUES (2, 'john_doe', 'jane.doe@example.com', NOW()); -- error: duplicate username
-- INSERT INTO users (user_id, username, email, created_at) VALUES (3, 'jane_doe', 'john.doe@example.com', NOW()); -- error: duplicate email

-- Part 4: PRIMARY KEY Constraints

-- Task 4.1: Single Column Primary Key
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments (dept_id, dept_name, location) VALUES (1, 'Sales', 'New York');
INSERT INTO departments (dept_id, dept_name, location) VALUES (2, 'HR', 'London');
INSERT INTO departments (dept_id, dept_name, location) VALUES (3, 'IT', 'Tokyo');

-- INSERT INTO departments (dept_id, dept_name, location) VALUES (1, 'Marketing', 'Paris'); -- error: duplicate dept_id
-- INSERT INTO departments (dept_id, dept_name, location) VALUES (NULL, 'Support', 'Sydney'); -- error: dept_id IS NULL

-- Task 4.2: Composite Primary Key
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- Task 4.3: Comparison Exercise
/*
1. Difference between UNIQUE and PRIMARY KEY:
   Primary Key - identifies each row so they are all ordered and cannot take null value
    Unique - makes every entered data unique, so null can be accepted but only once
2. single-column vs. composite PRIMARY KEY:
   Single - when only one attribute is enough to identify each row
    Composite - when combination of several columns' data is necessary to make unique identifier.
3. Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints
    Unique is used only to make every data entered unique so they will not repaet, like phone, email and so on.
    Primary key is the thing that helps to identify each row/note, which also must be unique, but there is no need for several identifiers, so it can only be one, not multiple.
*/

-- Part 5: FOREIGN KEY Constraints

-- Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

-- Testing
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES (101, 'Alice', 1, '2024-01-10');
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES (102, 'Bob', 3, '2024-03-15');
-- INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES (103, 'Charlie', 4, '2024-05-20'); -- error: dept_id=4 не существует в таблице departments

-- Task 5.2: Multiple Foreign Keys (Library System)
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

-- Sample Data
INSERT INTO authors (author_id, author_name, country) VALUES (1, 'George Orwell', 'UK');
INSERT INTO authors (author_id, author_name, country) VALUES (2, 'J.K. Rowling', 'UK');

INSERT INTO publishers (publisher_id, publisher_name, city) VALUES (1, 'Penguin Books', 'London');
INSERT INTO publishers (publisher_id, publisher_name, city) VALUES (2, 'Bloomsbury Publishing', 'London');

INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES (1, '1984', 1, 1, 1949, '978-0451524935');
INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES (2, 'Harry Potter and the Philosopher''s Stone', 2, 2, 1997, '978-0747532699');

-- Task 5.3: ON DELETE Options
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

-- Testing Scenarios
INSERT INTO categories (category_id, category_name) VALUES (1, 'Electronics');
INSERT INTO products_fk (product_id, product_name, category_id) VALUES (101, 'Laptop', 1);
INSERT INTO orders (order_id, order_date) VALUES (1001, '2025-10-01');
INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES (1, 1001, 101, 1);
INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES (2, 1001, 101, 2);

-- 1. Попытка удалить категорию, у которой есть продукты.
-- DELETE FROM categories WHERE category_id = 1;
-- Результат: Ошибка. Операция не будет выполнена из-за ограничения ON DELETE RESTRICT, так как существуют продукты, ссылающиеся на эту категорию.

-- 2. Удаление заказа.
-- DELETE FROM orders WHERE order_id = 1001;
-- SELECT * FROM order_items WHERE order_id = 1001;
-- Результат: Заказ с order_id = 1001 будет удален. Благодаря ON DELETE CASCADE, все связанные записи в таблице order_items (item_id 1 и 2) также будут автоматически удалены.

-- Part 6: Practical Application

-- Task 6.1: E-commerce Database Design

-- 1. Table customers
CREATE TABLE customers_ecommerce (
    customer_id SERIAL PRIMARY KEY, -- SERIAL автоматически создает первичный ключ
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE, -- Уникальный email
    phone TEXT,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 2. Table products
CREATE TABLE products_ecommerce (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0), -- Цена не может быть отрицательной
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0) -- Количество не может быть отрицательным
);

-- 3. Table orders
CREATE TABLE orders_ecommerce (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers_ecommerce(customer_id) ON DELETE SET NULL, -- Если клиент удален, заказ остается
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')) -- Статус из списка
);

-- 4. Table order_details
CREATE TABLE order_details_ecommerce (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders_ecommerce(order_id) ON DELETE CASCADE, -- Если заказ удален, детали удаляются
    product_id INTEGER NOT NULL REFERENCES products_ecommerce(product_id) ON DELETE RESTRICT, -- Нельзя удалить продукт, если он есть в заказе
    quantity INTEGER NOT NULL CHECK (quantity > 0), -- Количество должно быть положительным
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- Sample Records
INSERT INTO customers_ecommerce (name, email, phone) VALUES 
('Ivan Ivanov', 'ivan@example.com', '111-222-333'),
('Maria Petrova', 'maria@example.com', '444-555-666'),
('Sergey Smirnov', 'sergey@example.com', '777-888-999'),
('Anna Karenina', 'anna@example.com', NULL),
('Peter The Great', 'peter@example.com', '123-123-123');

INSERT INTO products_ecommerce (name, description, price, stock_quantity) VALUES
('Ноутбук Pro', 'Мощный ноутбук для профессионалов', 1500.00, 50),
('Смартфон X', 'Последняя модель смартфона', 999.99, 120),
('Беспроводные наушники', 'Качественный звук без проводов', 150.50, 200),
('Кофемашина', 'Автоматическая кофемашина', 300.00, 75),
('Книга по SQL', 'Все, что нужно знать о базах данных', 45.99, 300);

INSERT INTO orders_ecommerce (customer_id, order_date, total_amount, status) VALUES
(1, '2025-09-01', 1650.50, 'delivered'),
(2, '2025-09-05', 999.99, 'shipped'),
(1, '2025-09-10', 45.99, 'processing'),
(3, '2025-09-11', 300.00, 'pending'),
(4, '2025-09-12', 150.50, 'cancelled');

INSERT INTO order_details_ecommerce (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1500.00),
(1, 3, 1, 150.50),
(2, 2, 1, 999.99),
(3, 5, 1, 45.99),
(4, 4, 1, 300.00),
(5, 3, 1, 150.50);

-- Test Queries Demonstrating Constraints
-- 1. error UNIQUE (email)
-- INSERT INTO customers_ecommerce (name, email, phone) VALUES ('Duplicate User', 'ivan@example.com', '000-000-000');
-- Результат: Ошибка, так как email 'ivan@example.com' уже существует.

-- 2. error CHECK (price)
-- INSERT INTO products_ecommerce (name, price, stock_quantity) VALUES ('Bad Product', -10.00, 10);
-- Результат: Ошибка, так как цена не может быть отрицательной.

-- 3. error CHECK (status)
-- INSERT INTO orders_ecommerce (customer_id, total_amount, status) VALUES (2, 100.00, 'waiting');
-- Результат: Ошибка, так как статус 'waiting' не входит в разрешенный список.

-- 4. error FOREIGN KEY
-- INSERT INTO orders_ecommerce (customer_id, total_amount, status) VALUES (99, 100.00, 'pending');
-- Результат: Ошибка, так как customer_id=99 не существует в таблице customers_ecommerce.

-- 5. error CHECK (quantity)
-- INSERT INTO order_details_ecommerce (order_id, product_id, quantity, unit_price) VALUES (2, 3, 0, 150.00);
-- Результат: Ошибка, так как количество должно быть больше 0.