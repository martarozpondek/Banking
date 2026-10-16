CREATE TRIGGER CustomerAudit_Trigger
ON Customer
AFTER UPDATE 
AS 
BEGIN
	SET NOCOUNT ON;

	INSERT INTO CustomerAudit(CustomerId, 
	OldFirstName,
	OldLastName,
	OldEmail,
	OldPhoneNumber,
	NewFirstName,
	NewLastName,
	NewEmail,
	NewPhoneNumber)
	SELECT d.CustomerId AS CustomerId,
	
    CASE
        WHEN d.FirstName <> i.FirstName THEN d.FirstName
        ELSE NULL
    END AS OldFirstName,
	CASE 
		WHEN d.LastName <> i.LastName THEN d.LastName 
		ELSE NULL
	END AS OldLastName,
	CASE
		WHEN d.Email <> i.Email THEN d.Email 
		ELSE NULL
	END AS OldEmail,
	CASE
		WHEN d.PhoneNumber <> i.PhoneNumber THEN d.PhoneNumber 
		ELSE NULL
	END	AS OldPhoneNumber,
	CASE
        WHEN d.FirstName <> i.FirstName THEN i.FirstName
        ELSE NULL
    END AS NewFirstName, 
	CASE
        WHEN d.LastName <> i.LastName THEN i.LastName
        ELSE NULL
    END AS NewLastName, 
	CASE
        WHEN d.Email <> i.Email THEN i.Email
        ELSE NULL
    END AS NewEmail,
	CASE
        WHEN d.PhoneNumber <> i.PhoneNumber THEN i.PhoneNumber
        ELSE NULL
    END AS NewPhoneNumber 
	FROM deleted AS d INNER JOIN inserted AS i
    ON d.CustomerId = i.CustomerId
	WHERE i.FirstName <> d.FirstName OR i.LastName <> d.LastName
	OR i.Email <> d.Email OR i.PhoneNumber <> d.PhoneNumber;

END;
GO

SELECT CustomerId, FirstName, LastName, Email, PhoneNumber
FROM dbo.Customer;

USE Banking;
GO

BEGIN TRANSACTION;

DECLARE @CustomerId UNIQUEIDENTIFIER;

SELECT TOP (1) @CustomerId = CustomerId
FROM dbo.Customer
ORDER BY CustomerId;

-- Zmieniamy imię klienta, aby uruchomić trigger
UPDATE dbo.Customer
SET FirstName = N'Łukasz_Test'
WHERE CustomerId = 'A146F449-19C3-F111-A59E-4AE7DA529CB3';

-- Sprawdzamy, czy trigger zapisał audyt
SELECT TOP (5) *
FROM dbo.CustomerAudit
WHERE CustomerId = 'A146F449-19C3-F111-A59E-4AE7DA529CB3'
ORDER BY CustomerAuditId DESC;

-- Cofamy aktualizację klienta i wpis audytowy
ROLLBACK TRANSACTION;