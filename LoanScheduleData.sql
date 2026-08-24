INSERT INTO LoanSchedule
(
    InstallmentNumber,
    LoanId,
    LoanInstallmentStatusId,
    DueDate,
    PrincipalAmount,
    InterestAmount,
    PaidAmount,
    PaidDate
)
SELECT
    n.InstallmentNumber,

    l.LoanId,

    -- STATUS RATY
    CASE
        -- przyszła rata
        WHEN d.DueDate > CAST(GETDATE() AS DATE)
            THEN lsScheduled.LoanInstallmentStatusId

        -- rata zapłacona
        WHEN p.IsPaid = 1
            THEN lsPaid.LoanInstallmentStatusId

        -- rata częściowo zapłacona
        WHEN p.IsPartiallyPaid = 1
            THEN lsPartial.LoanInstallmentStatusId

        -- rata przeterminowana
        ELSE lsOverdue.LoanInstallmentStatusId
    END AS LoanInstallmentStatusId,

    d.DueDate,

    -- KAPITAŁ
    calc.PrincipalAmount,

    -- ODSETKI
    calc.InterestAmount,

    -- ZAPŁACONA KWOTA
    CASE
        WHEN p.IsPaid = 1
            THEN calc.TotalAmount

        WHEN p.IsPartiallyPaid = 1
            THEN CAST(
                calc.TotalAmount *
                (
                    30 +
                    ABS(CHECKSUM(NEWID())) % 51
                ) / 100.0
                AS DECIMAL(18,2)
            )

        ELSE 0
    END AS PaidAmount,

    -- DATA ZAPŁATY
    CASE
        WHEN p.IsPaid = 1
            THEN DATEADD(
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 10),
                d.DueDate
            )

        WHEN p.IsPartiallyPaid = 1
            THEN DATEADD(
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 5),
                d.DueDate
            )

        ELSE NULL
    END AS PaidDate

FROM dbo.Loan l

-- generowanie numerów rat 1-120
CROSS APPLY
(
    SELECT TOP (120)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS InstallmentNumber
    FROM sys.all_columns a1
    CROSS JOIN sys.all_columns a2
) n

-- tylko tyle rat, ile ma dany kredyt
CROSS APPLY
(
    SELECT
        DATEADD(
            MONTH,
            n.InstallmentNumber - 1,
            l.ActiveFrom
        ) AS DueDate
) d

-- wyliczenie kapitału i odsetek
CROSS APPLY
(
    SELECT

        -- kapitał raty
        CAST(
            CASE
                -- ostatnia rata = wszystko co zostało
                WHEN n.InstallmentNumber = l.LoanTermMonth
                    THEN
                        l.Principal
                        -
                        (
                            CAST(
                                l.Principal / l.LoanTermMonth
                                AS DECIMAL(18,2)
                            )
                            * (l.LoanTermMonth - 1)
                        )

                ELSE
                    CAST(
                        l.Principal / l.LoanTermMonth
                        AS DECIMAL(18,2)
                    )
            END
            AS DECIMAL(18,2)
        ) AS PrincipalAmount,

        -- odsetki od pozostałego kapitału
        CAST(
            (
                l.Principal
                -
                (
                    CAST(
                        l.Principal / l.LoanTermMonth
                        AS DECIMAL(18,2)
                    )
                    * (n.InstallmentNumber - 1)
                )
            )
            *
            (
                l.AnnualInterestRate / 100.0 / 12.0
            )
            AS DECIMAL(18,2)
        ) AS InterestAmount
) raw

-- całkowita rata
CROSS APPLY
(
    SELECT
        raw.PrincipalAmount,
        raw.InterestAmount,
        CAST(
            raw.PrincipalAmount + raw.InterestAmount
            AS DECIMAL(18,2)
        ) AS TotalAmount
) calc

-- ustalamy czy rata została zapłacona
CROSS APPLY
(
    SELECT
        CASE
            WHEN d.DueDate < CAST(GETDATE() AS DATE)
                 AND ABS(CHECKSUM(NEWID())) % 100 < 85
                THEN 1
            ELSE 0
        END AS IsPaid,

        CASE
            WHEN d.DueDate < CAST(GETDATE() AS DATE)
                 AND ABS(CHECKSUM(NEWID())) % 100 BETWEEN 85 AND 94
                THEN 1
            ELSE 0
        END AS IsPartiallyPaid
) p

-- STATUS: SCHEDULED
CROSS APPLY
(
    SELECT TOP (1)
        LoanInstallmentStatusId
    FROM dbo.LoanInstallmentStatus
    WHERE Code = 'SCHEDULED'
) lsScheduled

-- STATUS: PAID
CROSS APPLY
(
    SELECT TOP (1)
        LoanInstallmentStatusId
    FROM dbo.LoanInstallmentStatus
    WHERE Code = 'PAID'
) lsPaid

-- STATUS: PARTIALLY_PAID
CROSS APPLY
(
    SELECT TOP (1)
        LoanInstallmentStatusId
    FROM dbo.LoanInstallmentStatus
    WHERE Code = 'PARTIALLY_PAID'
) lsPartial

-- STATUS: OVERDUE
CROSS APPLY
(
    SELECT TOP (1)
        LoanInstallmentStatusId
    FROM dbo.LoanInstallmentStatus
    WHERE Code = 'OVERDUE'
) lsOverdue

WHERE
    n.InstallmentNumber <= l.LoanTermMonth

    -- zabezpieczenie przed ponownym wstawieniem tych samych rat
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.LoanSchedule existing
        WHERE existing.LoanId = l.LoanId
          AND existing.InstallmentNumber = n.InstallmentNumber
    );
