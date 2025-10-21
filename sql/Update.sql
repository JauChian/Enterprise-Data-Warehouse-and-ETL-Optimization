---------------------UPDATE

-------------------RULE 1
--if buyprice is negitive , update to positive
UPDATE dimProducts
SET buyPrice =ABS(buyPrice)
WHERE buyPrice <0;
--0 rows affect

-----------------------RULE
UPDATE dimPayments
SET amount = ABS(amount)
WHERE amount <0;


--paymentdate fix


--------------------------RULE 2
-- if priceEach is negitivie, update to positive
UPDATE factOrders
SET priceEach =ABS(priceEach)
WHERE priceEach <0;

--------------------------RULE 3
-- if quantityOrdered is negitivie, update to positive
UPDATE factOrders
SET quantityOrdered = ABS(quantityOrdered)
WHERE quantityOrdered <0;

-----------------------

----------------RULE 5
--Country checking in customers fix the county format regardless capital or non-capital cases

UPDATE dimCustomers 
SET COUNTRY = 'USA'
WHERE COUNTRY IN ('US','United States', 'UNITED STATES');
--0 row affected
UPDATE dimCustomers 
SET country = 'AU'
WHERE country IN ('Australia','australia');
-- 5 rows affected

UPDATE dimCustomers 
SET COUNTRY = 'NZ'
WHERE COUNTRY IN ('New Zealand');
--4 rows affected


-----------------RULE 5
--Country checking in offices fix the county format regardless capital or non-capital cases

UPDATE dimEmployees 
SET COUNTRY = 'USA'
WHERE COUNTRY IN ('US','United States', 'UNITED STATES');
-- o row affected
UPDATE dimEmployees
SET country = 'AU'
WHERE country IN ('Australia','australia');
-- 6 rows affected
UPDATE dimEmployees
SET COUNTRY = 'NZ'
WHERE COUNTRY IN ('New Zealand')
--4 rows affected


---------------- RULE8
--requiredDate,shippedDate checking in orders if orderDate greater than requiredDate, fix if requiredDate null replace orderDate +7

UPDATE f
SET f.requiredDateKey = (
    SELECT dt2.TimeKey
    FROM dimTime dt2
    WHERE dt2.Date = DATEADD(DAY, 7, dt1.Date)
)
FROM factOrders f
INNER JOIN dimTime dt1 ON dt1.TimeKey = f.orderDateKey
WHERE dt1.Date > (
    SELECT dt2.Date
    FROM dimTime dt2
    WHERE dt2.TimeKey = f.requiredDateKey
);

------------- RULE 8
-- if orderDate greater than shippedDate Fix if shippedDate null replace orderDate+2, if Status is ='Shipped'
UPDATE f
SET f.shippedDateKey = (
    SELECT dt3.TimeKey
    FROM dimTime dt3
    WHERE dt3.Date = DATEADD(DAY, 2, dt1.Date)
)
FROM factOrders f
INNER JOIN dimTime dt1 ON dt1.TimeKey = f.orderDateKey
WHERE dt1.Date > (
    SELECT dt3.Date
    FROM dimTime dt3
    WHERE dt3.TimeKey = f.shippedDateKey
);
