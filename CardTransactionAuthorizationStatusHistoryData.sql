
INSERT INTO CardTransactionAuthorizationStatusHistory
(
    CardTransactionAuthorizationId,
    OldStatusId,
    NewStatusId,
    ChangedAt
)

-- =====================================================
-- 1. PENDING → APPROVED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    2 AS NewStatusId,
    DATEADD(
        MINUTE,
        1 + ABS(CHECKSUM(NEWID())) % 10,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 2


UNION ALL


-- =====================================================
-- 2. PENDING → DECLINED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    3 AS NewStatusId,
    DATEADD(
        MINUTE,
        1 + ABS(CHECKSUM(NEWID())) % 10,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 3


UNION ALL


-- =====================================================
-- 3. PENDING → REVERSED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    2 AS NewStatusId,
    DATEADD(
        MINUTE,
        1 + ABS(CHECKSUM(NEWID())) % 10,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 4

UNION ALL

SELECT
    a.CardTransactionAuthorizationId,
    2 AS OldStatusId,
    4 AS NewStatusId,
    DATEADD(
        MINUTE,
        30 + ABS(CHECKSUM(NEWID())) % 1440,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 4


UNION ALL


-- =====================================================
-- 4. PENDING → EXPIRED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    5 AS NewStatusId,
    DATEADD(
        HOUR,
        1 + ABS(CHECKSUM(NEWID())) % 48,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 5


UNION ALL


-- =====================================================
-- 5. PENDING → CANCELLED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    6 AS NewStatusId,
    DATEADD(
        MINUTE,
        1 + ABS(CHECKSUM(NEWID())) % 60,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 6;
