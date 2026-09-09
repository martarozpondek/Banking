/*wiek klienta */
USE Banking;

CREATE FUNCTION GetCustomerAge(
	@CustomerId UNIQUEIDENTIFIER 
)
RETURNS INT 
AS
BEGIN 
	DECLARE @CustomerAge AS INT
		SELECT @CustomerAge = DATEDIFF(YYYY,BirthDate,SYSDATETIME()) FROM Customer WHERE CustomerId = @CustomerId
		RETURN @CustomerAge;
END;

SELECT
    FirstName,
    LastName,
    dbo.GetCustomerAge(CustomerId) AS CustomerAge
FROM dbo.Customer;