CREATE TABLE Loan
(
	LoanId BIGINT IDENTITY(1,1) NOT NULL,
	CurrencyCode CHAR(3) NOT NULL,
	LoanStatusId BIGINT NOT NULL,
	CustomerId UNIQUEIDENTIFIER NOT NULL,
	InterestRateTypeId BIGINT NOT NULL,
	Amount DECIMAL(18,2) NOT NULL,
	CurrentMonthlyPayment DECIMAL(18,2) NOT NULL,
	LoanTermMonth INT NOT NULL,
	Principal DECIMAL(18,2) NOT NULL, /*kapitał */
	OutstandingPrincipal DECIMAL(18,2) NOT NULL, /* pozostało do spłacenia kapitału */
	AnnualInterestRate DECIMAL(5,2) NOT NULL, /*odsetki*/
	AccruedInterest DECIMAL(18,2) NOT NULL DEFAULT(0), /*naliczone odsetki, które jeszcze nie zostały pobrane*/
	NextInstallmentDate DATE NOT NULL,
	ActiveFrom DATE NOT NULL,
	ActiveTo DATE NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_Loan_CreatedAt DEFAULT SYSDATETIMEOFFSET(),
	UpdatedAt DATETIMEOFFSET(0) NULL,

	CONSTRAINT PK_Loan PRIMARY KEY (LoanId),
	CONSTRAINT FK_Loan_Currency FOREIGN KEY (CurrencyCode) REFERENCES Currency(CurrencyCode),
	CONSTRAINT FK_Loan_LoanStatus FOREIGN KEY (LoanStatusId) REFERENCES LoanStatus(LoanStatusId),
	CONSTRAINT FK_Loan_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
	CONSTRAINT FK_Loan_InterestRateType FOREIGN KEY (InterestRateTypeId) REFERENCES InterestRateType(InterestRateTypeId),
	CONSTRAINT CK_Loan_Amount CHECK (Amount > 0),
	CONSTRAINT CK_Loan_CurrentMonthlyPayment CHECK (CurrentMonthlyPayment > 0),
    CONSTRAINT CK_Loan_Principal CHECK (Principal > 0),
	CONSTRAINT CK_Loan_AnnualInterestRate CHECK ( AnnualInterestRate >= 0 AND AnnualInterestRate <= 100),
	CONSTRAINT CK_Loan_AccruedInterest CHECK (AccruedInterest >= 0),
	CONSTRAINT CK_Loan_Dates CHECK ( ActiveTo IS NULL OR ActiveTo >= ActiveFrom),
	CONSTRAINT CK_Loan_LoanTermMonth CHECK (LoanTermMonth > 0),
	CONSTRAINT CK_Loan_OutstandingPrincipal CHECK (OutstandingPrincipal >= 0 AND OutstandingPrincipal <= Principal),
	CONSTRAINT CK_Loan_PrincipalAmount CHECK (Amount >= Principal),
	CONSTRAINT CK_Loan_InstallmentDate CHECK( ActiveTo IS NULL OR NextInstallmentDate <= ActiveTo),
	CONSTRAINT CK_Loan_NextInstallmentDate CHECK ( NextInstallmentDate >= ActiveFrom)
);