/*jaki procent limitu debetowego klient wykorzystuje*/
USE Banking;
CREATE FUNCTION GetOverdraftUsagePercentage(
	@AccountId BIGINT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
	DECLARE @Result DECIMAL (5,2)
	SELECT @Result =  
		CASE
			WHEN  OverdraftLimit > 0 THEN (ao.UsedAmount / ao.OverdraftLimit * 100 )  
			ELSE 0
		END
	FROM Account AS a JOIN AccountOverdraft AS ao ON a.AccountId = ao.AccountId WHERE a.AccountId = @AccountId;

	RETURN @Result
END;

SELECT dbo.GetOverdraftUsagePercentage(520);