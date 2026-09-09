/* czy ma aktywny kreedyt */
USE Banking;

CREATE FUNCTION HasLoanActive(
	@CustomerId UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN 
	DECLARE @Result AS BIT 
	SELECT @Result =
		CASE
			WHEN EXISTS (SELECT CustomerId FROM Loan AS l JOIN LoanStatus AS ls ON l.LoanStatusId = ls.LoanStatusId WHERE l.CustomerId = @CustomerId AND ls.Name = 'Active') THEN 1
			ELSE 0
		END
	RETURN @Result;
	
END;

SELECT FirstName, LastName, dbo.HasLoanActive(CustomerId) AS HasLoanActive
FROM dbo.Customer;

select * from LoanStatus