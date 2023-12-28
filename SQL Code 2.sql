1.2
WITH										
table1 AS										
(
SELECT
	DISTINCT customer.CustomerID,
	contact.Firstname,
	contact.LastName,
	CONCAT(contact.Firstname,
	' ' ,
	contact.LastName) AS fullname,
	CASE
		WHEN contact.title IS NULL THEN 'Dear'
		ELSE contact.title
	END AS Addressing_title,
	contact.Emailaddress,
	contact.phone,
	customer.AccountNumber,
	customer.CustomerType,
	address.city,
	(stateprovince.name) AS State,
	(countryregion.name) AS Country,
	address.AddressLine1 AS AddressLine1,
	address.AddressLine2 AS AddressLine2,
	COUNT(sales.SalesOrderID) AS number_of_orders,
	SUM(sales.totalDue) AS total_amount_of_purchases,
	MAX(DATE_TRUNC(sales.OrderDate, DAY)) AS last_order_date
FROM
	`adwentureworks_db.customer` customer
LEFT JOIN `adwentureworks_db.individual` ind
	-- to obtain FK for the contact table,LJ to keep all in customer table--										
ON
	customer.CustomerID = ind.CustomerID
LEFT JOIN `adwentureworks_db.contact` contact										
ON
	ind.ContactID = contact.ContactID
LEFT JOIN `adwentureworks_db.customeraddress` ca
	-- to obtain FK for address table--										
ON
	customer.CustomerID = ca.CustomerID
LEFT JOIN `adwentureworks_db.address` address										
ON
	ca.AddressID = address.AddressID
LEFT JOIN `adwentureworks_db.stateprovince` stateprovince										
ON
	stateprovince.StateProvinceID = address.StateProvinceID
LEFT JOIN `adwentureworks_db.countryregion` countryregion										
ON
	stateprovince.CountryRegionCode = countryregion.CountryRegionCode
LEFT JOIN `adwentureworks_db.salesorderheader` sales										
ON
	Customer.CustomerId = sales.CustomerID
INNER JOIN `adwentureworks_db.salesterritory` salesT										
ON
	customer.TerritoryID = salesT.TerritoryID
WHERE
	CustomerType = 'I'
GROUP BY
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,n 14
ORDER BY
	total_amount_of_purchases DESC										
)										
										
SELECT
	*
FROM
	table1
WHERE
	last_order_date < (
	SELECT
		DATE_SUB(MAX(last_order_date),
		INTERVAL 365 DAY)
		-- DATE_SUB subtracts 365days from the last order date ---										
	FROM
		table1										
)
ORDER BY
	total_amount_of_purchases DESC
LIMIT 200;										
