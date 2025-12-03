--3.1
CREATE TABLE accounts (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
 id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);
-- Insert test data
INSERT INTO accounts (name, balance) VALUES
 ('Alice', 1000.00),
 ('Bob', 500.00),
 ('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);

--3.2
BEGIN;
UPDATE accounts SET balance = balance - 100.00
 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Bob';
COMMIT;

select balance from accounts where name='Alice';
select balance from accounts where name = 'Bob';

--3.3
BEGIN;
UPDATE accounts SET balance = balance - 500.00
 WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

--3.4
BEGIN;
UPDATE accounts SET balance = balance - 100.00
 WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Bob';
-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Wally';
COMMIT;


--3.5
--Scenario A: READ COMMITTED
--t1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

--t2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;


--Scenario B: SERIALIZABLE
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;



--3.6
--Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
COMMIT;
--Terminal 2:
BEGIN;
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;


--3.7
--Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
--Terminal 2:
BEGIN;
UPDATE products SET price = 99.99
 WHERE product = 'Fanta';
-- Wait here (don't commit yet)
-- Then:
ROLLBACK;


--Ex1
BEGIN;
UPDATE accounts
SET balance = balance - 200.00
WHERE name = 'Bob' AND balance >= 200.00;

UPDATE accounts
SET balance = balance + 200.00
WHERE name = 'Wally'
  AND EXISTS (SELECT 1 FROM accounts WHERE name = 'Bob' AND balance >= 0);

COMMIT;
--Ex2
BEGIN;
INSERT INTO products (shop, product, price) VALUES ('MyShop', 'Apple', 1.00);
SAVEPOINT sp_insert;
UPDATE products SET price = 2.00 WHERE product = 'Apple';
SAVEPOINT sp_update;
DELETE FROM products WHERE product = 'Apple';
ROLLBACK TO sp_insert;
COMMIT;
--ex3

-- Transaction A
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE id = 1;
-- Пауза
UPDATE accounts SET balance = balance - 1000 WHERE id = 1;
COMMIT;

-- Transaction B
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 1000 WHERE id = 1;
COMMIT;

--ex4
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price) FROM products;
SELECT MIN(price) FROM products;
COMMIT;
