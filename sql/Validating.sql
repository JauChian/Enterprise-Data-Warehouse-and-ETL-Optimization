-----------------------=============Validating Customer=============
SELECT *
FROM dimCustomers dc
WHERE dc.customerNumber NOT IN
(
    SELECT c.customerNumber
    FROM saleAU_NZ.dbo.customer c
);
-------------------------------0
SELECT *
FROM dimCustomers dc
WHERE dc.customerNumber  IN
(
    SELECT c.customerNumber
    FROM saleAU_NZ.dbo.customer c
);
------------------------9
--------------------------------------
------------------------=============Validating employee=============
SELECT *
FROM dimEmployees de
WHERE de.employeeNumber NOT IN
(	
	SELECT e.employeeNumber
	FROM saleAU_NZ.dbo.employee e
	);
---------------------------------0
SELECT *
FROM dimEmployees de
WHERE de.employeeNumber IN
(	
	SELECT e.employeeNumber
	FROM saleAU_NZ.dbo.employee e
	);
-----------------------------10
-----------------------------============= Validating product=============
SELECT *
FROM dimProducts dc
WHERE dc.productCode NOT IN
(	
	SELECT p.productCode
	FROM saleAU_NZ.dbo.product p
	);
---------------------------------------- 0
SELECT *
FROM dimProducts dc
WHERE dc.productCode  IN
(	
	SELECT p.productCode
	FROM saleAU_NZ.dbo.product p
	);
------------------------------- 109


----------------------------============= Validating Payment=============

SELECT *
FROM dimPayments dm
WHERE dm.checkNumber NOT IN
(	
	SELECT m.checkNumber
	FROM saleAU_NZ.dbo.payment m
	);
----------------- 0
SELECT *
FROM dimPayments dm
WHERE dm.checkNumber  IN
(	
	SELECT m.checkNumber
	FROM saleAU_NZ.dbo.payment m
	);
------------------------------ 5


--------------------------------============= Validating factOrders=============
use test2


SELECT *
FROM factOrders f, dimCustomers dc, dimEmployees de,
    dimPayments dm, dimProducts dp, dimTime dt1, dimTime dt2, dimTime dt3
WHERE f.customerKey = dc.customerKey
    AND f.productKey = dp.ProductKey
    AND f.employeeKey = de.employeeKey
    AND f.paymentKey = dm.paymentKey
    AND f.orderDateKey = dt1.TimeKey
    AND f.RequiredDateKey = dt2.TimeKey
    AND f.shippedDateKey = dt3.TimeKey
    AND Not EXISTS
    (SELECT *
        FROM saleAU_NZ.dbo.productOrder po,
             saleAU_NZ.dbo.orderDetail od,
              saleAU_NZ.dbo.payment m,
               saleAU_NZ.dbo.customer c,
               saleAU_NZ.dbo.product p,
               saleAU_NZ.dbo.employee e

        WHERE 
            od.orderNumber = po.OrderNumber 
        AND od.productCode =dp.productCode
        AND po.customerNumber = dc.customerNumber
        AND dm.customerNumber =m.customerNumber
        AND de.employeeNumber = e.employeeNumber
        AND dc.customerNumber = c.customerNumber
        AND dp.productCode = p.productCode
        AND f.priceEach =od.priceEach
        AND f.quantityOrdered = od.quantityOrdered
        And f.status=po.status
        AND f.totalPrice = od.quantityOrdered * od.priceEach
        AND f.totalProfit =od.quantityOrdered*(od.priceEach-p.buyPrice)
        AND    f.totalPossibleProfit =  od.quantityOrdered*(p.MSRP-p.buyPrice)
        AND dt1.date = po.orderDate
        and dt2.date = po.requiredDate
        and dt3.date = po.shippedDate)

-------------- 21 left because of requiredate updating

SELECT *
FROM factOrders f, dimCustomers dc, dimEmployees de,
    dimPayments dm, dimProducts dp, dimTime dt1, dimTime dt2, dimTime dt3
WHERE f.customerKey = dc.customerKey
    AND f.productKey = dp.ProductKey
    AND f.employeeKey = de.employeeKey
    AND f.paymentKey = dm.paymentKey
    AND f.orderDateKey = dt1.TimeKey
    AND f.RequiredDateKey = dt2.TimeKey
    AND f.shippedDateKey = dt3.TimeKey
    AND  EXISTS
    (SELECT *
        FROM saleAU_NZ.dbo.productOrder po,
             saleAU_NZ.dbo.orderDetail od,
              saleAU_NZ.dbo.payment m,
               saleAU_NZ.dbo.customer c,
               saleAU_NZ.dbo.product p,
               saleAU_NZ.dbo.employee e

        WHERE 
            od.orderNumber = po.OrderNumber 
        AND od.productCode =dp.productCode
        AND po.customerNumber = dc.customerNumber
        AND dm.customerNumber =m.customerNumber
        AND de.employeeNumber = e.employeeNumber
        AND dc.customerNumber = c.customerNumber
        AND dp.productCode = p.productCode
        AND f.priceEach =od.priceEach
        AND f.quantityOrdered = od.quantityOrdered
        And f.status=po.status
        AND f.totalPrice = od.quantityOrdered * od.priceEach
        AND f.totalProfit =od.quantityOrdered*(od.priceEach-p.buyPrice)
        AND    f.totalPossibleProfit =  od.quantityOrdered*(p.MSRP-p.buyPrice)
        AND dt1.date = po.orderDate
        and dt2.date = po.requiredDate
        and dt3.date = po.shippedDate)
----------------------------------- 74 left