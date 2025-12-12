-- 1
--TA
-- Problem: no need to do rollback to savepoint right after the savepointois created.
-- Problem: it's better to rollback to a savepoint not cancel all opertaion before one mistake, but generally it's strange to cancel the operation right after it was completed.

--2
-- Answer:
Anna 600
Boris 400
Clara 500
David 100

--3
3.1 SERIALIZABLE
3.2 READ UNCOMMITTED
3.3 REPEATABLE READ


--4
1 325
2 2824.75
3 325
4. No because we use "READ UNCOMMITTED" level of isolation and despite it being fast it is not safe, because in case some parallel transactions operating the value may change
