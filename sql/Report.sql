--------------1.	Monthly sales and profit/loss report for each product line. 

SELECT 
    dp.productLine AS ProductLine,
    COUNT(*) AS NumberOfProducts,
    SUM(fO.quantityOrdered) AS TotalSales,
    SUM(fO.TotalProfit) AS TotalProfitLoss,
	dt.Month,dt.Year
FROM 
    factOrders fO
JOIN 
    dimProducts dp ON fO.productKey = dp.ProductKey
JOIN
	dimTime dt ON dt.TimeKey = fo.orderDateKey
GROUP BY 
    dp.productLine, dt.Month, dt.Year
ORDER BY 
    TotalProfitLoss DESC;
----------------------------------------------------------------------
------------------------------2.	Monthly report on the most profitable employees. 

SELECT 
    de.EmployeeName AS EmployeeName,
    de.city AS City,
    de.country AS Country,
    COUNT(*) AS TotalCustomers,
    COUNT(*) AS TotalPayments,
    SUM(fo.TotalProfit) AS TotalProfit,
	dt.Month,dt.Year
FROM 
    factOrders fo
JOIN 
    dimEmployees de ON fo.employeeKey = de.employeeKey
LEFT JOIN 
    dimCustomers dc ON fo.customerKey = dc.customerKey
LEFT JOIN 
    dimPayments dp ON dc.customerNumber = dp.customerNumber
JOIN
	dimTime dt ON dt.TimeKey = fo.orderDateKey
GROUP BY 
    de.EmployeeName, de.city, de.country, dt.Month, dt.Year
ORDER BY 
    TotalProfit DESC;
----------------------------------------------------
--------------------------3.	Summary report on the total sales based on City. 
SELECT 
    dc.city AS City,
    dc.country AS Country,
    COUNT(DISTINCT fo.productKey) AS TotalProductsSold,
    COUNT(DISTINCT dp.productLine ) AS TotalProductCategoriesSold,
    COUNT(DISTINCT fo.customerKey) AS TotalCustomers,
    SUM(fo.TotalPrice) AS TotalSales
FROM 
    factOrders fo
JOIN 
    dimCustomers dc ON fo.customerKey = dc.customerKey
JOIN 
    dimProducts dp ON fo.productKey = dp.ProductKey
GROUP BY 
    dc.city, dc.country
ORDER BY 
    TotalSales DESC;


	-------------------------------------------
	----------4.	Monthly report on the customers who have bought the most. 
SELECT 
    dc.customerName AS CustomerName,
    COUNT(*) AS TotalProductsBought,
    COUNT(*) AS TotalProductCategoriesBought,
    SUM(fo.TotalPrice) AS TotalSales,
    SUM(fo.TotalProfit) AS TotalProfitLoss,
	dt.Month,dt.Year
FROM 
    factOrders fo
JOIN 
    dimCustomers dc ON fo.customerKey = dc.customerKey
JOIN 
    dimProducts dp ON fo.productKey = dp.ProductKey
JOIN
	dimTime dt ON dt.TimeKey = fo.orderDateKey
GROUP BY 
    dc.customerName, dt.Month, dt.Year
ORDER BY 
    TotalProfitLoss DESC;

	-------------------------------------------
	-----------5.	Monthly sales report that list and comparer of Total-Profit with Total-Possible-Profit for each product line.
SELECT 
    dp.productLine AS ProductLine,
    COUNT(*) AS TotalProductsSold,
    SUM(fo.TotalPrice) AS TotalSales,
    SUM(fo.TotalProfit) AS TotalProfit,
    SUM(fo.TotalPossibleProfit) AS TotalPossibleProfit,
    SUM(fo.TotalProfit - fo.TotalPossibleProfit) AS ProfitDifference,
	dt.Month,dt.Year
FROM 
    factOrders fo
JOIN 
    dimProducts dp ON fo.productKey = dp.ProductKey
JOIN
	dimTime dt ON dt.TimeKey = fo.orderDateKey
GROUP BY 
    dp.productLine, dt.Month, dt.Year
ORDER BY 
    TotalProfit DESC;
