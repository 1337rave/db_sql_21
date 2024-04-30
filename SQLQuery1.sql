USE [db_sql_21];
CREATE TRIGGER CheckExistingGoods
ON Goods
INSTEAD OF INSERT
AS
BEGIN
    -- ����������, �� ���� ��� ����� ����� �� �����
    IF EXISTS (SELECT 1 FROM Goods G JOIN INSERTED I ON G.Name = I.Name)
    BEGIN
        -- ���� ����� ��� ����, ��������� ������� ������
        UPDATE Goods
        SET Quantity = Quantity + I.Quantity
        FROM Goods G
        JOIN INSERTED I ON G.Name = I.Name;
    END
    ELSE
    BEGIN
        -- ���� ����� �� ����, ������ ����
        INSERT INTO Goods (Name, Type, Quantity, ProdCost, Manufacturer, Price)
        SELECT Name, Type, Quantity, ProdCost, Manufacturer, Price
        FROM INSERTED;
    END
END;
GO

-- ������ ��� ����������� ���������� ��� ���������� ����������� �� ������� "����� �����������"
CREATE TRIGGER TransferToEmployeeArchive
ON Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO EmployeeArchive (EmployeeId, Position, EmploymentDate, Gender, Salary)
    SELECT EmployeeId, Position, EmploymentDate, Gender, Salary
    FROM DELETED;
END;
GO

-- ������ ��� �������� ������� ��������� ����� ���������� ������
CREATE TRIGGER CheckSellerLimit
ON Employees
INSTEAD OF INSERT
AS
BEGIN
    -- ���������� ������� �������� ���������
    IF (SELECT COUNT(*) FROM Employees WHERE Position = 'Seller') >= 6
    BEGIN
        RAISERROR ('Cannot add new seller. The maximum number of sellers (6) has been reached.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- ������ ������ ��������
        INSERT INTO Employees (Position, EmploymentDate, Gender, Salary)
        SELECT Position, EmploymentDate, Gender, Salary
        FROM INSERTED;
    END
END;
GO
