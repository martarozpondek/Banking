INSERT INTO CardTransactionAuthorization
(
    CardId,
    MerchantId,
    Amount,
    CardTransactionAuthorizationStatusId,
    AuthorizedAt,
    CreatedAt,
    UpdatedAt,
    AuthorizationCode,
    CurrencyCode,
    TransactionId
)
SELECT TOP (500)
    c.CardId,

    m.MerchantId,

    CAST(
        (ABS(CHECKSUM(NEWID())) % 500000) / 100.0 + 5.00
        AS DECIMAL(18,2)
    ) AS Amount,

    s.CardTransactionAuthorizationStatusId,

    d.AuthorizedAt,

    d.AuthorizedAt AS CreatedAt,

    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 70
        THEN DATEADD(
            MINUTE,
            ABS(CHECKSUM(NEWID())) % 1440,
            d.AuthorizedAt
        )
        ELSE NULL
    END AS UpdatedAt,

    RIGHT(
        '000000' +
        CAST(
            ABS(CHECKSUM(NEWID())) % 1000000
            AS VARCHAR(6)
        ),
        6
    ) AS AuthorizationCode,

    cur.CurrencyCode,

    NULL AS TransactionId

FROM dbo.Card c

CROSS APPLY
(
    SELECT TOP (1)
        m1.MerchantId
    FROM dbo.Merchant m1
    ORDER BY NEWID()
) m

CROSS APPLY
(
    SELECT TOP (1)
        s1.CardTransactionAuthorizationStatusId
    FROM dbo.CardTransactionAuthorizationStatus s1
    ORDER BY NEWID()
) s

CROSS APPLY
(
    SELECT TOP (1)
        c1.CurrencyCode
    FROM dbo.Currency c1
    ORDER BY NEWID()
) cur

CROSS APPLY
(
    SELECT
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 365),
            SYSDATETIMEOFFSET()
        ) AS AuthorizedAt
) d

ORDER BY NEWID();

SELECT *
FROM dbo.CardTransactionAuthorizationStatus;
