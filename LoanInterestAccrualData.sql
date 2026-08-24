INSERT INTO LoanInterestAccrual
(
    LoanId,
    AccrualDate,
    PrincipalBalance,
    InterestRate,
    InterestAmount
)
SELECT
    l.LoanId,

    d.AccrualDate,

    -- saldo kapitału
    CAST(
        CASE
            WHEN l.OutstandingPrincipal > 0
                THEN l.OutstandingPrincipal
            ELSE 0
        END
        AS DECIMAL(18,2)
    ) AS PrincipalBalance,

    l.AnnualInterestRate AS InterestRate,

    -- dzienne odsetki
    CAST(
        CASE
            WHEN l.OutstandingPrincipal > 0
                THEN
                    l.OutstandingPrincipal
                    * l.AnnualInterestRate
                    / 100.0
                    / 365.0
            ELSE 0
        END
        AS DECIMAL(18,2)
    ) AS InterestAmount

FROM dbo.Loan l

CROSS APPLY
(
    SELECT TOP (30)
        DATEADD(
            DAY,
            -(n - 1),
            CAST(GETDATE() AS DATE)
        ) AS AccrualDate
    FROM
    (
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM sys.all_columns a1
        CROSS JOIN sys.all_columns a2
    ) x
) d

WHERE
    l.ActiveFrom <= d.AccrualDate

    -- jeżeli kredyt ma ActiveTo,
    -- nie generujemy odsetek po jego zakończeniu
    AND
    (
        l.ActiveTo IS NULL
        OR l.ActiveTo >= d.AccrualDate
    )

    -- zabezpieczenie przed duplikatami
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.LoanInterestAccrual lia
        WHERE lia.LoanId = l.LoanId
          AND lia.AccrualDate = d.AccrualDate
    );