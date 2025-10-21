--populating

SELECT*FROM dimCustomers
SELECT*FROM dimEmployees
SELECT*FROM dimPayments
SELECT*FROM dimProducts
SELECT*FROM factOrders
--populating dimcustomers table

MERGE INTO dimCustomers AS dc
USING
(
	SELECT 
	c.customerNumber,
	c.salesRepEmployeeNumber,
		c.customerName,
		c.city, 
		c.country
	FROM saleAU_NZ.dbo.Customer AS c
 	WHERE  c.%%physloc%% NOT IN(
		SELECT ROWID
		FROM DQLOG
		WHERE
       DBName ='saleAU_NZ'
	   AND TableName = 'customer'
	   AND RuleNo =7
	   AND Action = 'Reject'
          )
	)AS c ON dc.customerNumber = c.customerNumber -- assume customerNumber is unique
	WHEN MATCHED THEN --if customerNumber matched, do nothing
		UPDATE SET 
		dc.customerNumber = c.customerNumber --dummy update	
	WHEN NOT MATCHED THEN
		INSERT
		(customerNumber,salesRepEmployeeNumber,
		customerName,city, country)
		VALUES 
		(c.customerNumber,c.salesRepEmployeeNumber,
		c.customerName,c.city, c.country
		);

----Do the fix by writing a sepearate sql statment(after merge)
-- 9 rows affected


--count testing--
select COUNT(*)
from dimCustomers
SELECT COUNT(*)
FROM saleAU_NZ.dbo.Customer 

-------------------------



MERGE INTO dimEmployees AS de
USING
(		
		SELECT
		e.employeeNumber,
		e.firstName , e.LastName ,
		o.City,
		o.Country

		FROM saleAU_NZ.dbo.employee AS e
		INNER JOIN
		saleAU_NZ.dbo.office AS o ON o.officeCode = e.officeCode
		WHERE e.officeCode = o.officeCode
		)
		AS e ON(de.employeeNumber =e.employeeNumber)  --assume employeenumber is unique
		WHEN MATCHED THEN --if employeenumber matched, do notih
			UPDATE SET
			de.employeeNumber =e.employeeNumber --dummy update
		WHEN NOT MATCHED THEN
			INSERT
			(employeeNumber,lastName,firstName,city,country)
			VALUES
			(e.employeeNumber,e.lastName,e.firstName,e.City,e.Country);

----------------------
----------------10 rows affected

--count testing--
select COUNT(*)
from dimEmployees
SELECT COUNT(*)
FROM saleAU_NZ.dbo.employee 

----------------------


MERGE INTO dimProducts AS dp
USING
(
	SELECT 
	p.productCode, 
	p.ProductName,
	p.ProductLine,
	p.quantityInStock,
	p.buyPrice,
	p.MSRP

	FROM saleAU_NZ.dbo.product AS p
	INNER JOIN 
	saleAU_NZ.dbo.productLine AS pl ON pl.productLine =p.productLine
	WHERE 
	p.%%physloc%% NOT IN(
		SELECT ROWID
		FROM DQLOG
		WHERE 
		DBName = 'saleAU_NZ'
		AND TableName = 'product'
		AND RuleNo IN(1,4) 
		AND Action = 'Reject')
) AS p ON (dp.productCode = p.productCode)
WHEN MATCHED THEN --if employeenumber matched, do notih
			UPDATE SET
			dp.productCode = p.productCode
WHEN NOT MATCHED THEN
	INSERT
	(productCode,productName,productLine,
		quantityInStock,buyPrice,MSRP)
	VALUES
	(p.productCode,p.ProductName,p.productLine,
		p.quantityInStock,p.buyPrice,p.MSRP);

--109 row affected
----------------------------------update

--count testing
SELECT COUNT(*)
FROM dimProducts

SELECT COUNT(*)
FROM saleAU_NZ.dbo.product 

-----

MERGE INTO dimPayments AS dm
USING
(   
    SELECT
        m.customerNumber,
        m.checkNumber,
        m.paymentDate,
        m.amount
    FROM saleAU_NZ.dbo.payment AS m
    WHERE m.%%physloc%% NOT IN (
            SELECT ROWID
            FROM DQLOG
            WHERE  
              DBName = 'saleAU_NZ'
			  AND TableName = 'payment'
			  AND RuleNo IN(9,10)
			  AND Action = 'Reject'
        )
) AS m ON (dm.checkNumber = m.checkNumber) 

WHEN MATCHED THEN
    UPDATE SET
       dm.paymentDate = m.paymentDate

WHEN NOT MATCHED THEN
    INSERT
    (
        customerNumber, checkNumber,paymentDate, amount
    )
    VALUES
    (
        m.customerNumber, m.checkNumber, m.paymentDate, m.amount
    );

--5 row affected
--count testing

SELECT COUNT(*) AS dimpayments
FROM dimPayments

SELECT COUNT(*) AS payment
FROM saleAU_NZ.dbo.payment 


-----------------------------------------------
USE test2
MERGE INTO factOrders AS fo
USING
(	
	SELECT productKey,customerKey,employeeKey,paymentKey,
			dt1.TimeKey as [orderDateKey],
			dt2.TimeKey as [requiredDateKey],
			dt3.TimeKey as [shippedDateKey],
			po.Status,
			po.orderNumber,
			QuantityOrdered,
			priceEach,
	--calculation
			(od.QuantityOrdered *od.PriceEach) as[TotalPrice], 
			(od.QuantityOrdered *(od.PriceEach -dp.buyPrice)) as [TotalProfit],
			(od.QuantityOrdered * (dp.MSRP -dp.BuyPrice)) as [TotalPossibleProfit]
	FROM saleAU_NZ.dbo.productOrder po 
		INNER JOIN saleAU_NZ.dbo.OrderDetail od ON po.OrderNumber = od.orderNumber
		INNER JOIN dimCustomers dc ON po.CustomerNumber = dc.CustomerNumber
		INNER JOIN dimProducts dp ON od.productCode = dp.productCode
		INNER JOIN dimPayments dm ON dc.customerNumber = dm.customerNumber
		INNER JOIN dimEmployees de ON de.employeeNumber = dc.salesRepEmployeeNumber
		INNER JOIN dimTime dt1 ON dt1.Date = po.OrderDate
		INNER JOIN dimTime dt2 ON dt2.Date = po.RequiredDate
		INNER JOIN dimTime dt3 ON dt3.Date = po.shippedDate
	WHERE od.productCode =dp.productCode  --connect orderdetail & product
		AND od.orderNumber = po.OrderNumber 
		AND po.customerNumber = dc.customerNumber
		AND dm.customerNumber =dc.customerNumber
		AND de.employeeNumber = dc.salesRepEmployeeNumber
		AND dc.customerNumber = dm.customerNumber
		AND dp.productCode = od.productCode
		AND dt1.Date =po.OrderDate
		AND dt2.Date =po.RequiredDate --three dimTime tables
		AND dt3.Date = po.ShippedDate
		AND od.%%physloc%% NOT IN(
			SELECT ROWID
			FROM DQLOG
			WHERE 
				DBName = 'sale_AU_NZ'
				AND TableName ='orderDetail'
				AND RuleNo in(2,3,6)
				AND Action = 'Reject'
			)
	) AS po ON (fo.productKey = po.productKey
            AND fo.customerKey = po.customerKey
			AND fo.employeeKey = po.employeekey
			AND fo.paymentKey = po.paymentKey
            AND fo.OrderDateKey = po.OrderDateKey)
	WHEN MATCHED THEN
	UPDATE SET fo.orderNumber = po.OrderNumber
	WHEN NOT MATCHED THEN
	INSERT (productKey, customerKey,employeeKey,paymentKey, orderDateKey, requiredDateKey,shippedDateKey,Status,
            orderNumber,QuantityOrdered,
			priceEach, TotalPrice,totalProfit,totalPossibleProfit)
VALUES (po.productKey, po.customerKey,po.employeeKey,po.paymentKey, po.OrderDateKey, po.RequiredDateKey,po.shippedDateKey,po.Status,
        po.OrderNumber,po.QuantityOrdered,
		po.priceEach, po.TotalPrice,po.totalProfit,po.totalPossibleProfit);

------------
--95 rows affected




--------------------------------requiredate Checking if it has any left data behind
use test2
SELECT 
    fo.customerKey,
	dt1.date AS orderdate,
	dt2.date As requiredDate
FROM 
    factorders fo
INNER JOIN 
    dimTime dt1 ON dt1.TimeKey = fo.orderDateKey
INNER JOIN 
    dimTime dt2 ON dt2.TimeKey = fo.requiredDateKey
WHERE 
  dt1.date > dt2.date

---------------------------shippedDate if it has any left data behind
-------------------


SELECT 
    fo.customerKey,
	dt1.date AS orderdate,
	dt3.date As shippedDate
FROM 
    factorders fo
INNER JOIN 
    dimTime dt1 ON dt1.TimeKey = fo.orderDateKey
INNER JOIN 
    dimTime dt3 ON dt3.TimeKey = fo.shippedDatekey
WHERE 
    dt1.date > dt3.date 


----------------------------------------------- below two was dt1> dt2
SELECT
    fo.orderdatekey,
    fo.requiredDateKey,
    dt1.date AS OrderDateTime,
    dt2.date AS RequiredDateTime
FROM
    factOrders fo
JOIN
    dimTime dt1 ON fo.orderdatekey = dt1.timeKey
JOIN
    dimTime dt2 ON fo.requiredDateKey = dt2.timeKey
where  orderdatekey = 187

SELECT
    fo.orderdatekey,
    fo.requiredDateKey,
    dt1.date AS OrderDateTime,
    dt2.date AS RequiredDateTime
FROM
    factOrders fo
JOIN
    dimTime dt1 ON fo.orderdatekey = dt1.timeKey
JOIN
    dimTime dt2 ON fo.requiredDateKey = dt2.timeKey
where  orderdatekey = 749
----------------------------------------

------------------------------------------------------------------------------------------------

SELECT*FROM factOrders

SELECT COUNT(*)
FROM factOrders f
INNER JOIN dimCustomers AS dc ON dc.customerKey = f.customerKey
INNER JOIN dimEmployees AS de ON de.employeeKey = f.employeeKey
INNEr JOIN dimPayments AS dm ON dm.paymentKey = f.paymentKey
INNER JOIN dimProducts AS dp ON dp.ProductKey = f.paymentKey
INNER JOIN dimTime AS dt1 ON dt1.TimeKey = f.orderDateKey
INNER JOIN dimTime AS dt2 ON dt2.TimeKey = f.requiredDateKey
INNER JOIN dimTime AS dt3 ON dt3.TimeKey = f.shippedDateKey


SELECT COUNT(*)
FROM saleAU_NZ.dbo.productorder AS po
INNER JOIN saleAU_NZ.dbo.orderdetail  AS od ON od.orderNumber = po.orderNumber
INNER JOIN saleAU_NZ.dbo.product AS p ON p.productCode = od.productCode
INNER JOIN saleAU_NZ.dbo.customer AS c ON c.customerNumber = po.customerNumber
INNER JOIN saleAU_NZ.dbo.payment AS m on m.customerNumber= c.customerNumber
INNER JOIN saleAU_NZ.dbo.employee AS e ON e.employeeNumber = c.salesRepEmployeeNumber
INNER JOIN saleAU_NZ.dbo.office AS o ON o.officeCode = e.officeCode
WHERE  od.orderNumber= po.OrderNumber
