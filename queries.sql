use Banking

/* klienci którzy mają debet */
SELECT a.AccountId, c.FirstName, c.LastName, a.AvailableBalance 
FROM Account AS a 
JOIN 
Customer AS c 
ON a.CustomerId = c.CustomerId
WHERE a.AvailableBalance < 0

/* wprowadzenie debetu */
UPDATE Account
SET 
    CurrentBalance = -250.00,
    AvailableBalance = -250.00
WHERE AccountId = 410;

UPDATE dbo.Account
SET 
    CurrentBalance = -1250.50,
    AvailableBalance = -1250.50
WHERE AccountId = 411;

UPDATE dbo.Account
SET 
    CurrentBalance = -75.20,
    AvailableBalance = -75.20
WHERE AccountId = 520;
/* znaleźć klientów, którzy mają więcej niż jedno konto i przynajmniej jedno z nich jest na minusie */
SELECT c.FirstName, c.LastName, COUNT(AccountId) AS "Number of accounts"
FROM Account AS a 
JOIN 
Customer AS c 
ON a.CustomerId = c.CustomerId 
WHERE a.AvailableBalance < 0  
GROUP BY c.FirstName, c.LastName
HAVING COUNT(AccountId) > 1

/* przypisanie kilku kont */
UPDATE dbo.Account
SET CustomerId = '7D27C26A-AB9C-F111-A598-4AE7DA529CB3'
WHERE AccountId = 666;

select * from Customer where CustomerId = '7D27C26A-AB9C-F111-A598-4AE7DA529CB3';
select * from AccountType
SELECT
    AccountId,
    AccountNumber,
    CustomerId,
    AccountTypeId,
    CurrentBalance,
    AvailableBalance
FROM dbo.Account
WHERE CustomerId = '7D27C26A-AB9C-F111-A598-4AE7DA529CB3'