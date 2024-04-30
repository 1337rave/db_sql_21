USE [db_sql_21];
GO

SELECT Name, Type, Quantity, ProdCost AS CostPrice, Manufacturer, Price
FROM Goods;

SELECT 
    g.Name AS GoodsName,
    s.Price AS SalePrice,
    s.Quantity,
    s.SaleDate,
    e.FullName AS SellerName,
    c.FullName AS BuyerName
FROM Sales s
JOIN Employees e ON s.SellerId = e.EmployeeId
LEFT JOIN Customers c ON s.CustomerId = c.CustomerId
JOIN Goods g ON s.Name = g.Name;

SELECT FullName, Position, EmploymentDate, Gender, Salary
FROM Employees;

SELECT Email, Phone AS ContactPhone, Gender, PurchaseHistory AS OrderHistory, DiscountPercentage, SignedForMailing
FROM Customers;