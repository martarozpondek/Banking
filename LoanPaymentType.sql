CREATE TABLE LoanPaymentType
(
	LoanPaymentTypeId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_LoanPaymentType PRIMARY KEY (LoanPaymentTypeId),
	CONSTRAINT UQ_LoanPaymentType_Code UNIQUE (Code)
);