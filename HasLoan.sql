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
			WHEN  count(CustomerId) IS NOT NULL THEN 1
			ELSE 0
		END
	
	FROM Loan
	WHERE CustomerId = @CustomerId;
	RETURN @Result;
	
END;
