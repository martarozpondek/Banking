USE Banking;
CREATE FUNCTION GetAccountFinancialStatus
(
	@AccountId BIGINT
)
RETURNS VARCHAR(100) 
AS
BEGIN
	DECLARE @AccountFinancialStatus AS VARCHAR(100)
	SELECT @AccountFinancialStatus = 
		CASE 
		WHEN 
			ao.UsedAmount = 0 THEN  'NORMAL'
		WHEN 
			ao.UsedAmount >= ao.OverdraftLimit THEN 'HIGH_OVERDRAFT_USAGE'
		ELSE 'OVERDRAFT'
		END
	FROM Account AS a JOIN  AccountOverdraft AS ao ON a.AccountId = ao.AccountId WHERE a.AccountId = @AccountId;
	RETURN @AccountFinancialStatus
END;
SELECT dbo.GetAccountFinancialStatus(500);

SELECT
    a.AccountId,
    a.CurrentBalance,
    a.AvailableBalance,
    ao.OverdraftLimit,
    ao.UsedAmount,
    dbo.GetAccountFinancialStatus(a.AccountId) AS FinancialStatus
FROM dbo.Account AS a
JOIN dbo.AccountOverdraft AS ao
    ON a.AccountId = ao.AccountId;