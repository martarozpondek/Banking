INSERT INTO LedgerEntry
(
    AccountId,
    TransactionId,
    Debit,
    Credit,
    BalanceAfterEntry,
    PostingDate
)
SELECT
    t.AccountId,
    t.TransactionId,

    -- Debit = pieniądze wychodzące z konta
    CASE
        WHEN t.TransactionDirection = 'D'
            THEN t.Amount
        ELSE 0
    END AS Debit,

    -- Credit = pieniądze wpływające na konto
    CASE
        WHEN t.TransactionDirection = 'C'
            THEN t.Amount
        ELSE 0
    END AS Credit,

    t.BalanceAfterTransaction AS BalanceAfterEntry,

    t.TransactionDate AS PostingDate

FROM dbo.AccountTransaction t

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.LedgerEntry l
    WHERE l.TransactionId = t.TransactionId
);
