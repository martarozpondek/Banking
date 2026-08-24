INSERT INTO Card
(
    CustomerId,
    AccountId,
    CardHolderName,
    CardNumberHash,
    LastFourDigits,
    IssuedAt,
    CardStatusId,
    ActivatedAt,
    ExpiresAt
)
SELECT
    a.CustomerId,

    a.AccountId,

    CONCAT(
        c.FirstName,
        ' ',
        c.LastName
    ) AS CardHolderName,

    HASHBYTES(
        'SHA2_512',
        '4' +
        RIGHT(
            '000000000000000' +
            CAST(a.AccountId AS VARCHAR(15)),
            15
        )
    ) AS CardNumberHash,

    RIGHT(
        RIGHT(
            '000000000000000' +
            CAST(a.AccountId AS VARCHAR(15)),
            15
        ),
        4
    ) AS LastFourDigits,

    d.IssuedAt,

    s.CardStatusId,

    CASE
        WHEN s.Code IN ('ACTIVE', 'BLOCKED')
            THEN DATEADD(
                DAY,
                ABS(CHECKSUM(NEWID())) % 30,
                CAST(d.IssuedAt AS DATETIME)
            )
        ELSE NULL
    END AS ActivatedAt,

    DATEADD(
        YEAR,
        4,
        d.IssuedAt
    ) AS ExpiresAt

FROM dbo.Account a

INNER JOIN dbo.Customer c
    ON c.CustomerId = a.CustomerId

CROSS APPLY
(
    SELECT
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 1000),
            CAST(GETDATE() AS DATE)
        ) AS IssuedAt
) d

CROSS APPLY
(
    SELECT TOP (1)
        cs.CardStatusId,
        cs.Code
    FROM dbo.CardStatus cs
    ORDER BY NEWID()
) s

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Card card
    WHERE card.AccountId = a.AccountId
);
