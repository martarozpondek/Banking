/*
Funkcja zwraca np.:

LOW
MEDIUM
HIGH

na podstawie kilku warunków, np.:

klient ma aktywny kredyt,
ma wykorzystany debet,
ma ujemne saldo,
ma zaległe płatności kredytowe.
 */

USE Banking;
CREATE FUNCTION GetCustomerRiskLevel
(
	@CustomerId UNIQUEIDENTIFIER 
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @RiskStatus AS VARCHAR(100);
	SELECT @RiskStatus = 
	CASE 
		WHEN
		(EXISTS
		(SELECT 1 FROM Account AS a 
		JOIN AccountOverdraft AS ao ON a.AccountId = ao.AccountId WHERE  ao.AvailableAmount <= 0 AND a.CustomerId = @CustomerId))
		THEN 'HIGH'

		WHEN
		(EXISTS
		(SELECT 1 
		FROM 
		LoanSchedule AS ls 
		JOIN
		Loan AS l ON ls.LoanId = l.LoanId
		WHERE l.CustomerId = @CustomerId AND ls.LoanInstallmentStatusId = 5))
		THEN 'HIGH'

		WHEN 
		(EXISTS 
		(SELECT 1 FROM Loan WHERE CustomerId = @CustomerId AND LoanStatusId = 2))
		THEN 'MEDIUM'

		WHEN 
		(EXISTS
		(SELECT 1 FROM Account 
		WHERE CustomerId = @CustomerId AND AvailableBalance <=0))
		THEN 'MEDIUM'


		ELSE 'LOW'
		END;
	RETURN @RiskStatus;
END;


SELECT dbo.GetCustomerRiskLevel('8927C26A-AB9C-F111-A598-4AE7DA529CB3') AS RiskLevel;

SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    dbo.GetCustomerRiskLevel(c.CustomerId) AS RiskLevel
FROM dbo.Customer AS c;

SELECT
    dbo.GetCustomerRiskLevel(c.CustomerId) AS RiskLevel,
    COUNT(*) AS CustomerCount
FROM dbo.Customer AS c
GROUP BY dbo.GetCustomerRiskLevel(c.CustomerId);