INSERT INTO Loan
(
    CurrencyCode,
    LoanStatusId,
    CustomerId,
    InterestRateTypeId,
    Amount,
    CurrentMonthlyPayment,
    LoanTermMonth,
    Principal,
    OutstandingPrincipal,
    AnnualInterestRate,
    AccruedInterest,
    NextInstallmentDate,
    ActiveFrom,
    ActiveTo
)
SELECT TOP (100)

    -- WALUTA
    cur.CurrencyCode,

    -- STATUS KREDYTU
    ls.LoanStatusId,

    -- KLIENT
    cu.CustomerId,

    -- TYP OPROCENTOWANIA
    ir.InterestRateTypeId,

    -- KWOTA KREDYTU
    v.Amount,

    -- RATA MIESIĘCZNA
    CAST(
        CASE
            WHEN v.MonthlyRate = 0
                THEN v.Principal / v.LoanTermMonth

            ELSE
                v.Principal *
                (
                    v.MonthlyRate *
                    POWER(
                        1 + v.MonthlyRate,
                        v.LoanTermMonth
                    )
                )
                /
                (
                    POWER(
                        1 + v.MonthlyRate,
                        v.LoanTermMonth
                    ) - 1
                )
        END
        AS DECIMAL(18,2)
    ) AS CurrentMonthlyPayment,

    -- OKRES KREDYTU
    v.LoanTermMonth,

    -- KAPITAŁ
    v.Principal,

    -- POZOSTAŁY KAPITAŁ
    v.OutstandingPrincipal,

    -- OPROCENTOWANIE ROCZNE
    v.AnnualInterestRate,

    -- NALICZONE ODSETKI
    v.AccruedInterest,

    -- NASTĘPNA RATA
    DATEADD(
        MONTH,
        1,
        v.ActiveFrom
    ) AS NextInstallmentDate,

    -- DATA ROZPOCZĘCIA
    v.ActiveFrom,

    -- DATA ZAKOŃCZENIA
    v.ActiveTo

FROM dbo.Customer cu

-- losowa waluta dla każdego kredytu
CROSS APPLY
(
    SELECT TOP (1)
        CurrencyCode
    FROM dbo.Currency
    ORDER BY NEWID()
) cur

-- losowy status dla każdego kredytu
CROSS APPLY
(
    SELECT TOP (1)
        LoanStatusId
    FROM dbo.LoanStatus
    ORDER BY NEWID()
) ls

-- losowy typ oprocentowania dla każdego kredytu
CROSS APPLY
(
    SELECT TOP (1)
        InterestRateTypeId
    FROM dbo.InterestRateType
    ORDER BY NEWID()
) ir

-- generowanie parametrów kredytu
CROSS APPLY
(
    SELECT

        -- kwota 10 000 - 300 000
        CAST(
            10000 +
            ABS(CHECKSUM(NEWID())) % 290001
            AS DECIMAL(18,2)
        ) AS Amount,

        -- okres 12 - 120 miesięcy
        12 +
        ABS(CHECKSUM(NEWID())) % 109 AS LoanTermMonth,

        -- oprocentowanie 5.00% - 15.00%
        CAST(
            5.00 +
            (ABS(CHECKSUM(NEWID())) % 1001) / 100.0
            AS DECIMAL(5,2)
        ) AS AnnualInterestRate,

        -- data rozpoczęcia z ostatnich 5 lat
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 1825),
            CAST(GETDATE() AS DATE)
        ) AS ActiveFrom

) base

-- wyliczamy kapitał i oprocentowanie miesięczne
CROSS APPLY
(
    SELECT

        base.Amount AS Amount,

        base.LoanTermMonth AS LoanTermMonth,

        base.AnnualInterestRate AS AnnualInterestRate,

        CAST(
            base.AnnualInterestRate / 100.0 / 12.0
            AS DECIMAL(18,10)
        ) AS MonthlyRate,

        base.ActiveFrom AS ActiveFrom,

        -- Principal = 90-100% kwoty kredytu
        CAST(
            base.Amount *
            (
                0.90 +
                (ABS(CHECKSUM(NEWID())) % 11) / 100.0
            )
            AS DECIMAL(18,2)
        ) AS Principal

) calc

-- wyliczamy pozostały kapitał i odsetki
CROSS APPLY
(
    SELECT

        calc.Amount,

        calc.LoanTermMonth,

        calc.AnnualInterestRate,

        calc.MonthlyRate,

        calc.ActiveFrom,

        calc.Principal,

        -- pozostało 0-100% kapitału
        CAST(
            calc.Principal *
            (
                ABS(CHECKSUM(NEWID())) % 101
            ) / 100.0
            AS DECIMAL(18,2)
        ) AS OutstandingPrincipal,

        -- naliczone odsetki 0-500 zł
        CAST(
            ABS(CHECKSUM(NEWID())) % 501
            AS DECIMAL(18,2)
        ) AS AccruedInterest,

        -- 70% kredytów nadal aktywnych
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 70
                THEN NULL

            ELSE
                DATEADD(
                    MONTH,
                    calc.LoanTermMonth,
                    calc.ActiveFrom
                )
        END AS ActiveTo

) v

WHERE
    -- gwarantujemy, że kolejna rata może być po ActiveFrom
    v.ActiveFrom <= DATEADD(
        MONTH,
        -1,
        CAST(GETDATE() AS DATE)
    )

ORDER BY NEWID();