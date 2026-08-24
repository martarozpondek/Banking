INSERT INTO OverdraftInterest
(
    OverdraftId,
    TransactionStatusId,
    TransactionId,
    InterestDate,
    InterestPeriodFrom,
    InterestPeriodTo,
    Amount,
    Rate
)
SELECT
    ao.OverdraftId,

    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 85 THEN 3
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 95 THEN 1
        ELSE 2
    END AS TransactionStatusId,

    NULL AS TransactionId,

    DATEADD(
        DAY,
        -(ABS(CHECKSUM(NEWID())) % 365),
        SYSDATETIMEOFFSET()
    ) AS InterestDate,

    DATEADD(
        DAY,
        -30,
        CAST(GETDATE() AS DATE)
    ) AS InterestPeriodFrom,

    CAST(GETDATE() AS DATE) AS InterestPeriodTo,

    CAST(
        ROUND(
            ao.UsedAmount
            * (ao.InterestRate / 100.0)
            * (30.0 / 365.0),
            2
        )
        AS DECIMAL(18,2)
    ) AS Amount,

    ao.InterestRate AS Rate

FROM dbo.AccountOverdraft ao
WHERE ao.UsedAmount > 0;