USE AdventureWorks;

-- 1. How many products can you find in the Production.Product table?
SELECT COUNT(*)
FROM Production.Product

-- 2. Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.
SELECT COUNT(*)
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL

-- 3. How many Products reside in each SubCategory? Write a query to display the results with the following titles.
/*
	ProductSubcategoryID CountedProducts
	-------------------- ---------------
*/
SELECT ProductSubcategoryID, COUNT(*) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID

-- 4. How many products that do not have a product subcategory.
SELECT COUNT(*)
FROM Production.Product
WHERE ProductSubcategoryID IS NULL

-- 5. Write a query to list the sum of products quantity in the Production.ProductInventory table.
SELECT SUM(Quantity)
FROM Production.ProductInventory

-- 6. Write a query to list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100.
/*
	ProductID TheSum
	--------- ------
*/
SELECT ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity) < 100

-- 7. Write a query to list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100
/*
	Shelf ProductID TheSum
	----- --------- ------
*/
SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY Shelf, ProductID
HAVING SUM(Quantity) < 100

-- 8. Write the query to list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table.
SELECT AVG(Quantity)
FROM Production.ProductInventory
WHERE LocationID = 10

-- 9. Write query to see the average quantity of products by shelf from the table Production.ProductInventory
/*
	ProductID Shelf TheAvg
	--------- ----- ------
*/
SELECT ProductID, Shelf, AVG(Quantity) AS TheSum
FROM Production.ProductInventory
GROUP BY ProductID, Shelf

-- 10. Write query to see the average quantity of products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory
/*
	ProductID Shelf TheAvg
	--------- ----- ------
*/
SELECT ProductID, Shelf, AVG(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE Shelf <> 'N/A'
GROUP BY ProductID, Shelf

-- 11. List the members (rows) and average list price in the Production.Product table. This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null.
/*
	Color Class TheCount AvgPrice
	----- ----- -------- --------
*/
SELECT Color, Class, COUNT(ProductID) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL
	AND Class IS NOT NULL
GROUP BY Color, Class

-- Joins:

-- 12. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables. Join them and produce a result set similar to the following.
/*
	Country Province
	------- --------
*/
SELECT c.Name AS Country, s.Name as Province
FROM Person.CountryRegion c
	JOIN Person.StateProvince s ON  c.CountryRegionCode = s.CountryRegionCode

-- 13. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following.
/*
	Country Province
	------- --------
*/
SELECT c.Name AS Country, s.Name as Province
FROM Person.CountryRegion c
	JOIN Person.StateProvince s ON  c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada')

-- Using Northwind Database: (Use aliases for all the Joins)
USE Northwind;

-- 14. List all Products that has been sold at least once in last 25 years.
SELECT *
FROM Products
WHERE ProductID IN (
	SELECT ProductID
	FROM [Order Details] od
		JOIN Orders o ON od.OrderID = o.OrderID
	WHERE o.OrderDate >= DATEADD(YEAR, -25, GETDATE())
)

-- 15. List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 o.ShipPostalCode
FROM [Order Details] od
	JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.ShipPostalCode IS NOT NULL
GROUP BY o.ShipPostalCode
ORDER BY SUM(od.Quantity) DESC

-- 16. List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT TOP 5 o.ShipPostalCode
FROM [Order Details] od
	JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.ShipPostalCode IS NOT NULL
	AND o.ShippedDate >= DATEADD(YEAR, -25, GETDATE())
GROUP BY o.ShipPostalCode
ORDER BY SUM(od.Quantity) DESC

-- 17. List all city names and number of customers in that city. 
SELECT City, COUNT(CustomerID) AS CustomerCount
FROM Customers
GROUP BY City

-- 18. List city names which have more than 2 customers, and number of customers in that city
SELECT City, COUNT(CustomerID) AS CustomerCount
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2

-- 19. List the names of customers who placed orders after 1/1/98 with order date.
SELECT c.ContactName, o.OrderDate
FROM Customers c
	JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= DATEFROMPARTS(1998, 1, 1)

-- 20. List the names of all customers with most recent order dates
SELECT c.ContactName, o.OrderDate
FROM Customers c
	LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
ORDER BY o.OrderDate DESC

-- 21. Display the names of all customers along with the count of products they bought
SELECT c.ContactName, t.ProductCount
FROM Customers c
	LEFT JOIN (
		SELECT c.CustomerID, COUNT(ProductID) AS ProductCount
		FROM Customers c
			JOIN Orders o ON c.CustomerID = o.CustomerID
			JOIN [Order Details] od ON o.OrderID = od.OrderID
		GROUP BY c.CustomerID
	) t ON c.CustomerID = t.CustomerID

-- 22. Display the customer ids who bought more than 100 Products with count of products.
SELECT c.CustomerID, COUNT(ProductID) AS ProductCount
FROM Customers c
	JOIN Orders o ON c.CustomerID = o.CustomerID
	JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID
HAVING COUNT(ProductID) > 100

-- 23. List all of the possible ways that suppliers can ship their products. Display the results as below
/*
	Supplier Company Name	Shipping Company Name
	---------------------	---------------------
*/
SELECT sp.CompanyName, sh.CompanyName
FROM Suppliers sp
	CROSS JOIN Shippers sh

-- 24. Display the products order each day. Show Order date and Product Name.
SELECT o.OrderDate, p.ProductName
FROM Orders o
	JOIN [Order Details] od ON o.OrderID = od.OrderID
	JOIN Products p ON od.ProductID = p.ProductID

-- 25. Displays pairs of employees who have the same job title.
SELECT
	e1.FirstName + ' ' + e1.LastName AS FullName1,
	e2.FirstName + ' ' + e2.LastName AS FullName2
FROM Employees e1
	JOIN Employees e2 ON e1.EmployeeID < e2.EmployeeID
WHERE e1.Title = e2.Title

-- 26. Display all the Managers who have more than 2 employees reporting to them.
SELECT *
FROM Employees
WHERE EmployeeID IN (
	SELECT e1.EmployeeID
	FROM Employees e1
		JOIN Employees e2 ON e1.EmployeeID = e2.ReportsTo
	GROUP BY e1.EmployeeID
	HAVING COUNT(e2.ReportsTo) > 2
)

-- 27. Display the customers and suppliers by city. The results should have the following columns
/*
	City
	Name
	Contact Name,
	Type (Customer or Supplier)
*/
SELECT City, CompanyName, ContactName, 'Customer' AS Type
FROM Customers
UNION ALL
SELECT City, CompanyName, ContactName, 'Supplier' AS Type
FROM Suppliers
