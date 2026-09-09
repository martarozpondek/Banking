/* czy ma kreedyt */
USE Banking;

CREATE FUNCTION HasLoan(
	@CustomerId UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN 
	DECLARE @Result AS BIT 
	SELECT @Result =
		CASE
			WHEN EXISTS (SELECT CustomerId FROM Loan WHERE CustomerId = @CustomerId) THEN 1
			ELSE 0
		END
	RETURN @Result;
	
END;

SELECT FirstName, LastName, dbo.HasLoan(CustomerId) AS HasLoan
FROM dbo.Customer;
