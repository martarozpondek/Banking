INSERT INTO AccountTransaction
(
    TransactionReference,
    TransactionTypeId,
    TransactionStatusId,
    TransactionDirection,
    MerchantId,
    AccountId,
    Amount,
    TransactionDate,
    TransactionCurrencyCode,
    Title,
    BalanceAfterTransaction
)
SELECT TOP (10000)

    -- numer transakcji
    'TRX' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', '') AS TransactionReference,

    -- typ transakcji
    t.TransactionTypeId,

    -- status
    s.TransactionStatusId,

    -- kierunek
    d.TransactionDirection,

    -- merchant
    CASE
        WHEN t.TransactionTypeId IN (1, 6, 11)
            THEN m.MerchantId
        ELSE NULL
    END AS MerchantId,

    -- konto
    a.AccountId,

    -- kwota
    x.Amount,

    -- data
    DATEADD(
        DAY,
        -(ABS(CHECKSUM(NEWID())) % 730),
        SYSDATETIMEOFFSET()
    ) AS TransactionDate,

    -- waluta konta
    a.CurrencyCode AS TransactionCurrencyCode,

    -- tytuł
    COALESCE(
        CASE
            WHEN t.TransactionTypeId IN (1, 6, 11)
                THEN m.Name
        END,
        tt.Name,
        'Transaction'
    ) + ' - ' +
    CONVERT(
        VARCHAR(19),
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 730),
            SYSDATETIMEOFFSET()
        ),
        120
    ) AS Title,

    -- saldo po transakcji
    CASE
        WHEN d.TransactionDirection = 'D'
            THEN CAST(a.CurrentBalance - x.Amount AS DECIMAL(18,2))
        ELSE
            CAST(a.CurrentBalance + x.Amount AS DECIMAL(18,2))
    END AS BalanceAfterTransaction

FROM Account a

CROSS APPLY
(
    SELECT
        ABS(CHECKSUM(NEWID())) % 100 AS RandomType
) rt

CROSS APPLY
(
    SELECT
        CASE
            WHEN rt.RandomType < 40 THEN 1
            WHEN rt.RandomType < 55 THEN 2
            WHEN rt.RandomType < 63 THEN 3
            WHEN rt.RandomType < 66 THEN 4
            WHEN rt.RandomType < 71 THEN 5
            WHEN rt.RandomType < 78 THEN 6
            WHEN rt.RandomType < 82 THEN 7
            WHEN rt.RandomType < 87 THEN 8
            WHEN rt.RandomType < 90 THEN 9
            WHEN rt.RandomType < 95 THEN 10
            ELSE 11
        END AS TransactionTypeId
) t

CROSS APPLY
(
    SELECT
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 85 THEN 3
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 92 THEN 1
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 96 THEN 2
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 98 THEN 4
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 99 THEN 5
            ELSE 6
        END AS TransactionStatusId
) s

CROSS APPLY
(
    SELECT
        CASE
            WHEN t.TransactionTypeId IN (1, 3, 6, 7, 10, 11)
                THEN 'D'

            WHEN t.TransactionTypeId IN (4, 5, 8, 9)
                THEN 'C'

            WHEN t.TransactionTypeId = 2
                THEN
                    CASE
                        WHEN ABS(CHECKSUM(NEWID())) % 2 = 0
                            THEN 'C'
                        ELSE 'D'
                    END
        END AS TransactionDirection
) d

CROSS APPLY
(
    SELECT
        CASE

            WHEN t.TransactionTypeId = 1
                THEN CAST(
                    10 + ABS(CHECKSUM(NEWID())) % 1491
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 2
                THEN CAST(
                    100 + ABS(CHECKSUM(NEWID())) % 9901
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 3
                THEN CAST(
                    50 + ABS(CHECKSUM(NEWID())) % 1951
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 4
                THEN CAST(
                    500 + ABS(CHECKSUM(NEWID())) % 9501
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 5
                THEN CAST(
                    4000 + ABS(CHECKSUM(NEWID())) % 9001
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 6
                THEN CAST(
                    30 + ABS(CHECKSUM(NEWID())) % 971
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 7
                THEN CAST(
                    5 + ABS(CHECKSUM(NEWID())) % 96
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 8
                THEN CAST(
                    20 + ABS(CHECKSUM(NEWID())) % 1481
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 9
                THEN CAST(
                    10 + ABS(CHECKSUM(NEWID())) % 491
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 10
                THEN CAST(
                    500 + ABS(CHECKSUM(NEWID())) % 3001
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 11
                THEN CAST(
                    100 + ABS(CHECKSUM(NEWID())) % 1901
                    AS DECIMAL(18,2)
                )

        END AS Amount
) x

OUTER APPLY
(
    SELECT TOP (1)
        MerchantId,
        Name
    FROM dbo.Merchant
    ORDER BY NEWID()
) m

LEFT JOIN dbo.TransactionType tt
    ON tt.TransactionTypeId = t.TransactionTypeId

ORDER BY NEWID();