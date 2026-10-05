IF DB_ID('Banking') IS NULL
BEGIN
    CREATE DATABASE Banking;
    PRINT 'Database [Banking] created.';
END
ELSE
BEGIN
    PRINT 'Database [Banking] already exists.';
END
GO
