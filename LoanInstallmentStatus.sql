CREATE TABLE LoanInstallmentStatus
(
	LoanInstallmentStatusId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_LoanInstallmentStatus PRIMARY KEY (LoanInstallmentStatusId),
	CONSTRAINT UQ_LoanInstallmentStatus_Code UNIQUE (Code)
);