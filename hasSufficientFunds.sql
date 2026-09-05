/* funkcja sprawdzająca czy klient ma wystarczająco środków na koncie żeby zapłacić */
use Banking;
CREATE FUNCTION HasSufficientFunds
(
	@AccountId BIGINT,
	@Amount DECIMAL(18,2) 
)
RETURNS BIT
AS
BEGIN
	DECLARE @Result BIT

	SELECT @Result = 
		CASE 
			WHEN AvailableBalance >= @Amount THEN 1
			ELSE 0
		END
	FROM Account 
	WHERE AccountId = @AccountId

	RETURN @Result;
END;
/*

SELECT 
    name,
    type_desc
FROM sys.objects
WHERE name = 'HasSufficientFunds'; */
SELECT dbo.HasSufficientFunds(410, 2500.00) AS HasSufficientFunds;