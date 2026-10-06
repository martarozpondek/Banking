USE Banking;

CREATE PROCEDURE BranchPerformanceReport
(
	@CustomerId UNIQUEIDENTIFIER,
	@BranchId BIGINT
)
AS
	SELECT COUNT(CustomerId)
SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ParentColumn
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE
    OBJECT_NAME(fk.parent_object_id) IN
    ('Branch', 'Employee', 'Customer', 'Account', 'Loan')
    OR
    OBJECT_NAME(fk.referenced_object_id) IN
    ('Branch', 'Employee', 'Customer', 'Account', 'Loan')
ORDER BY
    ChildTable,
    ParentTable;