--TABLE CREATION
--using id serial as primary key to create a unique id for every row


CREATE TABLE SalesTransactions (
Id SERIAL PRIMARY KEY,
TransactionNo BIGINT NOT NULL,
Dates DATE NOT NULL,
ProductNo VARCHAR (100) NOT NULL,
ProductName VARCHAR (255) NOT NULL,
Price NUMERIC(12, 2) NOT NULL,
Quantity INT NOT NULL,
CustomerNo BIGINT NOT NULL,
Country VARCHAR(100) NOT NULL
);

--CHECKING NEGATIVE QUANTITIES(RETURNS)

SELECT COUNT (*) AS Returns_count
FROM SalesTransactions
WHERE Quantity<0;


--FINDING SUSPICIOUS PRICES

SELECT *
FROM SalesTransactions
WHERE Price<=0 OR Price>10000
ORDER BY Price DESC
LIMIT 50;

--CHECKING FOR DUPLICATES

SELECT TransactionNo, COUNT(*) AS cnt
FROM SalesTransactions
GROUP BY TransactionNo
HAVING COUNT(*) >1


--CREATION OF REVENUE FIELD

ALTER TABLE SalesTransactions ADD COLUMN Revenue NUMERIC(14,2);
UPDATE SalesTransactions SET Revenue = Price * Quantity;


--CUSTOMER TRANSACTION COUNT
SELECT CustomerNo,
	   COUNT(*) AS TransactionCount
FROM SalesTransactions
GROUP BY CustomerNo
ORDER BY TransactionCount DESC;



--BUSINESS QUESTIONS

--Top 20customers by revenue

SELECT 
	CustomerNo,
	SUM(Revenue) AS Total_revenue,
	COUNT(DISTINCT TransactionNo) AS Total_transactions,
	SUM(Quantity) AS Total_quantity_purchased
FROM SalesTransactions
GROUP BY CustomerNo
ORDER BY Total_revenue DESC
LIMIT 20;



--customer purchase frequency distribution

WITH Customer_freq AS (
				SELECT CustomerNo, COUNT(DISTINCT TransactionNo) AS Purchase_count
				FROM SalesTransactions
				GROUP BY CustomerNo
)
SELECT Purchase_count, COUNT(*) AS number_of_customers
FROM Customer_freq
GROUP BY Purchase_count
ORDER BY Purchase_count;



--best performing product by revenue

SELECT ProductName, ProductNo, SUM(Revenue) AS TotalRevenue
FROM SalesTransactions
GROUP BY ProductName, ProductNo
ORDER BY TotalRevenue DESC;


--worst performing product by revenue

SELECT ProductName, ProductNo, SUM(Revenue) AS TotalRevenue
FROM SalesTransactions
GROUP BY ProductName, ProductNo
ORDER BY TotalRevenue ASC;



--Worst performing product by quantity

SELECT ProductName, ProductNo, SUM(Quantity) AS Total_quantity_sold
FROM SalesTransactions
GROUP BY ProductName, ProductNo
ORDER BY Total_quantity_sold ASC
LIMIT 20;


--best product by quantity

SELECT ProductName, ProductNo, SUM(Quantity) AS Total_quantity_sold
FROM SalesTransactions
GROUP BY ProductName, ProductNo
ORDER BY Total_quantity_sold DESC
LIMIT 20;


--Highest Average transaction value

SELECT ProductName,
		ProductNo, 
		SUM(Revenue) AS Total_revenue,
		COUNT (DISTINCT TransactionNo) AS Transaction_count,
		ROUND(SUM(Revenue) / NULLIF(COUNT(DISTINCT TransactionNo), 0),
		2
		) AS Average_transaction_value
FROM SalesTransactions
GROUP BY ProductName, ProductNo
ORDER BY Average_transaction_value DESC
LIMIT 20;


--lowest average transaction value

SELECT ProductName,
		ProductNo, 
		SUM(Revenue) AS Total_revenue,
		COUNT (DISTINCT TransactionNo) AS Transaction_count,
		ROUND(SUM(Revenue) / NULLIF(COUNT(DISTINCT TransactionNo), 0),
		2
		) AS Average_transaction_value
FROM SalesTransactions
GROUP BY ProductName, ProductNo
HAVING COUNT(DISTINCT TransactionNo) >=5     --enforcing minimum threshold
ORDER BY Average_transaction_value ASC
LIMIT 20;



--product performance overtime

SELECT ProductNo,
	   ProductName,
	   DATE_TRUNC ('Month', Dates) AS Month,
	   SUM(Revenue) AS Monthly_revenue,
	   SUM(Quantity) AS Monthly_quantity
FROM SalesTransactions
GROUP BY ProductNo, ProductName, DATE_TRUNC ('Month', Dates)
ORDER BY ProductNo, Month;



--Yearly trend

SELECT EXTRACT(YEAR FROM Dates) AS Year,
	   SUM(Revenue) AS Total_revenue,
	   SUM (Quantity) AS Total_quantity
FROM SalesTransactions
GROUP BY Year
ORDER BY Year;



--Quartely trend

SELECT EXTRACT(YEAR FROM Dates) AS Year,
	   EXTRACT(QUARTER FROM Dates) AS Quarter,
	   SUM(Revenue) AS Total_revenue,
	   SUM (Quantity) AS Total_quantity
FROM SalesTransactions
GROUP BY Year, Quarter
ORDER BY Year, Quarter;



--running totals

WITH Daily AS (
		SELECT Dates AS day, SUM (Revenue) AS Day_revenue
		FROM SalesTransactions
		GROUP BY Dates
)
SELECT
	Day,
	Day_revenue,
	SUM (Day_revenue) OVER (ORDER BY Day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_revenue
FROM Daily
ORDER BY Day;


--moving average

WITH Monthly AS (
	SELECT DATE_TRUNC ('Month', Dates) AS Month_start,
	SUM(Revenue) AS Month_revenue
	FROM SalesTransactions
	GROUP BY DATE_TRUNC('Month', Dates)
)
SELECT 
Month_start,
Month_revenue,
ROUND(
	AVG(Month_revenue) OVER (
		ORDER BY Month_start
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	),2
 )AS Moving_average_3_month
 FROM Monthly
 ORDER BY Month_start;

 

--country-wise sales performance ranking

SELECT Country,
	SUM(Revenue) AS TotalRevenue,
	SUM (Quantity) AS Total_quantity,
	COUNT (DISTINCT CustomerNo) AS Unique_customers
FROM SalesTransactions
GROUP BY Country
ORDER BY TotalRevenue DESC;



--market penetration analysys by country

WITH Country_customers AS (
	SELECT Country, COUNT (DISTINCT CustomerNo) AS Unique_customers
	FROM SalesTransactions
	GROUP BY Country
), Total_customers AS (
	SELECT COUNT(DISTINCT CustomerNo) AS Total_unique_customers
	FROM SalesTransactions
)
SELECT
	C.Country,
	C.Unique_customers,
	ROUND(100.0 * C.Unique_customers / T.Total_unique_customers, 2) AS Percentage_of_customers
FROM Country_customers C
CROSS JOIN Total_customers T
ORDER BY Unique_customers DESC;













