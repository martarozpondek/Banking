INSERT INTO LoanStatusHistory
(
    LoanId,
    OldStatusId,
    NewStatusId,
    ChangedAt
)

-- =====================================================
-- 1. PENDING → ACTIVE
-- =====================================================

SELECT
    l.LoanId,
    1 AS OldStatusId,
    2 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 30,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId IN (2,3,4,5,6)

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 2
)


UNION ALL


-- =====================================================
-- 2. ACTIVE → PAID_OFF
-- =====================================================

SELECT
    l.LoanId,
    2 AS OldStatusId,
    3 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 365,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId = 3

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 3
)


UNION ALL


-- =====================================================
-- 3. ACTIVE → OVERDUE
-- =====================================================

SELECT
    l.LoanId,
    2 AS OldStatusId,
    4 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 365,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId IN (4,5)

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 4
)


UNION ALL


-- =====================================================
-- 4. OVERDUE → DEFAULTED
-- =====================================================

SELECT
    l.LoanId,
    4 AS OldStatusId,
    5 AS NewStatusId,

    DATEADD(
        DAY,
        365 + ABS(CHECKSUM(NEWID())) % 365,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId = 5

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 5
)


UNION ALL


-- =====================================================
-- 5. ACTIVE → SUSPENDED
-- =====================================================

SELECT
    l.LoanId,
    2 AS OldStatusId,
    6 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 365,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId = 6

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 6
)


UNION ALL


-- =====================================================
-- 6. PENDING → CANCELLED
-- =====================================================

SELECT
    l.LoanId,
    1 AS OldStatusId,
    7 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 30,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId = 7

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 7
);

SELECT
    t.name AS TableName,
    SUM(p.rows) AS RecordsCount
FROM sys.tables AS t
INNER JOIN sys.partitions AS p
    ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;