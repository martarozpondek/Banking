/* Czy konto jest na debecie */
use Banking;
CREATE FUNCTION IsAccountOverdraft(
	@AccountId BIGINT
)
RETURNS BIT
AS
BEGIN
	DECLARE @Result BIT

	SELECT @Result =
		CASE 
			WHEN AvailableBalance < 0 THEN 1
			ELSE 0
		END
	FROM Account WHERE AccountId = @AccountId;
	RETURN @Result
END;

SELECT dbo.IsAccountOverdraft(520) AS IsAccountOverdraft;
