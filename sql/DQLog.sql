--DQLOG
--create
/*CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    WHEN conditionN THEN resultN
    ELSE result
END;*/
DROP TABLE DQLog;

CREATE TABLE DQLog
(
LogID 		int PRIMARY KEY IDENTITY,
RowID 		varbinary(32),		-- This is a physical address of a row stored on a disk and it is UNIQUE
DBName 		nchar(20),
TableName	nchar(20),
RuleNo		smallint,
Action		nchar(6) CHECK (action IN ('allow','fix','reject')) -- Action can be ONLY 'allow','fix','reject'
);

select*from DQLog
--physical address and DQLog Table


--DQ Checking and Logging
-------------------------------------------RULE NO 1------------------------------------------------------
--rule 1 Buyprice checking in products reject rule 1 0 or NULL


--if then condition
INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','product',1,
CASE 
	WHEN buyPrice = 0 OR buyPrice IS NULL THEN 'Reject'
	WHEN buyprice < 0 THEN 'FIX'
END
FROM saleAU_NZ.dbo.product
WHERE buyPrice <=0 or buyPrice IS NULL;  


-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check
--Rule No 1 Fix
SELECT *
FROM saleAU_NZ.dbo.product p
WHERE p.%%physloc%% =0x4002000001000E00;



-------------------------------------------RULE NO 2------------------------------------------------------
--rule 2 priceEach checking in orderdetails reject rule 2 0 or NULL


-- If Then
INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','Orderdetail',2,
CASE 
	WHEN priceEach = 0 OR priceEach IS NULL THEN 'Reject'
	WHEN priceEach < 0 THEN 'FIX'
END
FROM saleAU_NZ.dbo.orderdetail
WHERE priceEach <=0 or priceEach IS NULL;  



-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check
--Rule No 2 OrderDetail
--no result
SELECT *
FROM saleAU_NZ.dbo.orderdetail od


-------------------------------------------RULE NO 3------------------------------------------------------
--rule 3 QuantityOrder checking in OrderDetails Reject if quantityOrdered is null or 0 , 
--Fix is negative , need to convert to positive


INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','Orderdetail',3,
CASE 
	WHEN quantityOrdered = 0 OR quantityOrdered IS NULL THEN 'Reject'
	WHEN quantityOrdered < 0 THEN 'FIX'
END
FROM saleAU_NZ.dbo.orderdetail
WHERE quantityOrdered <=0 or quantityOrdered IS NULL;  




-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check
--Rule No 3 OrderDetail
--no result


-------------------------------------------RULE NO 4------------------------------------------------------
--rule 4 MSRP checking in product rejct rule 4 MSRP <buyPrice

INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','product',4,'Reject'
FROM saleAU_NZ.dbo.product
WHERE MSRP < buyPrice; 


-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check
-- Rule NO 4 product
SELECT *
FROM saleAU_NZ.dbo.product p
WHERE p.%%physloc%% =0x4002000001000800;


SELECT ROWID
        FROM DQLOG
SELECT*FROM DQLOG
SELECT ROWID
        FROM DQLOG
        WHERE 
        DBName = 'saleAU_NZ'
-------------------------------------------RULE NO 5------------------------------------------------------
--rule 5 Country checking in customers and offices fix 
--the county format regardless capital or non-capital cases

INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','Customer',5,'Fix'
FROM saleAU_NZ.dbo.customer 
WHERE Country IN ('US','United States', 'UNITED STATES', 'Australia','New Zealand')

INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','Office',5,'Fix'
FROM saleAU_NZ.dbo.office
WHERE  Country IN ('US','United States', 'UNITED STATES', 'Australia','New Zealand')

-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check
--Rule No 5 customer
SELECT *
FROM saleAU_NZ.dbo.customer p
WHERE p.%%physloc%% =0x1802000001000000;
SELECT *
FROM saleAU_NZ.dbo.customer p
WHERE p.%%physloc%% =0x1802000001000100;
SELECT *
FROM saleAU_NZ.dbo.customer p
WHERE p.%%physloc%% =0x1802000001000200;
SELECT *
FROM saleAU_NZ.dbo.customer p
WHERE p.%%physloc%% =0x1802000001000300;
SELECT *
FROM saleAU_NZ.dbo.customer p
WHERE p.%%physloc%% =0x1802000001000400;
SELECT *
FROM saleAU_NZ.dbo.customer p
WHERE p.%%physloc%% =0x1802000001000500;
SELECT *
FROM saleAU_NZ.dbo.customer p
WHERE p.%%physloc%% =0x1802000001000600;
SELECT *
FROM saleAU_NZ.dbo.customer p
WHERE p.%%physloc%% =0x1802000001000700;
SELECT *
FROM saleAU_NZ.dbo.customer p
WHERE p.%%physloc%% =0x1802000001000800;


-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check
--Rule No 5 office
SELECT *
FROM saleAU_NZ.dbo.office o
WHERE o.%%physloc%% =0x0802000001000000;
SELECT *
FROM saleAU_NZ.dbo.office o
WHERE o.%%physloc%% =0x0802000001000100;
SELECT *
FROM saleAU_NZ.dbo.office o
WHERE o.%%physloc%% =0x0802000001000200;
SELECT *
FROM saleAU_NZ.dbo.office o
WHERE o.%%physloc%% =0x0802000001000300;


-------------------------------------------RULE NO 6------------------------------------------------------
--rule 6 ProductCode checking in order detail reject 
--if productcode doesn't exist or is null


INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','orderDetail',6,'Reject'
FROM saleAU_NZ.dbo.orderdetail
WHERE productCode IS NULL OR productCode NOT IN 
		(SELECT productCode
		FROM saleAU_NZ.dbo.product);
		
-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check
--Rule No 6 OrderDetail
--NONE


-------------------------------------------RULE NO 7------------------------------------------------------
--rule 7 customerNumber address1, address2, and city checking in customer reject 
--if(customerNumber doesn't exist or is null) and (if any of: addressLine1, addressLine2
--and city are null)



INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','customer',7,'Reject'
FROM saleAU_NZ.dbo.customer
WHERE (customerNumber IS NULL or customerNumber NOT IN
	(SELECT customerNumber FROM saleAU_NZ.dbo.customer))
	AND (addressLine1 IS NULL OR addressLine2 IS NULL OR CITY IS NULL);


-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check
--Rule No 7
--none


-------------------------------------------RULE NO 8------------------------------------------------------
--rule 8 requiredDate,shippedDate checking in orders 
--if orderDate greater than requiredDate, fix if requiredDate null replace orderDate +7
--if orderDate greater than shippedDate Fix if shippedDate null replace orderDate+2 and Status is ='Shipped'

select orderdate
from saleAU_NZ.dbo.productorder

INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','productOrder',8,'Fix'
from saleAU_NZ.dbo.productorder 
where  (orderDate > requiredDate) or requiredDate IS NULL;

INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','productOrder',8,'Fix'
FROM saleAU_NZ.dbo.productorder
WHERE orderDate > shippedDate or (shippedDate IS NULL and status='Shipped');


--function ABS /absolute positive valuequantity
/* later
UPDATE saleAU_NZ.dbo.productOrder
SET requiredDate =ABS(requiredDate)
WHERE requiredDate <0;
*/

SELECT ROWID
        FROM DQLOG
SELECT ROWID
        FROM DQLOG
        WHERE 
        DBName = 'saleAU_NZ'
-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check



SELECT*FROM DQLog
SELECT *
FROM saleAU_NZ.dbo.productorder po
WHERE po.%%physloc%% =0x2002000001000200;
SELECT *
FROM saleAU_NZ.dbo.productorder po
WHERE po.%%physloc%% =0x2002000001000A00;
SELECT *
FROM saleAU_NZ.dbo.productorder po
WHERE po.%%physloc%% =0x2002000001000D00;

-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check

SELECT *
FROM saleAU_NZ.dbo.productorder po
WHERE po.%%physloc%% =0x2002000001000F00;



/*
UPDATE saleAU_NZ.dbo.productorder
SET shippedDate = DATEADD(DAY,2,orderDate)
WHERE shippedDate IS NULL;
	AND status = 'Shipped'
*/



-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check
-- RULE NO 8
--------------none


-------------------extra two DQ
--if amount is = 0 or null 'Reject
--if amount is negative 'fix

INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT		%%physloc%%, 'saleAU_NZ','payment',9,
CASE 
	WHEN amount = 0 OR amount IS NULL THEN 'Reject'
	WHEN amount < 0 THEN 'FIX'
END
FROM saleAU_NZ.dbo.payment
WHERE amount <=0 or amount IS NULL;  

--function ABS /absolute positive valuequantity
/* later
UPDATE saleAU_NZ.dbo.payment
SET amount =ABS(amount)
WHERE amount <0;
*/

--if paymentdate < orderdate 'Reject'

INSERT INTO DQLog(RowID,DBName,TableName,RuleNo,Action)
SELECT	DISTINCT	m.%%physloc%%,  'saleAU_NZ','payment',10,'Reject'
FROM saleAU_NZ.dbo.payment m
INNER JOIN saleAU_NZ.dbo.customer c ON c.customerNumber = m.customerNumber
INNER JOIN saleAU_NZ.dbo.productorder po ON po.customerNumber = c.customerNumber
WHERE po.orderDate> m.paymentDate


SELECT *
FROM saleAU_NZ.dbo.payment m
WHERE m.%%physloc%% =0x5002000001001000;



-------------------------------------------------------------------------------------------Logging check
-------------------------------------------------------------------------------------------Logging check

SELECT  *FROM DQLog
----------------------------Summary Table-------------------------------------------------
 SELECT        TableName, RuleNo, action, COUNT(*) as TotalRecords 
 FROM        DQLog
 GROUP BY    TableName, RuleNo, action;


-- ************************************************************************************************************
-- Logging check
-- ************************************************************************************************************
-- RowID				| 	DB NAME		TableName		Rule No			Action		
-- ************************************************************************************************************
--1	0x4002000001000E00	saleAU_NZ           	product             	1	FIX   
--2	0x4002000001000800	saleAU_NZ           	product             	4	Reject
--3	0x1802000001000000	saleAU_NZ           	Customer            	5	Fix   
--4	0x1802000001000100	saleAU_NZ           	Customer            	5	Fix   
--5	0x1802000001000200	saleAU_NZ           	Customer            	5	Fix   
--6	0x1802000001000300	saleAU_NZ           	Customer            	5	Fix   
--7	0x1802000001000400	saleAU_NZ           	Customer            	5	Fix   
--8	0x1802000001000500	saleAU_NZ           	Customer            	5	Fix   
--9	0x1802000001000600	saleAU_NZ           	Customer            	5	Fix   
--10	0x1802000001000700	saleAU_NZ           	Customer            	5	Fix   
--11	0x1802000001000800	saleAU_NZ           	Customer            	5	Fix   
--12	0x0802000001000000	saleAU_NZ           	Office              	5	Fix   
--13	0x0802000001000100	saleAU_NZ           	Office              	5	Fix   
--14	0x0802000001000200	saleAU_NZ           	Office              	5	Fix   
--15	0x0802000001000300	saleAU_NZ           	Office              	5	Fix   
--16	0x2002000001000200	saleAU_NZ           	productOrder        	8	Fix   
--17	0x2002000001000A00	saleAU_NZ           	productOrder        	8	Fix   
--18	0x2002000001000D00	saleAU_NZ           	productOrder        	8	Fix   
--19	0x2002000001000F00	saleAU_NZ           	productOrder        	8	Fix   
--20	0x5002000001000000	saleAU_NZ           	payment             	10	Reject
--21	0x5002000001000200	saleAU_NZ           	payment             	10	Reject
--22	0x5002000001000300	saleAU_NZ           	payment             	10	Reject
--23	0x5002000001000400	saleAU_NZ           	payment             	10	Reject
--24	0x5002000001000500	saleAU_NZ           	payment             	10	Reject
--25	0x5002000001000600	saleAU_NZ           	payment             	10	Reject
--26	0x5002000001000800	saleAU_NZ           	payment             	10	Reject
--27	0x5002000001000900	saleAU_NZ           	payment             	10	Reject
--28	0x5002000001000A00	saleAU_NZ           	payment             	10	Reject
--29	0x5002000001000C00	saleAU_NZ           	payment             	10	Reject
--30	0x5002000001000E00	saleAU_NZ           	payment             	10	Reject
--31	0x5002000001000F00	saleAU_NZ           	payment             	10	Reject
--32	0x5002000001001000	saleAU_NZ           	payment             	10	Reject
--33	0x5002000001001100	saleAU_NZ           	payment             	10	Reject
--34	0x5002000001001200	saleAU_NZ           	payment             	10	Reject
--35	0x5002000001001300	saleAU_NZ           	payment             	10	Reject
--36	0x5002000001001500	saleAU_NZ           	payment             	10	Reject
--37	0x5002000001001600	saleAU_NZ           	payment             	10	Reject
--
-- **********************************************************************************************************
-- Total Allow  0
-- Total Fix 	18
-- Total Reject	19
-- ***********************************************************************************************************