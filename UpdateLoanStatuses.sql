USE Banking;
WITH LoansToUpdate AS
(
    SELECT
        LoanId,
        LoanStatusId,
        ROW_NUMBER() OVER (ORDER BY LoanId) AS rn
    FROM dbo.Loan
    WHERE LoanStatusId = 3
)
SELECT
    LoanId,
    LoanStatusId AS CurrentStatusId,
    CASE
        WHEN rn <= 30 THEN 2
        ELSE 4
    END AS NewStatusId,
    CASE
        WHEN rn <= 30 THEN 'Active'
        ELSE 'Overdue'
    END AS NewStatus
FROM LoansToUpdate
WHERE rn <= 40
ORDER BY rn;

SET XACT_ABORT ON;

BEGIN TRANSACTION;

;WITH LoansToUpdate AS
(
    SELECT
        LoanId,
        ROW_NUMBER() OVER (ORDER BY LoanId) AS rn
    FROM dbo.Loan
    WHERE LoanStatusId = 3
)
UPDATE l
SET LoanStatusId =
    CASE
        WHEN u.rn <= 30 THEN 2  -- Active
        ELSE 4                  -- Overdue
    END
FROM dbo.Loan AS l
JOIN LoansToUpdate AS u
    ON u.LoanId = l.LoanId
WHERE u.rn <= 40;

SELECT
    ls.Name AS LoanStatus,
    COUNT(*) AS LoanCount
FROM dbo.Loan AS l
JOIN dbo.LoanStatus AS ls
    ON ls.LoanStatusId = l.LoanStatusId
GROUP BY ls.Name
ORDER BY LoanCount DESC;

COMMIT TRANSACTION;