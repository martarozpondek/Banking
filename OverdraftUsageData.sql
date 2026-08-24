INSERT INTO OverdraftUsage
(
    OverdraftId,
    OverdraftUsageTypeId,
    TransactionId,
    AmountUsed
)
SELECT TOP (150)
    ao.OverdraftId,

    (
        SELECT TOP (1)
            OverdraftUsageTypeId
        FROM dbo.OverdraftUsageType
        ORDER BY NEWID()
    ) AS OverdraftUsageTypeId,

    at.TransactionId,

    CAST(
        ABS(at.BalanceAfterTransaction)
        AS DECIMAL(18,2)
    ) AS AmountUsed

FROM dbo.AccountOverdraft ao

INNER JOIN dbo.AccountTransaction at
    ON at.AccountId = ao.AccountId

WHERE
    at.TransactionDirection = 'D'
    AND at.BalanceAfterTransaction < 0

    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.OverdraftUsage ou
        WHERE ou.TransactionId = at.TransactionId
    )

ORDER BY NEWID();