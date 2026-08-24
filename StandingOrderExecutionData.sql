INSERT INTO StandingOrderExecution
(
    StandingOrderId,
    TransactionId,
    ExecutionDate,
    Amount,
    StandingOrderExecutionStatusId,
    FailureReason
)
SELECT TOP (250)

    so.StandingOrderId,

    -- tylko część wykonanych zleceń będzie
    -- powiązana z transakcją
    CASE
        WHEN s.StatusId = 3
             AND ABS(CHECKSUM(NEWID())) % 100 < 80
        THEN
            (
                SELECT TOP (1)
                    at.TransactionId
                FROM dbo.AccountTransaction at
                WHERE at.AccountId = so.FromAccountId
                  AND at.Amount = so.Amount
                  AND at.TransactionDirection = 'D'
                ORDER BY NEWID()
            )
        ELSE NULL
    END AS TransactionId,

    -- data wykonania
    s.ExecutionDate,

    -- kwota taka sama jak w zleceniu
    so.Amount,

    s.StatusId,

    -- powód błędu tylko dla FAILED
    CASE
        WHEN s.StatusId = 4 THEN
            CASE ABS(CHECKSUM(NEWID())) % 5
                WHEN 0 THEN 'Insufficient funds'
                WHEN 1 THEN 'Account blocked'
                WHEN 2 THEN 'Transaction rejected by bank'
                WHEN 3 THEN 'Technical error'
                ELSE 'Execution failed'
            END
        WHEN s.StatusId = 5 THEN
            'Standing order cancelled'
        ELSE NULL
    END AS FailureReason

FROM dbo.StandingOrder so

CROSS APPLY
(
    SELECT
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 70 THEN 3
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 82 THEN 1
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 90 THEN 2
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 96 THEN 4
            ELSE 5
        END AS StatusId,

        DATEADD(
            DAY,
            ABS(CHECKSUM(NEWID())) % 365,
            so.StartDate
        ) AS ExecutionDate
) s

WHERE s.ExecutionDate <= CAST(GETDATE() AS DATE)

ORDER BY NEWID();