CREATE TABLE OverdraftUsageType
(
	OverdraftUsageTypeId BIGINT IDENTITY(1,1) NOT NULL,
    Code VARCHAR(30) NOT NULL,
    Name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_OverdraftUsageType PRIMARY KEY (OverdraftUsageTypeId),
    CONSTRAINT UQ_OverdraftUsageType_Code UNIQUE (Code)
);
