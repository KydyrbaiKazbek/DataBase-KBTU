create function get_sum(a numeric, b numeric)
returns numeric as $$
begin
    return a+b;
end; $$
language plpgsql;
select get_sum(5,20.42123);

create function GetStatus(money numeric)
returns text as $$
    declare status text;
    begin
        status := case
            when money>10000 then 'GOLD'
            when money>5000 then 'Silver'
            else 'Bronze'
            end;
        return status;
end;
$$ language plpgsql;
select GetStatus(500);

-- Overloading example:
create function get_rental_duaration(p_customer_id int)
returns int as $$
    declare rental_duration int;
    begin
        select into rental_duration sum(extract(day from return_date - rental_date))
        from rental where customer_id=p_customer_id;
        return rental_duration;
    end;
$$ language plpgsql;


-- create function get_rental_duaration(different args) returns int as $$
--     declare rental_duration int;
-- $$

--Table return
create function get_film(p_pattern VARCHAR)
returns table(film_title varchar,
             film_release_year int)
    as $$
    begin
        return query select
                         title,
                         cast(release_year as int)
                         from film where title ILIKE p_pattern;
    end;
    $$ language plpgsql;

--IN/OUT
create function hi_lo(
    a numeric,
    b numeric,
    c numeric,
    out hi numeric,
    out lo numeric
) as $$
    begin
        hi:= greatest(a,b,c);
        lo:= least(a,b,c);
    end;
    $$ language plpgsql;

--INOUT
create function square(
    inout a numeric
) as $$
    begin
    a:=a*a;
end;
$$ language plpgsql

-- Пример процедуры
CREATE OR REPLACE PROCEDURE AddBonusToUser(user_id INT)
AS $$
BEGIN
    UPDATE accounts
    SET balance = balance * 1.1
    WHERE id = user_id;
    COMMIT;
END;
$$ LANGUAGE plpgsql;


-- Multi OUT with join example:
create function stat(
    p_course_code varchar,
    out enrolled_stud int,
    out avg_grade numeric,
    out pass_rate numeric
) as $$
    begin
        select count(*), avg(e.grade), (count(case when e.grade>=50 then 1 end)::numeric/count(*))*100
        into enrolled_stud, avg_grade, pass_rate
        from courses c join enrolment e using(course_id)
        where c.course_code = p_course_code;
end;
$$




-- CLASS ASSIGNMENT

CREATE TABLE products (
 product_id SERIAL PRIMARY KEY,
 product_name VARCHAR(100),
 category VARCHAR(50),
 price NUMERIC(10,2),
 stock_quantity INTEGER
);
-- Insert sample data
INSERT INTO products (product_name, category, price, stock_quantity) VALUES
('Laptop', 'Electronics', 45000, 15),
('Mouse', 'Electronics', 1500, 50),
('Keyboard', 'Electronics', 3000, 30),
('Monitor', 'Electronics', 25000, 20),
('Desk Chair', 'Furniture', 15000, 10),
('Desk', 'Furniture', 35000, 8),
('Office Lamp', 'Furniture', 5000, 25),
('Notebook', 'Stationery', 500, 100),
('Pen Set', 'Stationery', 800, 75),
('Stapler', 'Stationery', 1200, 60);
-- Create orders table
CREATE TABLE orders (
 order_id SERIAL PRIMARY KEY,
 product_id INTEGER REFERENCES products(product_id),
 customer_name VARCHAR(100),
 quantity INTEGER,
 order_date DATE,
 status VARCHAR(20)
);
-- Insert sample data
INSERT INTO orders (product_id, customer_name, quantity, order_date, status) VALUES
(1, 'Aibek Makazhanov', 2, '2024-11-01', 'completed'),
(2, 'Aibek Makazhanov', 5, '2024-11-02', 'completed'),
(3, 'Dana Bekova', 3, '2024-11-03', 'pending'),
(4, 'Timur Suleimenov', 1, '2024-11-05', 'completed'),
(5, 'Aigul Nurpeisova', 2, '2024-11-06', 'completed'),
(1, 'Dana Bekova', 1, '2024-11-08', 'pending'),
(8, 'Timur Suleimenov', 10, '2024-11-10', 'completed'),
(9, 'Aigul Nurpeisova', 5, '2024-11-12', 'completed');

--1.1
create function calculate_discount(
    original_price numeric,
    discount_percent numeric
) returns numeric as $$
    declare new_price numeric;
    begin
        new_price := original_price - (original_price * discount_percent / 100);
        return new_price;
    end;
$$ language plpgsql;

SELECT calculate_discount(100, 15); -- Should return 85
SELECT calculate_discount(250.50, 20); -- Should return 200.40

--2.1
create function category_stats(
    p_category VARCHAR,
    out total_products int,
    out avg_price numeric
) as $$
    begin
        select count(*), avg(products.price) into total_products, avg_price
        from products where p_category = products.category;
    end;
    $$ language plpgsql;

SELECT * FROM category_stats('Electronics');
SELECT * FROM category_stats('Furniture');

--3.1
create function get_customer_orders(
    p_customer_name VARCHAR
) returns table(order_date date, product_name varchar, quantity int, status varchar)
as $$
    begin
        return query select order_date, product_name, quantity, status
        from orders join products p on orders.product_id = p.product_id
        where customer_name = p_customer_name;
    end;
    $$ language plpgsql;

SELECT * FROM get_customer_orders('Aibek Makazhanov');
SELECT * FROM get_customer_orders('Dana Bekova');

--4.1
create function search_products(
    p_name_pattern varchar
) returns table(product_name varchar, price int) as $$
    begin
        select product_name, price into product_name, price from products
        where product_name ILIKE p_name_pattern;
end;
$$ language plpgsql;

create function search_products(
    p_name_pattern varchar,
    p_category varchar
) returns table(product_name varchar, price int, category varchar)
as $$
    begin
        select product_name, price, category into  product_name, price, category
        from products where product_name ILIKE p_name_pattern and category = p_category;
    end;
    $$ language plpgsql;

SELECT * FROM search_products('D%');
SELECT * FROM search_products('D%', 'Furniture')
