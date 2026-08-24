INSERT INTO AccountOverdraft
(
    AccountId,
    OverdraftLimit,
    InterestRate,
    UsedAmount,
    ActiveFrom,
    ActiveTo
)
SELECT TOP (100)
    a.AccountId,
    r.OverdraftLimit,
    r.InterestRate,
    CAST(
        ROUND(r.OverdraftLimit * r.UsedPct, 2)
        AS DECIMAL(18,2)
    ) AS UsedAmount,
    d.ActiveFrom,
    d.ActiveTo

FROM Account a

/* sprawdzamy, czy konto nie ma już overdraftu
left join AccountId Unique - only one overdraft to one account*/
LEFT JOIN AccountOverdraft ao ON ao.AccountId = a.AccountId

-- losujemy limit, oprocentowanie i procent wykorzystania
CROSS APPLY
(
    SELECT
        CAST(
            (ABS(CHECKSUM(NEWID())) % 1900000 + 100000) / 100.0 
			/*CHECKSUM(NEWID()) change random value to number, 
			ABS without a minus sign - absolute value,
			range from 100 000 to 1 999 999*/
            AS DECIMAL(18,2) /*a maximum of 18 digits, including 2 after the decimal point */
        ) AS OverdraftLimit,

        CAST(
            (ABS(CHECKSUM(NEWID())) % 1001 + 800) / 100.0 /*(800 – 1800)/100 -- 8.00 – 18.00 */
            AS DECIMAL(5,2)
        ) AS InterestRate,

        CAST(
            ABS(CHECKSUM(NEWID())) % 81 /*Maximum - 80% */
            AS DECIMAL(5,2)
        ) / 100.0 AS UsedPct
) r

-- losujemy datę rozpoczęcia i ewentualnego zakończenia
CROSS APPLY
(
    SELECT
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 1500), /* date from the last of 1500 days */
            CAST(GETDATE() AS DATE) /*data only without time */
        ) AS ActiveFrom
) startDate

CROSS APPLY
(
    SELECT
        startDate.ActiveFrom AS ActiveFrom,

        CASE
            -- około 15% overdraftów zakończonych
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 15
            THEN DATEADD(
                DAY,
                ABS(CHECKSUM(NEWID()))
                % (
                    DATEDIFF(
                        DAY,
                        startDate.ActiveFrom,
                        CAST(GETDATE() AS DATE)
                    ) + 1
                ),
                startDate.ActiveFrom
            )
            ELSE NULL
        END AS ActiveTo
) d

WHERE ao.AccountId IS NULL

ORDER BY NEWID();