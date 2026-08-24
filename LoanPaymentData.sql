INSERT INTO LoanPayment
(
    LoanScheduleId,
    LoanPaymentStatusId,
    PaymentDate,
    LoanPaymentTypeId,
    Amount,
    PaymentReference
)
SELECT
    ls.LoanScheduleId,

    -- STATUS PŁATNOŚCI
    CASE
        WHEN r.StatusRandom < 85 THEN 3   -- COMPLETED
        WHEN r.StatusRandom < 90 THEN 1   -- PENDING
        WHEN r.StatusRandom < 94 THEN 2   -- PROCESSING
        WHEN r.StatusRandom < 97 THEN 4   -- FAILED
        WHEN r.StatusRandom < 99 THEN 5   -- CANCELLED
        ELSE 6                            -- REVERSED
    END AS LoanPaymentStatusId,

    -- DATA PŁATNOŚCI
    CASE
        WHEN ls.PaidDate IS NOT NULL
            THEN ls.PaidDate
        ELSE
            DATEADD(
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 5),
                ls.DueDate
            )
    END AS PaymentDate,

    -- TYP PŁATNOŚCI
    CASE
        WHEN r.TypeRandom < 65 THEN 6   -- AUTOMATIC_DEBIT
        WHEN r.TypeRandom < 85 THEN 7   -- BANK_TRANSFER
        WHEN r.TypeRandom < 95 THEN 9   -- CARD_PAYMENT
        WHEN r.TypeRandom < 98 THEN 8   -- CASH_PAYMENT
        ELSE 10                          -- REFUND
    END AS LoanPaymentTypeId,

    -- KWOTA
    ls.PaidAmount AS Amount,

    -- REFERENCJA
    'LP-' +
    REPLACE(
        CONVERT(VARCHAR(36), NEWID()),
        '-',
        ''
    ) AS PaymentReference

FROM dbo.LoanSchedule ls

CROSS APPLY
(
    SELECT
        ABS(CHECKSUM(NEWID())) % 100 AS StatusRandom,
        ABS(CHECKSUM(NEWID())) % 100 AS TypeRandom
) r

WHERE
    ls.PaidAmount > 0

    -- tylko raty, które miały termin
    AND ls.DueDate <= CAST(GETDATE() AS DATE)

    -- zabezpieczenie przed duplikowaniem płatności
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.LoanPayment lp
        WHERE lp.LoanScheduleId = ls.LoanScheduleId
    );