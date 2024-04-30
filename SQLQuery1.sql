USE [db_sql_21];
GO

INSERT INTO Goods (Name, Type, Quantity, ProdCost, Manufacturer, Price)
VALUES 
    ('Laptop', 'Electronics', 20, 500, 'Tech Inc.', 700),
    ('Smartphone', 'Electronics', 30, 300, 'Tech Inc.', 500),
    ('Headphones', 'Electronics', 50, 50, 'SoundMaster', 100),
    ('Keyboard', 'Electronics', 40, 20, 'Tech Inc.', 30),
    ('Mouse', 'Electronics', 60, 15, 'Tech Inc.', 25);

INSERT INTO Employees (Position, EmploymentDate, Gender, Salary)
VALUES 
    ('Manager', '2010-02-15', 'Male', 4000),
    ('Salesperson', '2015-03-10', 'Female', 2500),
    ('Assistant', '2019-08-20', 'Male', 2000);

INSERT INTO Customers (Email, Phone, Gender, PurchaseHistory, DiscountPercentage, SignedForMailing)
VALUES 
    ('customer1@example.com', '+1234567890', 'Male', 'Purchase History for Customer 1', 0.0, 1),
    ('customer2@example.com', '+0987654321', 'Female', 'Purchase History for Customer 2', 0.0, 0),
    ('customer3@example.com', '+1122334455', 'Male', 'Purchase History for Customer 3', 0.0, 1);

INSERT INTO Sales (Name, Quantity, SaleDate, SellerId, CustomerId)
VALUES 
    ('Laptop', 2, '2024-04-23', 101, 201),
    ('Smartphone', 3, '2024-04-23', 102, 202),
    ('Headphones', 5, '2024-04-23', 103, 203),
    ('Keyboard', 4, '2024-04-23', 104, 204),
    ('Mouse', 6, '2024-04-23', 105, 205);
