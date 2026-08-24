INSERT INTO StandingOrder
(
    StandingOrderFrequencyId,
    Amount,
    NextExecutionDate,
    LastExecutionDate,
    FromAccountId,
    ToAccountNumber,
    RecipientName,
    Title,
    CurrencyCode,
    IsActive,
    StartDate,
    EndDate
)
SELECT TOP (100)

    -- losowa częstotliwość
    (
        SELECT TOP (1)
            StandingOrderFrequencyId
        FROM dbo.StandingOrderFrequency
        ORDER BY NEWID()
    ),

    -- kwota 50 - 5000 PLN/EUR itd.
    CAST(
        50 + (ABS(CHECKSUM(NEWID())) % 495001) / 100.0
        AS DECIMAL(18,2)
    ),

    -- następna realizacja 1-60 dni od dzisiaj
    DATEADD(
        DAY,
        1 + ABS(CHECKSUM(NEWID())) % 60,
        CAST(GETDATE() AS DATE)
    ),

    NULL,

    -- konto źródłowe
    a.AccountId,

    -- 26-cyfrowy numer rachunku odbiorcy
    RIGHT(
        '00000000000000000000000000' +
        CAST(
            ABS(CHECKSUM(NEWID())) % 100000000
            AS VARCHAR(26)
        ),
        26
    ),

    -- odbiorca
    CASE ABS(CHECKSUM(NEWID())) % 10
        WHEN 0 THEN 'Zakład Energetyczny'
        WHEN 1 THEN 'Orange Polska'
        WHEN 2 THEN 'T-Mobile Polska'
        WHEN 3 THEN 'PGE'
        WHEN 4 THEN 'Wspólnota Mieszkaniowa'
        WHEN 5 THEN 'Play'
        WHEN 6 THEN 'Polsat Box'
        WHEN 7 THEN 'ZUS'
        WHEN 8 THEN 'Urząd Skarbowy'
        ELSE 'Przelew własny'
    END,

    -- tytuł
    CASE ABS(CHECKSUM(NEWID())) % 8
        WHEN 0 THEN 'Opłata za energię elektryczną'
        WHEN 1 THEN 'Opłata za telefon'
        WHEN 2 THEN 'Opłata za internet'
        WHEN 3 THEN 'Czynsz'
        WHEN 4 THEN 'Opłata za mieszkanie'
        WHEN 5 THEN 'Rachunek miesięczny'
        WHEN 6 THEN 'Stały przelew'
        ELSE 'Opłata cykliczna'
    END,

    -- waluta taka jak na koncie
    a.CurrencyCode,

    -- 85% aktywnych
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 85
        THEN 1
        ELSE 0
    END,

    -- StartDate
    s.StartDate,

    -- EndDate zawsze po NextExecutionDate
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 20
        THEN DATEADD(
            DAY,
            180 + ABS(CHECKSUM(NEWID())) % 730,
            DATEADD(
                DAY,
                1 + ABS(CHECKSUM(NEWID())) % 60,
                CAST(GETDATE() AS DATE)
            )
        )
        ELSE NULL
    END

FROM dbo.Account a

CROSS APPLY
(
    SELECT
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 365),
            CAST(GETDATE() AS DATE)
        ) AS StartDate
) s

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.StandingOrder so
    WHERE so.FromAccountId = a.AccountId
)

ORDER BY NEWID();
