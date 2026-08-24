CREATE TABLE LoanInterestAccrual /* daily interest accrual */
(
    LoanInterestAccrualId BIGINT IDENTITY(1,1),
    LoanId BIGINT NOT NULL,
    AccrualDate DATE NOT NULL,
    PrincipalBalance DECIMAL(18,2) NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL,
    InterestAmount DECIMAL(18,2) NOT NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_LoanInterestAccrual_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

    CONSTRAINT PK_LoanInterestAccrual PRIMARY KEY (LoanInterestAccrualId),
    CONSTRAINT FK_LoanInterestAccrual_Loan FOREIGN KEY (LoanId) REFERENCES Loan(LoanId),
	CONSTRAINT UQ_LoanInterestAccrual_Date UNIQUE (LoanId, AccrualDate),
	CONSTRAINT CK_LoanInterestAccrual_PrincipalBalance CHECK (PrincipalBalance >=0),
	CONSTRAINT CK_LoanInterestAccrual_InterestRate CHECK (InterestRate >=0 AND InterestRate <=100),
	CONSTRAINT CK_LoanInterestAccrual_InterestAmount CHECK (InterestAmount >=0)
);