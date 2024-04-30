USE [db_sql_21];

CREATE TRIGGER PreventDuplicateAlbum
ON Albums
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Albums A JOIN INSERTED I ON A.AlbumName = I.AlbumName)
    BEGIN
        RAISERROR ('Cannot add album. The album already exists in the collection.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Albums (AlbumName, Artist, ReleaseYear, Genre)
        SELECT AlbumName, Artist, ReleaseYear, Genre
        FROM INSERTED;
    END
END;
GO

-- ������, ���� �� �������� �������� ����� ����� The Beatles
CREATE TRIGGER PreventBeatlesDeletion
ON Discs
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM DELETED D JOIN Bands B ON D.BandId = B.BandId WHERE B.BandName = 'The Beatles')
    BEGIN
        RAISERROR ('Cannot delete discs from The Beatles.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE D
        FROM Discs D
        JOIN DELETED DL ON D.DiscId = DL.DiscId;
    END
END;
GO

-- ������, ���� ���������� ���������� ��� ��������� ���� �� ������� "�����"
CREATE TRIGGER TransferToDiscArchive
ON Discs
AFTER DELETE
AS
BEGIN
    INSERT INTO DiscArchive (DiscId, AlbumName, DiscName, TrackCount, DiscType, BandId)
    SELECT DiscId, AlbumName, DiscName, TrackCount, DiscType, BandId
    FROM DELETED;
END;
GO

-- ������, ���� �� �������� �������� � �������� ����� ��������� ����� "Dark Power Pop"
CREATE TRIGGER ProhibitDarkPowerPop
ON Discs
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM INSERTED WHERE Genre = 'Dark Power Pop')
    BEGIN
        RAISERROR ('Cannot add discs of the genre "Dark Power Pop" to the collection.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Discs (AlbumName, DiscName, TrackCount, DiscType, BandId)
        SELECT AlbumName, DiscName, TrackCount, DiscType, BandId
        FROM INSERTED;
    END
END;
GO
