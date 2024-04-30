USE [db_sql_21];

CREATE TABLE Goods (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Type NVARCHAR(50),
    Quantity INT NOT NULL,
    ProdCost DECIMAL(10, 2),
    Manufacturer NVARCHAR(100),
    Price DECIMAL(10, 2)
);

CREATE TABLE Sales (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL, 
    Quantity INT NOT NULL,
    SaleDate DATE,
    SellerId INT NOT NULL,
    CustomerId INT NOT NULL
);

CREATE TABLE Employees (
    EmployeeId INT PRIMARY KEY IDENTITY(1,1),
    Position NVARCHAR(50),
    EmploymentDate DATE,
    Gender NVARCHAR(10),
    Salary DECIMAL(10, 2)
);

CREATE TABLE Customers (
    CustomerId INT PRIMARY KEY IDENTITY(1,1),
    Email NVARCHAR(255) UNIQUE,
    Phone NVARCHAR(20),
    Gender NVARCHAR(10),
    PurchaseHistory TEXT,
    DiscountPercentage DECIMAL(5, 2),
    SignedForMailing BIT
);

CREATE TABLE History (
    SaleId INT PRIMARY KEY IDENTITY(1,1),
    GoodsName NVARCHAR(100) NOT NULL,
    SalePrice DECIMAL(10, 2),
    Quantity INT NOT NULL,
    SaleDate DATE,
    SellerId INT NOT NULL,
    CustomerId INT NOT NULL
);

CREATE TABLE Archive (
    ArchiveId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Type NVARCHAR(50),
    Quantity INT NOT NULL,
    CostPrice DECIMAL(10, 2),
    Manufacturer NVARCHAR(100),
    Price DECIMAL(10, 2)
);

CREATE TABLE LastUnit (
    LastUnitId INT PRIMARY KEY IDENTITY(1,1),
    GoodsName NVARCHAR(100) NOT NULL,
    Quantity INT NOT NULL
);

GO
-- ������ ��� �������� ���������� ��� ������ � ������� ������
CREATE TRIGGER RecordSaleHistory
ON Sales
AFTER INSERT
AS
BEGIN
    INSERT INTO History (GoodsName, SalePrice, Quantity, SaleDate, SellerId, CustomerId)
    SELECT i.Name, g.Price, i.Quantity, i.SaleDate, i.SellerId, i.CustomerId
    FROM INSERTED i
    JOIN Goods g ON i.Name = g.Name;
END;
GO

-- ������ ��� ����������� ���������� ��� ������, �� �������� �������, �� ������� �����
CREATE TRIGGER TransferToArchive
ON Sales
AFTER UPDATE
AS
BEGIN
    IF (SELECT Quantity FROM INSERTED) = 0
    BEGIN
        INSERT INTO Archive (Name, Type, Quantity, CostPrice, Manufacturer, Price)
        SELECT i.Name, i.Type, i.Quantity, i.ProdCost, i.Manufacturer, i.Price
        FROM INSERTED i;
    END
END;
GO

-- ������ ��� �������� �������� ��������� �볺���
CREATE TRIGGER PreventDuplicateCustomer
ON Customers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Customers WHERE Email = (SELECT Email FROM INSERTED))
    BEGIN
        RAISERROR ('Client already exists.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Customers (Email, Phone, Gender, PurchaseHistory, DiscountPercentage, SignedForMailing)
        SELECT Email, Phone, Gender, PurchaseHistory, DiscountPercentage, SignedForMailing
        FROM INSERTED;
    END
END;
GO

-- ������, �� ��������� ��������� �������� �볺���
CREATE TRIGGER PreventCustomerRemoval
ON Customers
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR ('Removal of existing customers is prohibited.', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO

-- ������, �� ��������� ��������� ����������, ��������� �� ������ �� 2015 ����
CREATE TRIGGER PreventEmployeeRemoval
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    IF (SELECT COUNT(*) FROM DELETED WHERE EmploymentDate < '2015-01-01') > 0
    BEGIN
        RAISERROR ('Removal of employees hired before 2015 is prohibited.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- ������ ��� ������������ ������� ������ ��� ��������� ��� ������� ����� 50000 ���
CREATE TRIGGER SetDiscountPercentage
ON Sales
AFTER INSERT
AS
BEGIN
    DECLARE @total_purchase DECIMAL(10, 2);
    
    SELECT @total_purchase = SUM(SI.Price * SI.Quantity)
    FROM Sales SI
    JOIN INSERTED I ON SI.CustomerId = I.CustomerId;
    
    IF @total_purchase > 50000 AND NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerId = (SELECT CustomerId FROM INSERTED) AND DiscountPercentage > 15)
    BEGIN
        UPDATE C SET DiscountPercentage = 15
        FROM Customers C
        JOIN INSERTED I ON C.CustomerId = I.CustomerId;
    END
END;
GO

-- ������, �� ��������� �������� ����� ��������� �����
CREATE TRIGGER ProhibitCompanyGoods
ON Goods
INSTEAD OF INSERT
AS
BEGIN
    IF (SELECT Manufacturer FROM INSERTED) = 'Sport, Sun and Barbell'
    BEGIN
        RAISERROR ('Adding goods from Sport, Sun and Barbell is prohibited.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Goods (Name, Type, Quantity, ProdCost, Manufacturer, Price)
        SELECT Name, Type, Quantity, ProdCost, Manufacturer, Price
        FROM INSERTED;
    END
END;
GO

-- ������ ��� �������� ������� ������ � ��������
CREATE TRIGGER CheckStockQuantity
ON Goods
AFTER UPDATE
AS
BEGIN
    IF (SELECT Quantity FROM INSERTED) = 1
    BEGIN
        INSERT INTO LastUnit (GoodsName, Quantity)
        SELECT Name, Quantity FROM INSERTED;
    END
END;
GO