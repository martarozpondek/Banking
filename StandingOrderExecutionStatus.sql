CREATE TABLE StandingOrderExecutionStatus
(
	StandingOrderExecutionStatusId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_StandingOrderExecutionStatus PRIMARY KEY (StandingOrderExecutionStatusId),
	CONSTRAINT UQ_StandingOrderExecutionStatus_Code UNIQUE (Code)
);