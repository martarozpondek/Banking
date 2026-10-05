USE MASTER
GO

IF DB_ID('Banking') IS NOT NULL
BEGIN
    ALTER DATABASE Banking
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE Banking;

    PRINT 'Database [Banking] removed.';
END
ELSE
BEGIN
    PRINT 'Database [Banking] does not exist.';
END
GO