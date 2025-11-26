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


