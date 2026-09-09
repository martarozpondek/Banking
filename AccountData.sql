INSERT INTO Account
(
    CustomerId,
    AccountNumber,
    AccountTypeId,
    CurrencyCode,
    CurrentBalance,
    AvailableBalance
)
SELECT TOP (80)

    CustomerId,

    '101' +
    RIGHT(
        '00000000000000000000000' +
        CAST(ROW_NUMBER() OVER (ORDER BY CustomerId) AS VARCHAR(23)),
        23
    ) AS AccountNumber,

    CASE
	WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 13 = 0 THEN 6
	WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 22 = 0 THEN 8
    WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 20 = 0 THEN 4
	WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 18 = 0 THEN 10
    WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 10 = 0 THEN 3
    WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 5 = 0 THEN 2
    ELSE 1
	END AS AccountTypeId,

    CASE
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 25 = 0 THEN 'USD'
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 20 = 0 THEN 'GBP'
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 15 = 0 THEN 'EUR'
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 30 = 0 THEN 'CHF'
        ELSE 'PLN'
    END AS CurrencyCode,

    b.Bal AS CurrentBalance,

    b.Bal AS AvailableBalance

FROM dbo.Customer

CROSS APPLY
(
    SELECT CAST(
        (ABS(CHECKSUM(NEWID())) % 1000000) / 100.0
        AS DECIMAL(18,2)
    ) AS Bal
) b

ORDER BY CustomerId;

