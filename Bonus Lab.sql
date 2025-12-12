--Data and tables prep
--My datatypes
create type acc_currency as enum ('KZT', 'RUB','EUR', 'USD');
create type acc_stat as enum ('active', 'blocked', 'frozen');
create type transaction_type as enum ('transfer', 'deposit', 'withdraw');
create type transaction_stat as enum ('pending', 'completed', 'failed', 'reversed');

create table customers(
    customer_id serial primary key,
    iin char(12) unique not null,
    full_name varchar(255) not null,
    phone varchar(20),
    email varchar(255),
    status acc_stat default 'active',
    created_at timestamp default current_timestamp,
    daily_limit_kzt decimal(15,2) default 250000.00
    );

create table accounts(
    acc_id serial primary key,
    customer_id int references customers(customer_id),
    acc_number varchar(34) unique not null, --2 letters for KZ and other countries, 2 digits and up to 30 chars - IBAN standard
    currency acc_currency not null,
    balance decimal(15,2) default 0.00,
    is_active boolean default true,
    opened_at timestamp default current_timestamp,
    closed_at timestamp
);

create table exchange_rates(
    rate_id serial primary key,
    from_currency acc_currency not null,
    to_currency acc_currency not null,
    rate decimal(10,6) not null,
    valid_from timestamp default current_timestamp,
    valid_to timestamp
);

create table transactions(
    transaction_id serial primary key,
    from_acc_id int references accounts(acc_id),
    to_acc_id int references accounts(acc_id),
    amount decimal(15,2) not null,
    currency acc_currency not null,
    exchange_rate decimal(10,6),
    amount_kzt decimal(15,2),
    type transaction_type not null,
    status transaction_stat default 'pending',
    created_at timestamp default current_timestamp,
    completed_at timestamp,
    description text
);

create table audit_log(
    log_id serial primary key,
    table_name varchar(50),
    record_id int,
    action varchar(10),
    old_values jsonb,
    new_values jsonb,
    changed_by varchar(50) default current_user,
    changed_at timestamp default current_timestamp,
    ip_address inet
);

-- Data insertion
insert into customers(iin, full_name, phone, daily_limit_kzt) values
('000000000000', 'Myname Is Kazybek', '+73141592653', 500000),
('111111111111', 'Almas Olzhas Sultanuly', '+75897932384',default),
('222222222222', 'Ernazarov Amir','+76264338327' ,default),
('333333333333', 'Kenes Abay','+79502884197', 100000),
('444444444444', 'Daulet Adil', '+71693993751',450000),
('555555555555', 'Kadyrova Sayle','+70582097494', 50000),
('666666666666', 'Eskendir Esmakhan','+74592307816', 800000),
('777777777777', 'Alexey Pushka', '+74062862089',300000),
('888888888888', 'Sponge Bob', '+79862803482',150000),
('999999999999', 'Anuar Dimash', '+75342117067',200000);

insert into accounts(customer_id, acc_number, currency, balance) values
(10, 'KZ33279943524423618823', 'KZT', 3406903.03),
(1, 'KZ34772163786093525136', 'KZT', 8555034.26),
(2, 'KZ19291243064099701450', 'KZT', 600582.35),
(3, 'KZ37570976180185639960', 'RUB', 1824545.09),
(4, 'KZ90109866645828922442', 'KZT', 2160663.25),
(5, 'KZ50020424908568588795', 'KZT', 307044.73),
(6, 'KZ22135088401772225340', 'EUR', 65887.49),
(7, 'KZ29729584268679284620', 'KZT', 7737454.36),
(8, 'KZ61329889283406532588', 'USD', 44670.28),
(9, 'KZ82133121523137523768', 'KZT', 4465393.43);

insert into exchange_rates(from_currency, to_currency, rate) values
('EUR', 'KZT', 609.52),
('KZT', 'EUR', 0.001631),
('USD', 'KZT', 517),
('KZT', 'USD', 0.001907),
('RUB', 'KZT', 6.08),
('KZT', 'RUB', 0.142857),
('EUR', 'USD', 1.17),
('USD', 'EUR', 0.85),
('USD', 'RUB', 79.68),
('RUB', 'USD', 0.013),
('EUR', 'RUB', 93.42),
('RUB', 'EUR', 0.011);
--commission included into the rate for operations with tenge:)

--TASK1
--process_transfer procedure which trnasfers money from one account to another
--account based on 5 parameters from_account_number, to_account_number, amount,
-- currency, description
create or replace procedure process_transfer(
    p_from_acc varchar,
    p_to_acc varchar,
    p_amount decimal,
    p_currency acc_currency,
    p_description text
) as $$
declare
    v_from_id int;
    v_to_id int;
    v_from_bal decimal;
    v_cust_status acc_stat;
    v_limit decimal;
    v_daily_sum decimal;
    v_rate decimal := 1.0;
    v_amount_kzt decimal;
    v_to_currency acc_currency;
    v_cust_id int;
    v_error_msg text;
begin
    begin
    -- 1. validating accounts' existence and getting the ids
    select acc_id, balance, customer_id into v_from_id, v_from_bal, v_cust_id
    from accounts where acc_number = p_from_acc for update; -- sender
    if not found then raise exception 'Sender account not found'; end if;

    select acc_id, currency into v_to_id, v_to_currency
    from accounts where acc_number = p_to_acc for update; -- receiver
    if not found then raise exception 'Receiver account not found'; end if;

    -- 2. validating customer status if it is active
    select status, daily_limit_kzt into v_cust_status, v_limit
    from customers where customer_id = v_cust_id;
    if v_cust_status != 'active' then raise exception 'Sender customer is not active'; end if;

    -- 3. checking the balance
    if v_from_bal < p_amount then raise exception 'Insufficient funds'; end if;

    -- 4. calculating rates & kzt amount
    if p_currency != 'KZT' then
        select rate into v_rate from exchange_rates
        where from_currency = p_currency and to_currency = 'KZT'
        order by valid_from desc limit 1;
        v_amount_kzt := p_amount * v_rate;
    else v_amount_kzt := p_amount; end if;

    -- 5. checking daily limit
    select coalesce(sum(amount_kzt), 0) into v_daily_sum
    from transactions
    where from_acc_id = v_from_id
    and type = 'transfer'
    and created_at::date = current_date;

    if (v_daily_sum + v_amount_kzt) > v_limit then
        raise exception 'Daily transaction limit exceeded';
    end if;

    -- 6. executing the transfer (ACID - Atomicity)
    update accounts set balance = balance - p_amount where acc_id = v_from_id;

    -- handling currency conversion for receiver
    declare
        v_final_credit decimal := p_amount;
        v_cross_rate decimal;
    begin
        if p_currency != v_to_currency then
             -- Attempt for Direct pair (but I already inserted rates for all combination of the 4 currencies). Can be useful if a new currency was added.
             select rate into v_cross_rate 
             from exchange_rates 
             where from_currency = p_currency and to_currency = v_to_currency 
             order by valid_from desc limit 1;
             -- If the bank doesn't have such rate and multi-conversion is necessary
             if found then
                v_final_credit := p_amount * v_cross_rate;
             else
                v_final_credit := p_amount * (select rate from exchange_rates where from_currency = p_currency and to_currency = 'KZT' limit 1) * (select rate from exchange_rates where from_currency = 'KZT' and to_currency = v_to_currency limit 1);
             end if;
        end if;

        update accounts set balance = balance + v_final_credit where acc_id = v_to_id;
    end;

    -- 7. log transaction & audit
    insert into transactions (from_acc_id, to_acc_id, amount, currency, amount_kzt, type, status, description, completed_at)
    values (v_from_id, v_to_id, p_amount, p_currency, v_amount_kzt, 'transfer', 'completed', p_description, now());

    insert into audit_log (table_name, record_id, action, new_values)
    values ('transactions', lastval(), 'INSERT', jsonb_build_object('amount', p_amount, 'from', p_from_acc));

    exception when others then
        v_error_msg := sqlerrm;
    end;

    if v_error_msg is not null then
        -- Logging the failure
        insert into audit_log (table_name, action, new_values)
        values ('transactions', 'FAILURE', jsonb_build_object('error', v_error_msg));
        commit;
        raise notice 'Transaction failed with error: %', v_error_msg;
    else
        commit;
    end if;
end;
$$ language plpgsql;





--TASK2
-- First view (customer_balance_summary)
create or replace view customer_balance_summary as
select
    c.full_name,
    c.iin,
    count(a.acc_id) as total_accounts,
    sum(a.balance * coalesce((select rate from exchange_rates er where er.from_currency = a.currency and er.to_currency = 'KZT' order by valid_from desc limit 1), 1)) as total_balance_kzt,
    (sum(a.balance * coalesce((select rate from exchange_rates er where er.from_currency = a.currency and er.to_currency = 'KZT' order by valid_from desc limit 1), 1))
    / nullif(c.daily_limit_kzt, 0)) * 100 as limit_utilization_pct,

    rank() over (order by sum(a.balance * coalesce((select rate from exchange_rates er where er.from_currency = a.currency and er.to_currency = 'KZT' order by valid_from desc limit 1), 1)) desc) as balance_rank
from customers c
join accounts a on c.customer_id = a.customer_id
group by c.customer_id, c.full_name, c.iin, c.daily_limit_kzt;

-- Second view (daily_transaction_report)
create or replace view daily_transaction_report as
select
    created_at::date as trans_date,
    type,
    count(*) as trans_count,
    sum(amount_kzt) as daily_volume,
    avg(amount_kzt) as avg_amount,
    sum(sum(amount_kzt)) over (partition by type order by created_at::date) as running_total_volume,
    (sum(amount_kzt) - lag(sum(amount_kzt)) over (partition by type order by created_at::date))
        / nullif(lag(sum(amount_kzt)) over (partition by type order by created_at::date), 0) * 100 as growth_pct
from transactions
group by created_at::date, type;

-- Third view (suspicious_activity_view)
create or replace view suspicious_activity_view with (security_barrier) as
select * from transactions t1
where
    amount_kzt > 5000000 --checking if it is greater than 5 million tenge equivalent
    or exists (          --checking if there are rapid sequential transfers
        select 1 from transactions t2
        where t2.from_acc_id = t1.from_acc_id
        and t2.transaction_id != t1.transaction_id
        and abs(extract(epoch from (t1.created_at - t2.created_at))) < 60
    )
    -- cheking if there are >10 transactions in an hour
    or (
        select count(*)
        from transactions t3
        where t3.from_acc_id = t1.from_acc_id
        and t3.created_at between t1.created_at - interval '1 hour' and t1.created_at
    ) > 10;






-- TASK3
set enable_seqscan = on; -- because the set is too small postgre will prefer sequential scan, but to see the real impact of indexing I will turn it off using this command.
-- 1. B-Tree Index
-- Finding customers by IIN is common operation banks might often do.
explain analyze select * from customers where iin = '111111111111'; -- Before: planning 5.132, exe 1.988 ms
create index idx_customers_iin on customers(iin);
explain analyze select * from customers where iin = '111111111111'; -- after: planning 0.54, exe 0.032 ms

-- 2. Hash Index
-- We look up transaction currency using exact equality
explain analyze select * from transactions where currency = 'USD'; -- Before: plannign 3.584, exe 0.051
create index idx_trans_currency on transactions using HASH (currency);
explain analyze select * from transactions where currency = 'USD'; -- After: planning 0.814, exe 0.459

-- 3. GIN Index
-- The audit_log table stores unstructured JSONB data. We need to search inside the JSON.
explain analyze select * from audit_log where new_values @> '{"amount": 1000}'; --before: planning 0.169, exe 0.032 ms
create index idx_audit_json on audit_log using GIN (new_values);
explain analyze select * from audit_log where new_values @> '{"amount": 1000}'; --after: planning 0.167, exe 0.847 ms
--it's because there was too less data to search through.

-- 4. Partial Index
-- We frequently query active accounts, but rarely query banned and frozen ones.
explain analyze select * from accounts where acc_number = 'KZ003' and is_active = true; --before: planning 0.912, exe 0.06 ms
create index idx_active_accounts on accounts(acc_number) where is_active = true;
explain analyze select * from accounts where acc_number = 'KZ003' and is_active = true;--after: planning 0.587, exe 0.051 ms


-- 5. Composite Index (Covering Index)
-- High-volume queries often check "Sender" + "Date" together for limit checks.
EXPLAIN ANALYZE SELECT * FROM transactions
WHERE from_acc_id = 1 AND created_at >= '2025-10-06'; -- before 0.162, 0.089 ms

CREATE INDEX idx_trans_sender_date ON transactions(from_acc_id, created_at);

EXPLAIN ANALYZE SELECT * FROM transactions
WHERE from_acc_id = 1 AND created_at >= '2025-10-06'; --after 0.150, 0.034

--To speed up the transfer procedure
explain analyze select sum(amount_kzt)
from transactions
where from_acc_id = 1 and type = 'transfer' and created_at >= CURRENT_DATE; --before: planning 0.736, exe 0.119

create index idx_trans_limit_check
on transactions(from_acc_id, type, created_at)
include (amount_kzt);

explain analyze select sum(amount_kzt)
from transactions
where from_acc_id = 1 and type = 'transfer' and created_at >= CURRENT_DATE; --after: planning 0.190, exe 0.058
--also because of lack of data, but in real world scenario it will gradually speed up.



--TASK4
create or replace procedure process_salary_batch(
    p_company_acc varchar,
    p_payments jsonb,
    inout v_success_count int default 0,
    inout v_fail_count int default 0,
    inout v_fail_details jsonb default '[]'::jsonb
) as $$
declare
    v_comp_id int;
    v_comp_bal decimal;
    v_payment jsonb;
    v_total_batch_planned decimal := 0;
    v_actual_spent decimal := 0;
    v_employee_acc int;
    v_amount decimal;
begin
    if not pg_try_advisory_lock(hashtext(p_company_acc)) then
        raise exception 'Batch processing already in progress for this company';
    end if;

    select acc_id, balance into v_comp_id, v_comp_bal
    from accounts where acc_number = p_company_acc for update;

    select sum((p->>'amount')::decimal) into v_total_batch_planned
    from jsonb_array_elements(p_payments) p;

    if v_comp_bal < v_total_batch_planned then
        raise exception 'Company funds insufficient for total batch';
    end if;

    for v_payment in select * from jsonb_array_elements(p_payments)
    loop
        v_amount := (v_payment->>'amount')::decimal;

        begin
            select acc_id into v_employee_acc
            from accounts a join customers c on a.customer_id = c.customer_id
            where c.iin = v_payment->>'iin' and a.currency = 'KZT' limit 1;

            if v_employee_acc is null then
                raise exception 'Employee account not found for IIN %', v_payment->>'iin';
            end if;

            update accounts set balance = balance + v_amount
            where acc_id = v_employee_acc;

            v_success_count := v_success_count + 1;
            v_actual_spent := v_actual_spent + v_amount;

        exception when others then
            v_fail_count := v_fail_count + 1;
            v_fail_details := v_fail_details || jsonb_build_object(
                'iin', v_payment->>'iin',
                'error', sqlerrm
            );
        end;
    end loop;

    update accounts
    set balance = balance - v_actual_spent
    where acc_id = v_comp_id;

    perform pg_advisory_unlock(hashtext(p_company_acc));

    insert into audit_log (table_name, action, new_values)
    values ('batch_salary', 'REPORT', jsonb_build_object(
        'company', p_company_acc,
        'success', v_success_count,
        'failed', v_fail_count,
        'details', v_fail_details,
        'total_spent', v_actual_spent
    ));

    raise notice 'Batch Complete. Success: %, Failed: %', v_success_count, v_fail_count;
end;
$$ language plpgsql;

create materialized view salary_batch_report as
select
    log_id as report_id,
    changed_at as processed_at,
    new_values->>'company' as company_account,
    (new_values->>'success')::int as success_count,
    (new_values->>'failed')::int as failed_count,
    (new_values->>'total_spent')::decimal as total_amount_kzt,
    new_values->'details' as failure_reasons
from audit_log
where table_name = 'batch_salary' and action = 'REPORT';