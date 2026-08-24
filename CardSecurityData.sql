INSERT INTO CardSecurity
(
    CardId,
    PinRetryCount,
    BlockedUntil,
    IsBlocked,
    PinChangedAt
)
SELECT
    c.CardId,

    x.PinRetryCount,

    CASE
        WHEN x.IsBlocked = 1
        THEN DATEADD(
            HOUR,
            1 + ABS(CHECKSUM(NEWID())) % 72,
            SYSDATETIMEOFFSET()
        )
        ELSE NULL
    END AS BlockedUntil,

    x.IsBlocked,

    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 90
        THEN DATEADD(
            DAY,
            ABS(CHECKSUM(NEWID())) % 365,
            CAST(c.IssuedAt AS DATETIMEOFFSET)
        )
        ELSE NULL
    END AS PinChangedAt

FROM dbo.Card c

CROSS APPLY
(
    SELECT
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 80 THEN 0
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 95 THEN 1
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 99 THEN 2
            ELSE 3
        END AS PinRetryCount
) p

CROSS APPLY
(
    SELECT
        p.PinRetryCount,
        CASE
            WHEN p.PinRetryCount = 3 THEN 1
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 2 THEN 1
            ELSE 0
        END AS IsBlocked
) x

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.CardSecurity cs
    WHERE cs.CardId = c.CardId
);