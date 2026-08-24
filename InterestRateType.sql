CREATE TABLE InterestRateType
(
	InterestRateTypeId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_InterestRateType PRIMARY KEY (InterestRateTypeId),
	CONSTRAINT UQ_InterestRateType_Code UNIQUE (Code)
);