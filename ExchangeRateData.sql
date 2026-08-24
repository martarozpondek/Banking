;WITH Dates AS
(
    SELECT
        CAST(DATEADD(DAY, -364, GETDATE()) AS DATE) AS RateDate

    UNION ALL

    SELECT
        DATEADD(DAY, 1, RateDate)
    FROM Dates
    WHERE RateDate < CAST(GETDATE() AS DATE)
),
Rates AS
(
    SELECT
        c.CurrencyCode,
        d.RateDate,

        CASE c.CurrencyCode
            WHEN 'EUR' THEN 4.25
            WHEN 'USD' THEN 3.65
            WHEN 'GBP' THEN 4.95
            WHEN 'CHF' THEN 4.55
            WHEN 'CZK' THEN 0.17
            WHEN 'DKK' THEN 0.57
            WHEN 'HUF' THEN 0.011
            WHEN 'JPY' THEN 0.023
            WHEN 'NOK' THEN 0.37
            WHEN 'SEK' THEN 0.38
            WHEN 'CAD' THEN 2.65
            WHEN 'AUD' THEN 2.40
        END AS BaseRate

    FROM dbo.Currency c
    CROSS JOIN Dates d
    WHERE c.CurrencyCode <> 'PLN'
)
INSERT INTO dbo.ExchangeRate
(
    CurrencyCode,
    ExchangeRateDate,
    CurrencyConversionRate,
    Multiplier
)
SELECT
    CurrencyCode,

    DATEADD(
        SECOND,
        0,
        CAST(RateDate AS DATETIMEOFFSET)
    ) AS ExchangeRateDate,

    CAST(
        BaseRate +
        (
            (ABS(CHECKSUM(
                NEWID()
            )) % 2001 - 1000) / 100000.0
        )
        AS DECIMAL(10,4)
    ) AS CurrencyConversionRate,

    1.0000 AS Multiplier

FROM Rates r

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.ExchangeRate er
    WHERE er.CurrencyCode = r.CurrencyCode
      AND er.ExchangeRateDate =
          CAST(r.RateDate AS DATETIMEOFFSET)
)
OPTION (MAXRECURSION 400);