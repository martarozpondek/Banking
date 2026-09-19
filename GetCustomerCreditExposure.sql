/* Funkcja ma obliczyć całkowitą ekspozycję kredytową klienta, np.:

OutstandingPrincipal
+ wykorzystany overdraft

Czyli odpowiadasz na pytanie:

„Jakie jest obecne zadłużenie klienta wobec banku?” */
USE Banking;

CREATE FUNCTION GetCustomerCreditExposure
(
	@CustomerId UNIQUEIDENTIFIER
)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @DebtValue AS DECIMAL(18,2);
	DECLARE @OverdraftDebt AS DECIMAL(18,2);

	SELECT @DebtValue = 
		ISNULL(
		(
			SELECT SUM(OutstandingPrincipal) 
			FROM Loan AS l WHERE l.CustomerId= @CustomerId
		),
		0)

	SELECT @OverdraftDebt =
		ISNULL(
		(
			SELECT SUM(ao.UsedAmount) 
			FROM 
			Account AS a 
			JOIN 
			AccountOverdraft AS ao ON ao.AccountId = a.AccountId
			WHERE a.CustomerId= @CustomerId
		),
		0)
	RETURN @DebtValue+@OverdraftDebt;
END;

SELECT dbo.GetCustomerCreditExposure('8927C26A-AB9C-F111-A598-4AE7DA529CB3') AS CustomerCreditExposure

SELECT
    l.LoanId,
    l.OutstandingPrincipal
FROM dbo.Loan AS l
WHERE l.CustomerId = '8927C26A-AB9C-F111-A598-4AE7DA529CB3';

SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    dbo.GetCustomerCreditExposure(c.CustomerId) AS CustomerCreditExposure
FROM dbo.Customer AS c;