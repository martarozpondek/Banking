CREATE TABLE LoanPaymentStatus
(
	LoanPaymentStatusId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_LoanPaymentStatus PRIMARY KEY (LoanPaymentStatusId),
	CONSTRAINT UQ_LoanPaymentStatus_Code UNIQUE (Code)
);