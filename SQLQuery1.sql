USE [db_sql_21];

-- ������ ��� �������� �������� ������� � ����� ����� ��������
CREATE TRIGGER CheckDuplicateCustomer
ON Customers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Customers C JOIN INSERTED I ON C.LastName = I.LastName)
    BEGIN
        INSERT INTO DuplicateCustomers (LastName, FirstName, Email, Phone, Gender)
        SELECT LastName, FirstName, Email, Phone, Gender
        FROM INSERTED;
    END
    ELSE
    BEGIN
        INSERT INTO Customers (LastName, FirstName, Email, Phone, Gender)
        SELECT LastName, FirstName, Email, Phone, Gender
        FROM INSERTED;
    END
END;
GO

-- ������, ���� ���������� ������ ������� ������� �� ������� "������ �������"
CREATE TRIGGER TransferPurchaseHistory
ON Customers
AFTER DELETE
AS
BEGIN
    INSERT INTO PurchaseHistory (CustomerId, PurchaseDate, GoodsName, Quantity, SalePrice, SellerId)
    SELECT D.CustomerId, S.SaleDate, S.GoodsName, S.Quantity, S.SalePrice, S.SellerId
    FROM DELETED D
    JOIN Sales S ON D.CustomerId = S.CustomerId;
END;
GO

-- ������, ���� �������� �� � ��������� � ������� ��������
CREATE TRIGGER CheckSellerInCustomers
ON Sellers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Customers C JOIN INSERTED I ON C.LastName = I.LastName AND C.FirstName = I.FirstName)
    BEGIN
        RAISERROR ('Cannot add a seller who is already in the Customers table.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Sellers (LastName, FirstName, Email, Phone, Gender)
        SELECT LastName, FirstName, Email, Phone, Gender
        FROM INSERTED;
    END
END;
GO

-- ������, ���� �������� �� � �������� � ������� ���������
CREATE TRIGGER CheckCustomerInSellers
ON Customers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Sellers S JOIN INSERTED I ON S.LastName = I.LastName AND S.FirstName = I.FirstName)
    BEGIN
        RAISERROR ('Cannot add a customer who is already in the Sellers table.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Customers (LastName, FirstName, Email, Phone, Gender)
        SELECT LastName, FirstName, Email, Phone, Gender
        FROM INSERTED;
    END
END;
GO

-- ������, ���� �� �������� ��������� ���������� ��� ������ ������ ������
CREATE TRIGGER ProhibitSpecificItemsSale
ON Sales
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM INSERTED WHERE GoodsName IN ('Apple', 'Pear', 'Plum', 'Cilantro'))
    BEGIN
        RAISERROR ('Cannot insert information about the sale of apples, pears, plums, or cilantro.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Sales (CustomerId, GoodsName, Quantity, SalePrice, SaleDate, SellerId)
        SELECT CustomerId, GoodsName, Quantity, SalePrice, SaleDate, SellerId
        FROM INSERTED;
    END
END;
GO

