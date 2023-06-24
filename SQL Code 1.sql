WITH T1 AS(
SELECT
	LAST_DAY(DATE(OrderDate),
	MONTH) AS month_order,
	T.CountryRegionCode AS countryregcode,
	T.Name AS Region,
	COUNT(SalesOrderID) AS num_orders,
	COUNT (DISTINCT (CustomerID)) AS num_customers,
	COUNT (DISTINCT (SalesPersonID)) AS num_sales_rep,
	SUM(TotalDue) AS Total_W_tax
FROM
	`tc-da-1. adwentureworks_db.salesorderheader` S
JOIN `tc-da-1. adwentureworks_db.salesterritory` T						
ON
	T.TerritoryID = S.TerritoryID
GROUP BY
	1,
	2,
	3)															
SELECT
	month_order,
	countryregcode,
	Region,
	num_orders,
	num_customers,
	num_sales_rep,
	Total_W_tax,
	DENSE_RANK() OVER (PARTITION BY countryregcode
ORDER BY
	Total_W_tax DESC) AS sales_rank,
	SUM(Total_W_tax) OVER (PARTITION BY Region
ORDER BY
	month_order) AS cum_sum
FROM
	T1						