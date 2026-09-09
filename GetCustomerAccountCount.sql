/*liczba wszystkich kont klienta*/

USE Banking;

CREATE FUNCTION GetCustomerAccountCount(
	@CustomerId UNIQUEIDENTIFIER 
)
RETURNS INT
AS
BEGIN
	DECLARE @NumberOfAccounts AS INT
		SELECT @NumberOfAccounts = COUNT(AccountId) FROM Account WHERE CustomerId = @CustomerId
		RETURN @NumberOfAccounts;
END;


SELECT
    FirstName,
    LastName,
    dbo.GetCustomerAccountCount(CustomerId) AS NumberOfAccounts
FROM dbo.Customer;

SELECT
    c.FirstName,
    c.LastName,
    at.Name,
    dbo.GetCustomerAccountCount(a.CustomerId) AS NumberOfAccounts
FROM dbo.Customer AS c JOIN Account AS a ON c.CustomerId = a.CustomerId JOIN AccountType AS at ON a.AccountTypeId = at.AccountTypeId