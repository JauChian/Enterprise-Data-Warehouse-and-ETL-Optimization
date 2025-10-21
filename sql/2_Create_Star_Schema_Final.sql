--create schema 
--dimEmployees, dimProducts,dimCustomers,dimPayments,dimTime,factOrders


CREATE TABLE dimCustomers(
customerKey				int IDENTITY(1,1)			PRIMARY KEY,
customerNumber			int							NOT NULL,
salesRepEmployeeNumber	int							DEFAULT NULL,
customerName			nvarchar(50)			 NOT NULL,
city					nvarchar(50)			 NOT NULL,
country					nvarchar(50)				 NOT NULL
);

CREATE TABLE dimPayments(
paymentKey				int IDENTITY(1,1)			PRIMARY KEY,
customerNumber			int							NOT NULL, --natural key
checkNumber				nvarchar(50)			 NOT NULL, --natural key
paymentDate				date					 NOT NULL,
amount					decimal(10,2)			 NOT NULL,
);

CREATE TABLE dimEmployees(
employeeKey				int IDENTITY(1,1)		PRIMARY KEY,
employeeNumber			int						NOT NULL,
lastName				nvarchar(50)			NOT NULL,
firstName				nvarchar(50)			NOT NULL,
city					nvarchar(50)			NOT NULL,
country					nvarchar(50)			NOT NULL
);

ALTER TABLE dimEmployees
ADD EmployeeName AS (FirstName + ' ' + LastName);



CREATE TABLE dimProducts(
ProductKey				int		IDENTITY(1,1)	PRIMARY KEY,
productName				nvarchar(70)			NOT NULL,
productCode				nvarchar(15)			NOT NULL,
productLine				nvarchar(50)			NOT NULL,
quantityInStock			smallint				NOT NULL,
buyPrice				decimal(10,2)			NOT NULL,
MSRP					decimal(10,2)			NOT NULL

);




CREATE TABLE factOrders(
productKey		int			FOREIGN KEY REFERENCES dimProducts(Productkey),
customerKey		int			FOREIGN KEY REFERENCES dimCustomers(CustomerKey),
employeeKey		int			FOREIGN KEY REFERENCES dimEmployees(employeeKey),
paymentKey		int			FOREIGN KEY REFERENCES dimPayments(paymentKey),
orderDateKey	int			FOREIGN KEY REFERENCES dimTime(TimeKey),
requiredDateKey int			FOREIGN KEY REFERENCES dimTime(TimeKey),
shippedDateKey		int			FOREIGN KEY REFERENCES dimTime(TimeKey),
status			varchar(10) NOT NULL,
orderNumber		int			NOT NULL,
quantityOrdered smallint	NOT NULL,
priceEach		money		NOT NULL,
TotalPrice		money		NOT NULL,
TotalProfit		money		NOT NULL,
TotalPossibleProfit	money	NOT NULL

PRIMARY KEY(productKey, CustomerKey,employeeKey,paymentKey,OrderDateKey)

);


