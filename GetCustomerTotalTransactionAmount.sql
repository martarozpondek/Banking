/*zwraca łączną wartość transakcji klienta w określonym okresie */
USE Banking;

CREATE FUNCTION GetCustomerTotalTransactionAmount
(
	@CustomerId UNIQUEIDENTIFIER,
	@StartDate DATE,
	@EndDate DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN	
	DECLARE @TotalTransactionValue AS DECIMAL(18,2);

	SELECT @TotalTransactionValue = ISNULL(SUM(at.Amount),0) 
	FROM Customer AS c 
	JOIN Account AS a ON c.CustomerId = a.CustomerId 
	JOIN AccountTransaction AS at ON a.AccountId = at.AccountId 
	WHERE c.CustomerId= @CustomerId AND (TransactionDate >= @StartDate AND TransactionDate < DATEADD(DAY,1,@EndDate))

	RETURN @TotalTransactionValue;
END;

SELECT dbo.GetCustomerTotalTransactionAmount(
    '8927C26A-AB9C-F111-A598-4AE7DA529CB3',
    '2024-01-01',
    '2024-09-30'
) AS TotalTransactionAmount;

SELECT dbo.GetCustomerTotalTransactionAmount(
    '6D28C26A-AB9C-F111-A598-4AE7DA529CB3',
    '2025-10-10',
    '2025-11-11'
) AS TotalTransactionAmount;



SELECT
    a.AccountId,
    at.TransactionId,
    at.Amount,
    at.TransactionDate
FROM dbo.Account AS a
JOIN dbo.AccountTransaction AS at
    ON a.AccountId = at.AccountId
WHERE a.CustomerId = '6D28C26A-AB9C-F111-A598-4AE7DA529CB3';