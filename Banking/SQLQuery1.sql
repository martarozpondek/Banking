CREATE DATABASE Banking;
USE Banking;

CREATE TABLE Customer
(
	CustomerId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
	FirstName NVARCHAR(100) NOT NULL,
	LastName NVARCHAR(100) NOT NULL,
	Email VARCHAR(255),
	PhoneNumber VARCHAR(20),
	BirthDate DATE NOT NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_Customer_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_Customer PRIMARY KEY (CustomerId)
);

CREATE TABLE Currency
(
    CurrencyCode CHAR(3) NOT NULL,
    CurrencyName NVARCHAR(50) NOT NULL,
	CurrencySymbol NVARCHAR(5) NOT NULL,

    CONSTRAINT PK_Currency PRIMARY KEY (CurrencyCode)
	
);

CREATE TABLE TransactionType
(
	TransactionTypeId INT IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(150) NOT NULL,
	Code VARCHAR(50) NOT NULL CONSTRAINT UQ_TransactionType_Code UNIQUE(Code),
	Description NVARCHAR(250) NOT NULL,

	CONSTRAINT PK_TransactionType PRIMARY KEY (TransactionTypeId)
);

CREATE TABLE TransactionStatus
(
    TransactionStatusId INT IDENTITY(1,1) NOT NULL,
    Code VARCHAR(50) NOT NULL CONSTRAINT UQ_TransactionStatus_Code UNIQUE(Code),
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_TransactionStatus PRIMARY KEY (TransactionStatusId)
);

CREATE TABLE AccountType
(
	AccountTypeId INT IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(150) NOT NULL,
	Code VARCHAR(50) NOT NULL CONSTRAINT UQ_AccountType_Code UNIQUE(Code),
	Description NVARCHAR(250) NOT NULL,

	CONSTRAINT PK_AccountType PRIMARY KEY (AccountTypeId)
);

CREATE TABLE MerchantCategoryCode
(
    MCCCode CHAR(4) NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_MerchantCategoryCode PRIMARY KEY(MCCCode)
);

CREATE TABLE Merchant
(
	MerchantId INT IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(250) NOT NULL,
	Street NVARCHAR(350) NOT NULL,
	BuildingNumber VARCHAR(20) NOT NULL,
	PostalCode VARCHAR(10) NOT NULL,
	City NVARCHAR(150) NOT NULL,
	CountryCode CHAR(2) NOT NULL,
	MCCCode CHAR(4) NOT NULL,
	/*	AccountNumber VARCHAR(26) NOT NULL CONSTRAINT UQ_Account_AccountNumber UNIQUE (AccountNumber) */
	CONSTRAINT PK_Merchant PRIMARY KEY (MerchantId),
	CONSTRAINT FK_Merchant_MerchantCategoryCode FOREIGN KEY (MCCCode) REFERENCES MerchantCategoryCode(MCCCode)
);

CREATE TABLE OverdraftUsageType
(
	OverdraftUsageTypeId BIGINT IDENTITY(1,1) NOT NULL,
    Code VARCHAR(30) NOT NULL,
    Name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_OverdraftUsageType PRIMARY KEY (OverdraftUsageTypeId),
    CONSTRAINT UQ_OverdraftUsageType_Code UNIQUE (Code)
);


CREATE TABLE Account
(
	AccountId BIGINT IDENTITY(1,1) NOT NULL,
	CustomerId UNIQUEIDENTIFIER NOT NULL,
	AccountNumber VARCHAR(26) NOT NULL CONSTRAINT UQ_Account_AccountNumber UNIQUE (AccountNumber),
	AccountTypeId INT NOT NULL,
	CurrencyCode CHAR(3) NOT NULL,
	CurrentBalance DECIMAL(18,2) NOT NULL CONSTRAINT DF_Account_CurrentBalance DEFAULT (0),
	AvailableBalance DECIMAL(18,2) NOT NULL CONSTRAINT DF_Account_AvailableBalance DEFAULT (0),
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_Account_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_Account PRIMARY KEY (AccountId),
	CONSTRAINT FK_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
	CONSTRAINT FK_Account_Currency FOREIGN KEY (CurrencyCode) REFERENCES Currency(CurrencyCode),
	CONSTRAINT FK_Account_AccountType FOREIGN KEY (AccountTypeId) REFERENCES AccountType(AccountTypeId)
);


CREATE TABLE AccountTransaction
(
	TransactionId BIGINT IDENTITY(1,1) NOT NULL,
	TransactionReference VARCHAR(50) NOT NULL CONSTRAINT UQ_AccountTransaction_Code UNIQUE(TransactionReference),
	TransactionTypeId INT NOT NULL,
	TransactionStatusId INT NOT NULL,
	TransactionDirection CHAR(1) NOT NULL,
	MerchantId INT NULL,
	AccountId BIGINT NOT NULL,
	Amount DECIMAL(18,2) NOT NULL,
	TransactionDate DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_AccountTransaction_TransactionDate DEFAULT SYSDATETIMEOFFSET(),
	TransactionCurrencyCode CHAR(3) NOT NULL,
	Title NVARCHAR(200) NOT NULL,
	BalanceAfterTransaction DECIMAL(18,2) NOT NULL,
	

	CONSTRAINT PK_AccountTransaction PRIMARY KEY (TransactionId),
	CONSTRAINT FK_AccountTransaction_Account FOREIGN KEY (AccountId) REFERENCES Account(AccountId), 
	CONSTRAINT FK_AccountTransaction_Currency FOREIGN KEY (TransactionCurrencyCode) REFERENCES Currency(CurrencyCode),
	CONSTRAINT FK_AccountTransaction_Type FOREIGN KEY (TransactionTypeId) REFERENCES TransactionType(TransactionTypeId),
	CONSTRAINT FK_AccountTransaction_Status FOREIGN KEY (TransactionStatusId) REFERENCES TransactionStatus(TransactionStatusId),
	CONSTRAINT FK_AccountTransaction_Merchant FOREIGN KEY (MerchantId) REFERENCES Merchant(MerchantId), 
	CONSTRAINT CK_AccountTransaction_TransactionDirection CHECK (TransactionDirection IN ('D', 'C')),
);

CREATE TABLE AccountOverdraft
(
	OverdraftId INT IDENTITY(1,1) NOT NULL,
	AccountId BIGINT NOT NULL CONSTRAINT UQ_AccountOverdraft_Account UNIQUE(AccountId),
	OverdraftLimit DECIMAL(18,2) NOT NULL,
	InterestRate DECIMAL(5,2) NOT NULL,
	UsedAmount DECIMAL(18,2) NOT NULL DEFAULT (0),
	AvailableAmount AS
	(
		OverdraftLimit - UsedAmount
	) PERSISTED,
	ActiveFrom DATE NOT NULL,
	ActiveTo DATE NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_AccountOverdraft_CreatedAt DEFAULT SYSDATETIMEOFFSET(),
	UpdatedAt DATETIMEOFFSET(0) NULL,

	CONSTRAINT PK_AccountOverdraft PRIMARY KEY (OverdraftId),
	CONSTRAINT FK_AccountOverdraft_Account FOREIGN KEY (AccountId) REFERENCES Account(AccountId)
);

CREATE TABLE LedgerEntry
(
    LedgerEntryId BIGINT IDENTITY(1,1),
	AccountId BIGINT NOT NULL,
	TransactionId BIGINT NOT NULL,
    Debit DECIMAL(18,2) NOT NULL DEFAULT(0),
    Credit DECIMAL(18,2) NOT NULL DEFAULT(0),
	BalanceAfterEntry DECIMAL(18,2) NOT NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_LedgerEntry_CreatedAt DEFAULT SYSDATETIMEOFFSET(),
	PostingDate DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_LedgerEntry_PostingDate DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_LedgerEntry PRIMARY KEY(LedgerEntryId),
	CONSTRAINT FK_LedgerEntry_Account FOREIGN KEY (AccountId) REFERENCES Account(AccountId),
	CONSTRAINT FK_LedgerEntry_AccountTransaction FOREIGN KEY (TransactionId) REFERENCES AccountTransaction(TransactionId)

);

CREATE TABLE OverdraftUsage
(
    OverdraftUsageId BIGINT IDENTITY(1,1) NOT NULL,
    OverdraftId INT NOT NULL,
	OverdraftUsageTypeId BIGINT NOT NULL,
    TransactionId BIGINT NOT NULL,
    AmountUsed DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_OverdraftUsage_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

    CONSTRAINT PK_OverdraftUsage PRIMARY KEY (OverdraftUsageId),
	CONSTRAINT FK_OverdraftUsage_Overdraft FOREIGN KEY (OverdraftId) REFERENCES AccountOverdraft(OverdraftId),
	CONSTRAINT FK_OverdraftUsage_AccountTransaction FOREIGN KEY(TransactionId) REFERENCES AccountTransaction(TransactionId),
	CONSTRAINT FK_OverdraftUsage_Type FOREIGN KEY (OverdraftUsageTypeId) REFERENCES OverdraftUsageType(OverdraftUsageTypeId)
);

CREATE TABLE OverdraftInterest
(
	OverdraftInterestId BIGINT IDENTITY(1,1) NOT NULL,
	OverdraftId INT NOT NULL,
	TransactionStatusId INT NOT NULL,
	TransactionId BIGINT NULL,
	InterestDate DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_OverdraftInterest_InterestDate DEFAULT SYSDATETIMEOFFSET(),
	InterestPeriodFrom DATE NOT NULL,
	InterestPeriodTo DATE NOT NULL,
	Amount DECIMAL(18,2) NOT NULL,
	Rate DECIMAL(5,2) NOT NULL,

	CONSTRAINT PK_OverdraftInterest PRIMARY KEY (OverdraftInterestId),
	CONSTRAINT FK_OverdraftInterest_Overdraft FOREIGN KEY (OverdraftId) REFERENCES AccountOverdraft(OverdraftId),
	CONSTRAINT FK_OverdraftInterest_AccountTransaction FOREIGN KEY (TransactionId) REFERENCES AccountTransaction(TransactionId),
	CONSTRAINT FK_OverdraftInterest_TransactionStatus FOREIGN KEY (TransactionStatusId) REFERENCES TransactionStatus(TransactionStatusId)

);

CREATE TABLE CardStatus
(
	CardStatusId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_CardStatus PRIMARY KEY (CardStatusId),
	CONSTRAINT UQ_CardStatus_Code UNIQUE (Code),
);

CREATE TABLE Card
(
	CardId BIGINT IDENTITY(1,1) NOT NULL,
	CustomerId UNIQUEIDENTIFIER NOT NULL,
	AccountId BIGINT NOT NULL,
	CardHolderName NVARCHAR(100) NOT NULL,
	CardNumberHash VARBINARY(64) NOT NULL, /* Stores a cryptographic hash of the card number */
	LastFourDigits CHAR(4) NOT NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_Card_CreatedAt DEFAULT SYSDATETIMEOFFSET(),  /*created at system */
	IssuedAt DATE NOT NULL, /* Date when the card was issued to the customer */
	CardStatusId BIGINT NOT NULL,
	ActivatedAt Date NULL,
	ExpiresAt DATE NOT NULL,
	

	CONSTRAINT PK_Card PRIMARY KEY (CardId),
	CONSTRAINT FK_Card_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
	CONSTRAINT FK_Card_Account FOREIGN KEY (AccountId) REFERENCES Account(AccountId),
	CONSTRAINT FK_CardStatus_Card FOREIGN KEY (CardStatusId) REFERENCES CardStatus(CardStatusId), 
	CONSTRAINT UQ_Card_CardNumberHash UNIQUE(CardNumberHash),
	CONSTRAINT CK_Card_LastFourDigits CHECK(LastFourDigits NOT LIKE '%[^0-9]%' AND LEN(LastFourDigits)=4)
);

CREATE TABLE CardSecurity
(
	CardAuthorizationId BIGINT IDENTITY(1,1) NOT NULL,
	CardId BIGINT NOT NULL CONSTRAINT UQ_CardSecurity_Card UNIQUE(CardId),
	PinRetryCount INT NOT NULL DEFAULT(0),
	BlockedUntil DATETIMEOFFSET(0) NULL,
	IsBlocked BIT NOT NULL DEFAULT(0),
	PinChangedAt DATETIMEOFFSET(0) NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_CardSecurity_CreatedAt DEFAULT SYSDATETIMEOFFSET(),
	UpdatedAt DATETIMEOFFSET(0) NULL,

	CONSTRAINT PK_CardAuthorization PRIMARY KEY (CardAuthorizationId),
	CONSTRAINT FK_CardAuthorization FOREIGN KEY (CardId) REFERENCES Card(CardId),
	CONSTRAINT CK_CardSecurity_PinRetryCount CHECK(PinRetryCount BETWEEN 0 AND 3) /*PIN entry limit: 0–3 attempts */
);

CREATE TABLE CardTransactionAuthorizationStatus
(
	CardTransactionAuthorizationStatusId INT IDENTITY(1,1) NOT NULL,
	Code NVARCHAR(50) NOT NULL CONSTRAINT UQ_CardTransactionAuthorizationStatus_Code UNIQUE (Code),
	Name VARCHAR(100) NOT NULL,

	CONSTRAINT PK_CardTransactionAuthorizationStatus PRIMARY KEY (CardTransactionAuthorizationStatusId)
);

CREATE TABLE CardTransactionAuthorization
(

	CardTransactionAuthorizationId BIGINT IDENTITY(1,1) NOT NULL,
	CardId BIGINT NOT NULL,
	MerchantId INT NOT NULL,
	Amount DECIMAL(18,2) NOT NULL CONSTRAINT CK_CardTransactionAuthorization_Amount CHECK (Amount > 0),
	CardTransactionAuthorizationStatusId INT NOT NULL,
	AuthorizedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_CardTransactionAuthorization_AuthorizationDate DEFAULT SYSDATETIMEOFFSET(), /* Date and time when the transaction was authorized by the bank */
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_CardTransactionAuthorization_CreatedAt DEFAULT SYSDATETIMEOFFSET(), /* Date and time when the record was created in the database */
	UpdatedAt DATETIMEOFFSET(0) NULL, /* Date and time when the record was last updated */
	AuthorizationCode CHAR(6) NOT NULL CONSTRAINT UQ_CardTransactionAuthorization_AuthorizationCode UNIQUE (AuthorizationCode),
	CurrencyCode CHAR(3) NOT NULL,
	TransactionId BIGINT NULL,


	CONSTRAINT PK_CardTransactionAuthorization PRIMARY KEY (CardTransactionAuthorizationId),
	CONSTRAINT FK_CardTransactionAuthorization_Card FOREIGN KEY (CardId) REFERENCES Card(CardId),
	CONSTRAINT FK_CardTransactionAuthorization_Merchant FOREIGN KEY (MerchantId) REFERENCES Merchant(MerchantId),
	CONSTRAINT FK_CardTransactionAuthorization_CardTransactionAuthorizationStatus FOREIGN KEY (CardTransactionAuthorizationStatusId) REFERENCES CardTransactionAuthorizationStatus(CardTransactionAuthorizationStatusId),
	CONSTRAINT FK_CardTransactionAuthorization_Currency FOREIGN KEY (CurrencyCode) REFERENCES Currency(CurrencyCode),
	CONSTRAINT FK_CardTransactionAuthorization_Transaction FOREIGN KEY (TransactionId) REFERENCES AccountTransaction(TransactionId),
	CONSTRAINT CK_CardTransactionAuthorization_AuthorizationCode CHECK (AuthorizationCode NOT LIKE '%[^0-9]%')
);

CREATE TABLE CardTransactionAuthorizationStatusHistory
(
	CardTransactionAuthorizationStatusHistoryId INT IDENTITY(1,1) NOT NULL,
	CardTransactionAuthorizationId BIGINT NOT NULL,
	OldStatusId INT NULL,
	NewStatusId INT NOT NULL,
	ChangedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_CardTransactionAuthorizationStatusHistory_ChangedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_CardTransactionAuthorizationStatusHistory PRIMARY KEY (CardTransactionAuthorizationStatusHistoryId),
	CONSTRAINT FK_CardTransactionAuthorizationStatusHistory_OldStatus FOREIGN KEY (OldStatusId) REFERENCES CardTransactionAuthorizationStatus(CardTransactionAuthorizationStatusId),
	CONSTRAINT FK_CardTransactionAuthorizationStatusHistory_NewStatus FOREIGN KEY (NewStatusId) REFERENCES CardTransactionAuthorizationStatus(CardTransactionAuthorizationStatusId),
	CONSTRAINT FK_CardTransactionAuthorizationStatusHistory_CardTransactionAuthorization FOREIGN KEY (CardTransactionAuthorizationId) REFERENCES CardTransactionAuthorization(CardTransactionAuthorizationId),
);

CREATE TABLE ExchangeRate
(
	ExchangeRateId INT IDENTITY(1,1) NOT NULL,
	CurrencyCode CHAR(3) NOT NULL,
	ExchangeRateDate DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_ExchangeRate_ExchangeRateDate DEFAULT SYSDATETIMEOFFSET(),
	CurrencyConversionRate DECIMAL(10, 4) NOT NULL,
	Multiplier DECIMAL(10,4) NOT NULL CONSTRAINT DF_ExchangeRate_Multiplier DEFAULT (1), 
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_ExchangeRate_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_ExchangeRate PRIMARY KEY (ExchangeRateId),
	CONSTRAINT FK_ExchangeRate_Currency FOREIGN KEY (CurrencyCode) REFERENCES Currency(CurrencyCode),
	CONSTRAINT UQ_ExchangeRate_CurrencyDate UNIQUE (CurrencyCode, ExchangeRateDate),
	CONSTRAINT CK_ExchangeRate_Rate CHECK (CurrencyConversionRate > 0),
	CONSTRAINT CK_ExchangeRate_Multiplier CHECK (Multiplier > 0)
);

CREATE TABLE LoanStatus
(
	LoanStatusId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_LoanStatus PRIMARY KEY (LoanStatusId),
	CONSTRAINT UQ_LoanStatus_Code UNIQUE (Code)
);


CREATE TABLE InterestRateType
(
	InterestRateTypeId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_InterestRateType PRIMARY KEY (InterestRateTypeId),
	CONSTRAINT UQ_InterestRateType_Code UNIQUE (Code)
);

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
	Principal DECIMAL(18,2) NOT NULL, /*kapita³ */
	OutstandingPrincipal DECIMAL(18,2) NOT NULL, /* pozosta³o do sp³acenia kapita³u */
	AnnualInterestRate DECIMAL(5,2) NOT NULL, /*odsetki*/
	AccruedInterest DECIMAL(18,2) NOT NULL DEFAULT(0), /*naliczone odsetki, które jeszcze nie zosta³y pobrane*/
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

CREATE TABLE LoanStatusHistory
(
    LoanStatusHistoryId BIGINT IDENTITY(1,1) NOT NULL,
    LoanId BIGINT NOT NULL,
    OldStatusId BIGINT NULL,
    NewStatusId BIGINT NOT NULL,
    ChangedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_LoanStatusHistory PRIMARY KEY (LoanStatusHistoryId),
	CONSTRAINT FK_LoanStatusHistory_Loan FOREIGN KEY (LoanId) REFERENCES Loan(LoanId),
	CONSTRAINT FK_LoanStatusHistory_OldStatus FOREIGN KEY (OldStatusId) REFERENCES LoanStatus(LoanStatusId),
	CONSTRAINT FK_LoanStatusHistory_NewStatus FOREIGN KEY (NewStatusId) REFERENCES LoanStatus(LoanStatusId)
);

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

CREATE TABLE LoanInstallmentStatus
(
	LoanInstallmentStatusId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_LoanInstallmentStatus PRIMARY KEY (LoanInstallmentStatusId),
	CONSTRAINT UQ_LoanInstallmentStatus_Code UNIQUE (Code)
);

CREATE TABLE LoanSchedule
(
	LoanScheduleId BIGINT IDENTITY(1,1) NOT NULL,
	InstallmentNumber INT NOT NULL,
	LoanId BIGINT NOT NULL,
	LoanInstallmentStatusId BIGINT NOT NULL,
	DueDate DATE NOT NULL,
    PrincipalAmount DECIMAL(18,2) NOT NULL,
    InterestAmount DECIMAL(18,2) NOT NULL,
    TotalAmount AS ( PrincipalAmount + InterestAmount ) PERSISTED,
	PaidAmount DECIMAL(18,2) NOT NULL DEFAULT(0),
    PaidDate DATE NULL,
	RemainingAmount AS (PrincipalAmount + InterestAmount - PaidAmount) PERSISTED,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_LoanSchedule_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_LoanSchedule PRIMARY KEY (LoanScheduleId),
	CONSTRAINT FK_LoanSchedule_Loan FOREIGN KEY (LoanId) REFERENCES Loan(LoanId),
	CONSTRAINT FK_LoanSchedule_LoanInstallmentStatus FOREIGN KEY (LoanInstallmentStatusId) REFERENCES LoanInstallmentStatus(LoanInstallmentStatusId),
	CONSTRAINT CK_LoanSchedule_Amounts CHECK (PrincipalAmount >= 0 AND InterestAmount >= 0),
	CONSTRAINT UQ_LoanSchedule_Installment UNIQUE (LoanId, InstallmentNumber),
	CONSTRAINT CK_LoanSchedule_PaidAmount CHECK (PaidAmount >=0 AND PaidAmount <= TotalAmount)
);


CREATE TABLE LoanPaymentType
(
	LoanPaymentTypeId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_LoanPaymentType PRIMARY KEY (LoanPaymentTypeId),
	CONSTRAINT UQ_LoanPaymentType_Code UNIQUE (Code)
);

CREATE TABLE LoanPaymentStatus
(
	LoanPaymentStatusId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_LoanPaymentStatus PRIMARY KEY (LoanPaymentStatusId),
	CONSTRAINT UQ_LoanPaymentStatus_Code UNIQUE (Code)
);

CREATE TABLE LoanPayment
(
	LoanPaymentId BIGINT IDENTITY(1,1) NOT NULL,
	LoanScheduleId BIGINT NULL,
	LoanPaymentStatusId BIGINT NOT NULL,
	PaymentDate DATE NOT NULL,
	LoanPaymentTypeId BIGINT NOT NULL,
	Amount DECIMAL(18,2) NOT NULL,
	PaymentReference VARCHAR(50) UNIQUE,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_LoanPayment_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_LoanPayment PRIMARY KEY (LoanPaymentId),
	CONSTRAINT FK_LoanPayment_LoanSchedule FOREIGN KEY (LoanScheduleId) REFERENCES LoanSchedule(LoanScheduleId),
	CONSTRAINT FK_LoanPayment_LoanPaymentType FOREIGN KEY (LoanPaymentTypeId) REFERENCES LoanPaymentType(LoanPaymentTypeId),
	CONSTRAINT FK_LoanPayment_LoanPaymentStatus FOREIGN KEY (LoanPaymentStatusId) REFERENCES LoanPaymentStatus(LoanPaymentStatusId),
	CONSTRAINT CK_LoanPayment_Amount CHECK (Amount > 0)
);

CREATE TABLE Branch
(
	BranchId BIGINT IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(150) NOT NULL,
	Code VARCHAR(50) NOT NULL CONSTRAINT UQ_Branch_Code UNIQUE(Code),
	Street NVARCHAR(350) NOT NULL,
	BuildingNumber VARCHAR(20) NOT NULL,
	PostalCode VARCHAR(10) NOT NULL,
	City NVARCHAR(150) NOT NULL,
	CountryCode CHAR(2) NOT NULL,

	CONSTRAINT PK_Branch PRIMARY KEY (BranchId)
);

CREATE TABLE Employee 
(
	EmployeeId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
	BranchId BIGINT NOT NULL,
	FirstName NVARCHAR(100) NOT NULL,
	LastName NVARCHAR(100) NOT NULL,
	Email VARCHAR(255),
	PhoneNumber VARCHAR(20),
	BirthDate DATE NOT NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_Employee_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_Employee PRIMARY KEY (EmployeeId),
	CONSTRAINT FK_Employee_Branch FOREIGN KEY (BranchId) REFERENCES Branch(BranchId)
);

CREATE TABLE StandingOrderExecutionStatus
(
	StandingOrderExecutionStatusId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_StandingOrderExecutionStatus PRIMARY KEY (StandingOrderExecutionStatusId),
	CONSTRAINT UQ_StandingOrderExecutionStatus_Code UNIQUE (Code)
);

CREATE TABLE StandingOrderFrequency
(
	StandingOrderFrequencyId BIGINT IDENTITY(1,1) NOT NULL,
	Code VARCHAR(30) NOT NULL, 
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_StandingOrderFrequency PRIMARY KEY (StandingOrderFrequencyId),
	CONSTRAINT UQ_StandingOrderFrequency_Code UNIQUE (Code)
);

CREATE TABLE StandingOrder
(
	StandingOrderId BIGINT IDENTITY(1,1) NOT NULL,
	StandingOrderFrequencyId BIGINT NOT NULL,
	Amount DECIMAL(18,2) NOT NULL,
	NextExecutionDate DATE NOT NULL,
	LastExecutionDate DATE NULL,
	FromAccountId BIGINT NOT NULL,
	ToAccountNumber VARCHAR(26) NOT NULL,
	RecipientName NVARCHAR(200) NOT NULL,
	Title NVARCHAR(150) NOT NULL,
	CurrencyCode CHAR(3) NOT NULL,
	IsActive BIT NOT NULL DEFAULT(1),
	StartDate DATE NOT NULL,
	EndDate DATE NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_StandingOrder_CreatedAt DEFAULT SYSDATETIMEOFFSET(),
	UpdatedAt DATETIMEOFFSET(0) NULL,

	CONSTRAINT PK_StandingOrder PRIMARY KEY (StandingOrderId),
	CONSTRAINT FK_StandingOrder_Currency FOREIGN KEY (CurrencyCode) REFERENCES Currency(CurrencyCode),
	CONSTRAINT FK_StandingOrder_FromAccount FOREIGN KEY (FromAccountId) REFERENCES Account(AccountId),
	CONSTRAINT FK_StandingOrder_StandingOrderFrequency FOREIGN KEY (StandingOrderFrequencyId) REFERENCES StandingOrderFrequency(StandingOrderFrequencyId),
	CONSTRAINT CK_StandingOrder_Amount CHECK (Amount > 0),
	CONSTRAINT CK_StandingOrder_Dates CHECK (EndDate IS NULL OR EndDate >= StartDate),
	CONSTRAINT CK_StandingOrder_NextExecution CHECK (NextExecutionDate >= StartDate),
	CONSTRAINT CK_StandingOrder_ToAccountNumber CHECK (LEN(ToAccountNumber) = 26 AND ToAccountNumber NOT LIKE '%[^0-9]%'),
	CONSTRAINT CK_StandingOrder_NextExecution_EndDate CHECK (EndDate IS NULL OR NextExecutionDate <= EndDate),
	CONSTRAINT CK_StandingOrder_LastExecutionDate CHECK (LastExecutionDate IS NULL OR LastExecutionDate >= StartDate),
	CONSTRAINT CK_StandingOrder_ExecutionDate CHECK (LastExecutionDate IS NULL OR LastExecutionDate < NextExecutionDate)
);

CREATE TABLE StandingOrderExecution
(
    StandingOrderExecutionId BIGINT IDENTITY(1,1) NOT NULL,
    StandingOrderId BIGINT NOT NULL,
    TransactionId BIGINT NULL,
    ExecutionDate DATE NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    StandingOrderExecutionStatusId BIGINT NOT NULL,
    FailureReason NVARCHAR(250) NULL,
    CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_StandingOrderExecution_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

    CONSTRAINT PK_StandingOrderExecution PRIMARY KEY (StandingOrderExecutionId),
    CONSTRAINT FK_StandingOrderExecution_StandingOrder FOREIGN KEY (StandingOrderId) REFERENCES StandingOrder(StandingOrderId),
    CONSTRAINT FK_StandingOrderExecution_Transaction FOREIGN KEY (TransactionId) REFERENCES AccountTransaction(TransactionId),
    CONSTRAINT FK_StandingOrderExecution_Status FOREIGN KEY (StandingOrderExecutionStatusId) REFERENCES StandingOrderExecutionStatus(StandingOrderExecutionStatusId),
	CONSTRAINT CK_StandingOrderExecution_Amount CHECK (Amount > 0)
);

INSERT INTO CardStatus (Code, Name) VALUES ('CREATED','Created'),('ACTIVE', 'Active'),('INACTIVE','Inactive'),('BLOCKED','Blocked'),('CANCELLED','Cancelled'),('EXPIRED','Expired');
INSERT INTO CardTransactionAuthorizationStatus (Code, Name) VALUES  ('PENDING', 'Pending'),('APPROVED', 'Approved'),('DECLINED', 'Declined'),('REVERSED', 'Reversed'),('EXPIRED', 'Expired'),('CANCELLED', 'Cancelled');
INSERT INTO LoanInstallmentStatus  (Code, Name) VALUES ('SCHEDULED', 'Scheduled'),('DUE', 'Due'),('PARTIALLY_PAID', 'Partially Paid'),('PAID', 'Paid'),('OVERDUE', 'Overdue'),('CANCELLED', 'Cancelled');
INSERT INTO LoanPaymentStatus (Code, Name) VALUES  ('PENDING', 'Pending'),('PROCESSING', 'Processing'),('COMPLETED', 'Completed'),('FAILED', 'Failed'),('CANCELLED', 'Cancelled'),('REVERSED', 'Reversed');
INSERT INTO LoanStatus (Code, Name) VALUES ('PENDING', 'Pending'),('ACTIVE', 'Active'),('PAID_OFF', 'Paid Off'),('OVERDUE', 'Overdue'),('DEFAULTED', 'Defaulted'),('SUSPENDED', 'Suspended'),('CANCELLED', 'Cancelled');
INSERT INTO TransactionStatus (Code, Name) VALUES ('PENDING', 'Pending'),('PROCESSING', 'Processing'),('COMPLETED', 'Completed'),('FAILED', 'Failed'),('CANCELLED', 'Cancelled'),('REVERSED', 'Reversed');
INSERT INTO StandingOrderExecutionStatus (Code, Name)VALUES('PENDING', 'Pending'),('PROCESSING', 'Processing'),('COMPLETED', 'Completed'),('FAILED', 'Failed'),('CANCELLED', 'Cancelled'),('REJECTED', 'Rejected');
INSERT INTO StandingOrderFrequency (Code, Name) VALUES ('WEEKLY', 'Weekly'),('BIWEEKLY', 'Every two weeks'),('MONTHLY', 'Monthly'),('QUARTERLY', 'Quarterly'),('SEMIANNUALLY', 'Every six months'),('ANNUALLY', 'Annually');

INSERT INTO AccountType (Name, Code, Description) VALUES 
('CURRENT_ACCOUNT', 'Current Account', 'Standard current bank account'),
('SAVINGS_ACCOUNT', 'Savings Account', 'Account designed for saving money'),
('BASIC_ACCOUNT', 'Basic Account', 'Basic bank account with essential services'),
('KIDS_ACCOUNT', 'Kids Account', 'Bank account designed for children'),
('YOUNG_PEOPLE_ACCOUNT', 'Young People Account', 'Bank account designed for young customers'),
('STUDENT_ACCOUNT', 'Student Account', 'Bank account designed for students'),
('PREMIUM_ACCOUNT', 'Premium Account', 'Account with additional premium banking services'),
('BUSINESS_ACCOUNT', 'Business Account', 'Bank account designed for business customers'),
('FOREIGN_CURRENCY_ACCOUNT', 'Foreign Currency Account', 'Account held in a foreign currency'),
('JOINT_ACCOUNT', 'Joint Account', 'Account shared by two or more customers');

INSERT INTO TransactionType (Name, Code, Description) VALUES
('Card payment', 'CARD_PAYMENT', 'Payment made by card'),
('Bank transfer', 'BANK_TRANSFER', 'Bank transfer'),
('ATM withdrawal', 'ATM_WITHDRAWAL', 'Cash withdrawal from ATM'),
('Cash deposit', 'CASH_DEPOSIT', 'Cash deposited into an account'),
('Salary', 'SALARY', 'Salary payment'),
('Direct debit', 'DIRECT_DEBIT', 'Direct debit payment'),
('Bank fee', 'BANK_FEE', 'Bank fee charged to the account'),
('Refund', 'REFUND', 'Refund of a previous payment'),
('Interest', 'INTEREST', 'Interest credited to the account'),
('Loan payment', 'LOAN_PAYMENT', 'Loan repayment'),
('Standing order', 'STANDING_ORDER', 'Payment generated by a standing order');

INSERT INTO OverdraftUsageType (Code, Name) VALUES
('CARD_PAYMENT', 'Card payment'),
('BANK_TRANSFER', 'Bank transfer'),
('ATM_WITHDRAWAL', 'ATM withdrawal'),
('DIRECT_DEBIT', 'Direct debit'),
('STANDING_ORDER', 'Standing order'),
('CASH_WITHDRAWAL', 'Cash withdrawal'),
('BANK_FEE', 'Bank fee'),
('LOAN_PAYMENT', 'Loan payment'),
('OTHER', 'Other');

INSERT INTO LoanPaymentType (Code, Name) VALUES
('REGULAR_INSTALLMENT', 'Regular Installment'),
('EARLY_REPAYMENT', 'Early Repayment'),
('PARTIAL_EARLY_REPAYMENT', 'Partial Early Repayment'),
('FULL_REPAYMENT', 'Full Repayment'),
('OVERPAYMENT', 'Overpayment'),
('AUTOMATIC_DEBIT', 'Automatic Debit'),
('BANK_TRANSFER', 'Bank Transfer'),
('CASH_PAYMENT', 'Cash Payment'),
('CARD_PAYMENT', 'Card Payment'),
('REFUND', 'Refund');

INSERT INTO InterestRateType (Code, Name) VALUES ('FIXED', 'Fixed interest rate'),('VARIABLE', 'Variable interest rate'),('MIXED', 'Mixed interest rate');

INSERT INTO Currency (CurrencyCode, CurrencyName, CurrencySymbol)
VALUES
('PLN', 'Polish Zloty', 'z³'),
('EUR', 'Euro', '€'),
('USD', 'US Dollar', '$'),
('GBP', 'British Pound', '?'),
('CHF', 'Swiss Franc', 'CHF'),
('CZK', 'Czech Koruna', 'Kè'),
('SEK', 'Swedish Krona', 'kr'),
('NOK', 'Norwegian Krone', 'kr'),
('DKK', 'Danish Krone', 'kr'),
('HUF', 'Hungarian Forint', 'Ft'),
('JPY', 'Japanese Yen', '?'),
('CAD', 'Canadian Dollar', 'C$'),
('AUD', 'Australian Dollar', 'A$');
INSERT INTO MerchantCategoryCode (MCCCode, CategoryName)
VALUES
('4111', 'Local/Suburban Passenger Transportation'),
('4112', 'Passenger Railways'),
('4121', 'Taxi and Ride Services'),
('4511', 'Airlines'),
('4722', 'Travel Agencies'),
('4789', 'Transportation Services'),
('4899', 'Cable, Internet and Streaming Services'),
('5211', 'Building Materials'),
('5311', 'Department Stores'),
('5331', 'Variety Stores'),
('5411', 'Grocery Stores'),
('5422', 'Freezer and Locker Meat Provisioners'),
('5441', 'Candy, Nut and Confectionery Stores'),
('5462', 'Bakeries'),
('5499', 'Miscellaneous Food Stores'),
('5541', 'Service Stations'),
('5651', 'Clothing Stores'),
('5712', 'Furniture and Home Furnishings'),
('5732', 'Electronics Stores'),
('5734', 'Computer Software Stores'),
('5812', 'Eating Places and Restaurants'),
('5813', 'Drinking Places'),
('5814', 'Fast Food Restaurants'),
('5912', 'Drug Stores and Pharmacies'),
('5921', 'Package Stores – Beer, Wine and Liquor'),
('5940', 'Bicycle Shops'),
('5941', 'Sporting Goods Stores'),
('5942', 'Book Stores'),
('5943', 'Stationery Stores'),
('5944', 'Jewelry Stores'),
('5945', 'Hobby, Toy and Game Shops'),
('5947', 'Gift, Card, Novelty and Souvenir Shops'),
('5964', 'Direct Marketing – Catalog Merchants'),
('5995', 'Pet Shops'),
('5999', 'Miscellaneous Retail Stores'),
('6011', 'Automated Cash Disbursements'),
('6012', 'Financial Institutions'),
('6300', 'Insurance Sales and Underwriting'),
('7011', 'Hotels and Motels'),
('7298', 'Health and Beauty Spas'),
('7299', 'Miscellaneous Personal Services'),
('7832', 'Motion Picture Theaters'),
('7991', 'Tourist Attractions and Exhibits'),
('7995', 'Betting and Gambling'),
('8011', 'Doctors and Physicians'),
('8021', 'Dentists and Orthodontists'),
('8099', 'Medical Services'),
('8211', 'Elementary and Secondary Schools'),
('8398', 'Charitable and Social Service Organizations'),
('8999', 'Professional Services'),
('9222', 'Fines'),
('9399', 'Government Services');

	
INSERT INTO Merchant (Name, Street, BuildingNumber, PostalCode, City, CountryCode, MCCCode) VALUES
('Biedronka', 'Aleja Wojska Polskiego', '12', '42-200', 'Czestochowa', 'PL', '5411'),
('Lidl', 'Aleja Najswietszej Maryi Panny', '45', '42-200', 'Czestochowa', 'PL', '5411'),
('Carrefour', 'Aleja Pokoju', '15', '42-200', 'Czestochowa', 'PL', '5411'),
('Zabka', 'Aleja Wolnosci', '8', '42-200', 'Czestochowa', 'PL', '5499'),
('Orlen', 'Aleja Jana Pawla II', '20', '42-202', 'Czestochowa', 'PL', '5541'),
('Shell', 'Aleja Bohaterow Monte Cassino', '10', '42-200', 'Czestochowa', 'PL', '5541'),
('McDonalds', 'Aleja Wojska Polskiego', '100', '42-200', 'Czestochowa', 'PL', '5814'),
('KFC', 'Aleja Pokoju', '5', '42-200', 'Czestochowa', 'PL', '5814'),
('Pizza Hut', 'Aleja Najswietszej Maryi Panny', '20', '42-200', 'Czestochowa', 'PL', '5812'),
('Empik', 'Aleja Najswietszej Maryi Panny', '35', '42-200', 'Czestochowa', 'PL', '5942'),
('RTV Euro AGD', 'Aleja Pokoju', '25', '42-200', 'Czestochowa', 'PL', '5732'),
('CCC', 'Aleja Wojska Polskiego', '50', '42-200', 'Czestochowa', 'PL', '5651'),
('Rossmann', 'Aleja Wolnosci', '15', '42-200', 'Czestochowa', 'PL', '5912'),
('Apteka Gemini', 'Aleja Pokoju', '30', '42-200', 'Czestochowa', 'PL', '5912'),
('Hotel Mercure', 'Ulica Poprzeczna', '10', '42-200', 'Czestochowa', 'PL', '7011'),
('Carrefour', 'RoŸdzieñskiego', '200', '40-203', 'Katowice', 'PL', '5411'),
('¯abka', '3 Maja', '15', '40-096', 'Katowice', 'PL', '5411'),
('Restauracja Silesia', 'Mariacka', '12', '40-014', 'Katowice', 'PL', '5812'),
('Biedronka', 'Bohaterów Westerplatte', '22', '65-034', 'Zielona Góra', 'PL', '5411'),
('¯abka', 'Kupiecka', '18', '65-058', 'Zielona Góra', 'PL', '5411'),
('Restauracja Winna', 'Niepodleg³oœci', '25', '65-048', 'Zielona Góra', 'PL', '5812'),
('Lidl', 'Grunwaldzka', '141', '80-264', 'Gdañsk', 'PL', '5411'),
('McDonalds', 'Podwale Grodzkie', '1', '80-895', 'Gdañsk', 'PL', '5812'),
('Apteka Gdañska', 'D³uga', '10', '80-827', 'Gdañsk', 'PL', '5912'),
('Auchan', 'Zuzanny', '20', '41-219', 'Sosnowiec', 'PL', '5411'),
('Rossmann', 'Modrzejowska', '32', '41-200', 'Sosnowiec', 'PL', '5311'),
('Restauracja Zag³êbie', 'Warszawska', '45', '41-200', 'Sosnowiec', 'PL', '5812'),
('¯abka', 'Marsza³kowska', '100', '00-001', 'Warszawa', 'PL', '5411'),
('Biedronka', 'Pu³awska', '25', '02-515', 'Warszawa', 'PL', '5411'),
('Restauracja Stary Dom', 'Pu³awska', '104', '02-620', 'Warszawa', 'PL', '5812'),
('Empik', 'Nowy Œwiat', '15', '00-029', 'Warszawa', 'PL', '5942'),
('¯abka', 'Œwidnicka', '12', '50-068', 'Wroc³aw', 'PL', '5411'),
('Carrefour', 'Gen. Hallera', '52', '53-203', 'Wroc³aw', 'PL', '5411'),
('Pizza Si', 'W³odkowica', '12', '50-072', 'Wroc³aw', 'PL', '5812'),
('Media Expert', 'Legnicka', '58', '54-204', 'Wroc³aw', 'PL', '5732'),
('¯abka', 'D³uga', '8', '31-146', 'Kraków', 'PL', '5411'),
('Carrefour', 'Pawia', '5', '31-154', 'Kraków', 'PL', '5411'),
('Restauracja Pod Anio³ami', 'Grodzka', '35', '31-001', 'Kraków', 'PL', '5812'),
('Empik', 'Floriañska', '26', '31-019', 'Kraków', 'PL', '5942'),
('¯abka', 'Krupówki', '10', '34-500', 'Zakopane', 'PL', '5411'),
('Karczma Saba³a', 'Krupówki', '37', '34-500', 'Zakopane', 'PL', '5812'),
('Sklep Górski Tatra', 'Krupówki', '42', '34-500', 'Zakopane', 'PL', '5941'),
('¯abka', 'D³uga', '12', '31-147', 'Kraków', 'PL', '5499'),
('Lidl', 'Grunwaldzka', '45', '80-241', 'Gdañsk', 'PL', '5411'),
('Biedronka', 'Pi³sudskiego', '18', '50-033', 'Wroc³aw', 'PL', '5411'),
('Orlen', 'Pu³awska', '125', '02-707', 'Warszawa', 'PL', '5541'),
('Empik', 'Kazimierza Wielkiego', '21', '50-077', 'Wroc³aw', 'PL', '5942'),
('Rossmann', 'Floriañska', '8', '31-019', 'Kraków', 'PL', '5912'),
('McDonald''s', 'Aleja Niepodleg³oœci', '15', '02-653', 'Warszawa', 'PL', '5814'),
('KFC', 'Œwiêtojañska', '32', '81-372', 'Gdynia', 'PL', '5814'),
('Decathlon', 'Zakopiañska', '62', '30-418', 'Kraków', 'PL', '5940'),
('Media Expert', 'Legnicka', '58', '54-204', 'Wroc³aw', 'PL', '5732'),
('IKEA', 'Pabianicka', '255', '93-457', '£ódŸ', 'PL', '5712'),
('Castorama', 'Obornicka', '235', '60-650', 'Poznañ', 'PL', '5211'),
('Cinema City', 'Al. Jana Paw³a II', '82', '00-175', 'Warszawa', 'PL', '7832'),
('Hotel Mercure', 'Bracka', '1', '31-005', 'Kraków', 'PL', '7011'),
('Shell', 'Zwyciêstwa', '96', '75-011', 'Koszalin', 'PL', '5541'),
('Starbucks', 'Mickiewicza', '10', '01-517', 'Warszawa', 'PL', '5812'),
('Pizzeria Da Grasso', 'Rynek', '5', '50-106', 'Wroc³aw', 'PL', '5812'),
('Allegro', 'Grunwaldzka', '182', '60-166', 'Poznañ', 'PL', '5311'),
('Decathlon', 'Bora-Komorowskiego', '37', '31-876', 'Kraków', 'PL', '5940'),
('PKP Intercity', 'Plac Dworcowy', '1', '20-406', 'Lublin', 'PL', '4112'),
('TUI', 'Marsza³kowska', '104', '00-017', 'Warszawa', 'PL', '4722'),
('LOT Polish Airlines', 'Komitetu Obrony Robotników', '43', '02-146', 'Warszawa', 'PL', '4511'),
('Uber', 'Chmielna', '85', '00-805', 'Warszawa', 'PL', '4121'),
('Bolt', 'Œwiêtego Ducha', '5', '80-834', 'Gdañsk', 'PL', '4121'),
('Cinema City', 'Pokoju', '44', '31-564', 'Kraków', 'PL', '7832'),
('Multikino', 'Z³ota', '59', '00-120', 'Warszawa', 'PL', '7832'),
('Auchan', 'Hetmañska', '16', '60-219', 'Poznañ', 'PL', '5411'),
('Carrefour', 'Powstañców Œl¹skich', '95', '53-332', 'Wroc³aw', 'PL', '5411'),
('Reserved', 'D³uga', '20', '80-831', 'Gdañsk', 'PL', '5651'),
('H&M', 'Floriañska', '26', '31-021', 'Kraków', 'PL', '5651'),
('Lidl', 'Legnicka', '58', '54-204', 'Wroc³aw', 'PL', '5411'),
('Auchan', 'Bardzka', '3', '50-516', 'Wroc³aw', 'PL', '5411'),
('Orlen', 'Grabiszyñska', '241', '53-234', 'Wroc³aw', 'PL', '5541'),
('Empik', 'Œwidnicka', '40', '50-027', 'Wroc³aw', 'PL', '5942'),
('Restauracja Konspira', 'Bogus³awskiego', '27', '50-023', 'Wroc³aw', 'PL', '5812'),
('Biedronka', 'D³uga', '23', '31-147', 'Kraków', 'PL', '5411'),
('Carrefour', 'Pawia', '5', '31-154', 'Kraków', 'PL', '5411'),
('Shell', 'Zakopiañska', '62', '30-418', 'Kraków', 'PL', '5541'),
('Hotel Krakus', 'Nowohucka', '35', '30-717', 'Kraków', 'PL', '7011'),
('Café Camelot', 'Œwiêtego Tomasza', '17', '31-022', 'Kraków', 'PL', '5812'),
('¯abka', 'Marsza³kowska', '102', '00-017', 'Warszawa', 'PL', '5411'),
('Orlen', 'Pu³awska', '145', '02-715', 'Warszawa', 'PL', '5541'),
('Empik', 'Nowy Œwiat', '15/17', '00-029', 'Warszawa', 'PL', '5942'),
('Rossmann', 'Targowa', '72', '03-734', 'Warszawa', 'PL', '5912'),
('Restauracja Stary Dom', 'Pu³awska', '104', '02-620', 'Warszawa', 'PL', '5812'),
('Uber', 'ul. Tadeusza Koœciuszki', '12', '50-038', 'Wroc³aw', 'PL', '4121'),
('Bolt', 'ul. Marsza³kowska', '104', '00-017', 'Warszawa', 'PL', '4121'),
('PKP Intercity', 'Al. Jerozolimskie', '142A', '02-305', 'Warszawa', 'PL', '4112'),
('LOT Polish Airlines', 'ul. Komitetu Obrony Robotników', '43', '02-146', 'Warszawa', 'PL', '4511'),
('Cinema City', 'ul. Pokoju', '44', '40-950', 'Katowice', 'PL', '7832'),
('Multikino', 'ul. Z³ota', '59', '00-120', 'Warszawa', 'PL', '7832'),
('Helios', 'ul. Powstañców Œl¹skich', '95', '53-332', 'Wroc³aw', 'PL', '7832'),
('Empik', 'ul. Floriañska', '18', '31-019', 'Kraków', 'PL', '5942'),
('McDonald''s', 'ul. Zakopiañska', '62', '30-418', 'Kraków', 'PL', '5814'),
('KFC', 'ul. Grójecka', '67', '02-094', 'Warszawa', 'PL', '5814'),
('Starbucks', 'ul. Szewska', '8', '50-122', 'Wroc³aw', 'PL', '5812'),
('Costa Coffee', 'ul. D³uga', '29', '80-827', 'Gdañsk', 'PL', '5812'),
('Pizza Hut', 'ul. 3 Maja', '13', '40-096', 'Katowice', 'PL', '5812'),
('Media Expert', 'ul. Legnicka', '58', '54-204', 'Wroc³aw', 'PL', '5732'),
('RTV Euro AGD', 'ul. Bora-Komorowskiego', '37', '31-876', 'Kraków', 'PL', '5732'),
('Allegro', 'ul. Grunwaldzka', '182', '60-166', 'Poznañ', 'PL', '5999'),
('Decathlon', 'ul. Pu³awska', '427', '02-801', 'Warszawa', 'PL', '5941'),
('Booking.com', 'ul. Przy Rondzie', '4', '31-547', 'Kraków', 'PL', '4722'),
('Hotel Mercure', 'ul. Z³ota', '48', '00-120', 'Warszawa', 'PL', '7011'),
('Radisson Blu', 'ul. D³ugi Targ', '19', '80-828', 'Gdañsk', 'PL', '7011'),
('Netflix', 'ul. Chmielna', '85', '00-805', 'Warszawa', 'PL', '4899'),
('Spotify', 'ul. Krucza', '50', '00-025', 'Warszawa', 'PL', '4899'),
('Google', 'ul. Emilii Plater', '53', '00-113', 'Warszawa', 'PL', '5734');

INSERT INTO Branch(Name, Code, Street, BuildingNumber, PostalCode, City, CountryCode) VALUES
('Oddzia³ Czêstochowa Centrum', 'CZWA001', 'Aleja Najœwiêtszej Maryi Panny', '35', '42-200', 'Czêstochowa', 'PL'),
('Oddzia³ Czêstochowa Pó³noc', 'CZWA002', 'Aleja Wyzwolenia', '5', '42-224', 'Czêstochowa', 'PL'),
('Oddzia³ Katowice Centrum', 'KATO001', 'Warszawska', '10', '40-008', 'Katowice', 'PL'),
('Oddzia³ Katowice Po³udnie', 'KATO002', 'Koœciuszki', '45', '40-048', 'Katowice', 'PL'),
('Oddzia³ Warszawa Centrum', 'WAW001', 'Marsza³kowska', '100', '00-017', 'Warszawa', 'PL'),
('Oddzia³ Warszawa Mokotów', 'WAW002', 'Pu³awska', '45', '02-515', 'Warszawa', 'PL'),
('Oddzia³ Warszawa Wola', 'WAW003', 'Towarowa', '25', '00-839', 'Warszawa', 'PL'),
('Oddzia³ Kraków Centrum', 'KRK001', 'Floriañska', '15', '31-019', 'Kraków', 'PL'),
('Oddzia³ Kraków Podgórze', 'KRK002', 'Wadowicka', '3', '30-347', 'Kraków', 'PL'),
('Oddzia³ Wroc³aw Centrum', 'WRO001', 'Œwidnicka', '20', '50-068', 'Wroc³aw', 'PL'),
('Oddzia³ Wroc³aw Krzyki', 'WRO002', 'Powstañców Œl¹skich', '95', '53-332', 'Wroc³aw', 'PL'),
('Oddzia³ Gdañsk Centrum', 'GDA001', 'D³uga', '12', '80-827', 'Gdañsk', 'PL'),
('Oddzia³ Gdañsk Wrzeszcz', 'GDA002', 'Grunwaldzka', '100', '80-244', 'Gdañsk', 'PL'),
('Oddzia³ Poznañ Centrum', 'POZ001', 'Œwiêty Marcin', '40', '61-807', 'Poznañ', 'PL'),
('Oddzia³ Poznañ Je¿yce', 'POZ002', 'D¹browskiego', '50', '60-842', 'Poznañ', 'PL'),
('Oddzia³ £ódŸ Centrum', 'LOD001', 'Piotrkowska', '100', '90-425', '£ódŸ', 'PL'),
('Oddzia³ Zielona Góra Centrum', 'ZGR001', 'Niepodleg³oœci', '25', '65-048', 'Zielona Góra', 'PL'),
('Oddzia³ Sosnowiec Centrum', 'SOS001', 'Warszawska', '45', '41-200', 'Sosnowiec', 'PL'),
('Oddzia³ Lublin Centrum', 'LUB001', 'Krakowskie Przedmieœcie', '20', '20-002', 'Lublin', 'PL'),
('Oddzia³ Zakopane Centrum', 'ZAK001', 'Krupówki', '30', '34-500', 'Zakopane', 'PL');

INSERT INTO Employee (BranchId, FirstName, LastName, Email, PhoneNumber, BirthDate) VALUES
(1, 'Pawe³', 'Kowalczyk', 'pawel.kowalczyk@banking.pl', '550123101', '1986-04-12'),
(1, 'Natalia', 'Krupa', 'natalia.krupa@banking.pl', '550123102', '1992-09-25'),
(1, 'Pawe³', 'Kowalczyk', 'pawel.kowalczyk@banking.pl', '550123101', '1986-04-12'),
(1, 'Mariusz', 'Szulc', 'mariusz.szulc@banking.pl', '550123103', '1983-06-18'),
(1, 'Anna', 'Kowalska', 'anna.kowalska@banking.pl', '501234101', '1988-03-15'),
(1, 'Piotr', 'Nowak', 'piotr.nowak@banking.pl', '502345102', '1985-07-22'),
(1, 'Katarzyna', 'Wiœniewska', 'katarzyna.wisniewska@banking.pl', '503456103', '1991-11-08'),
(1, 'Anna', 'Kowalska', 'anna.kowalska@bank.pl', '501234101', '1988-03-15'),
(1, 'Piotr', 'Nowak', 'piotr.nowak@bank.pl', '502345102', '1985-07-22'),
(1, 'Katarzyna', 'Wójcik', 'katarzyna.wojcik@bank.pl', '503456103', '1991-11-08'),
(1, 'Micha³', 'Kamiñski', 'michal.kaminski@bank.pl', '504567104', '1987-01-19'),
(1, 'Joanna', 'Lewandowska', 'joanna.lewandowska@bank.pl', '505678105', '1993-06-27'),
(2, 'Micha³', 'Wójcik', 'michal.wojcik@banking.pl', '504567104', '1989-01-19'),
(2, 'Joanna', 'Kamiñska', 'joanna.kaminska@banking.pl', '505678105', '1993-05-27'),
(2, 'Alicja', 'Cieœlak', 'alicja.cieslak@banking.pl', '550123104', '1994-01-09'),
(2, 'Rados³aw', 'Borkowski', 'radoslaw.borkowski@banking.pl', '550123105', '1988-11-21'),
(2, 'Dominika', 'Sadowska', 'dominika.sadowska@banking.pl', '550123106', '1995-05-14'),
(2, 'Tomasz', 'Zieliñski', 'tomasz.zielinski@bank.pl', '506789106', '1982-09-11'),
(2, 'Magdalena', 'Szymañska', 'magdalena.szymanska@bank.pl', '507890107', '1990-04-05'),
(2, 'Pawe³', 'WoŸniak', 'pawel.wozniak@bank.pl', '508901108', '1986-12-14'),
(2, 'Natalia', 'D¹browska', 'natalia.dabrowska@bank.pl', '509012109', '1994-02-23'),
(2, 'Marcin', 'Koz³owski', 'marcin.kozlowski@bank.pl', '510123110', '1989-08-30'),
(3, 'Aleksandra', 'Jankowska', 'aleksandra.jankowska@bank.pl', '511234111', '1992-05-17'),
(3, 'Robert', 'Mazur', 'robert.mazur@bank.pl', '512345112', '1984-10-03'),
(3, 'Monika', 'Krawczyk', 'monika.krawczyk@bank.pl', '513456113', '1991-01-26'),
(3, '£ukasz', 'Piotrowski', 'lukasz.piotrowski@bank.pl', '514567114', '1988-07-09'),
(3, 'Karolina', 'Grabowska', 'karolina.grabowska@bank.pl', '515678115', '1995-03-12'),
(3, 'Jakub', 'Zaj¹c', 'jakub.zajac@banking.pl', '550123107', '1990-03-27'),
(3, 'Agnieszka', 'Soko³owska', 'agnieszka.sokolowska@banking.pl', '550123108', '1987-08-16'),
(3, 'Przemys³aw', 'Kubiak', 'przemyslaw.kubiak@banking.pl', '550123109', '1982-12-05'),
(3, 'Monika', 'Wysocka', 'monika.wysocka@banking.pl', '550123110', '1993-07-19'),
(3, 'Tomasz', 'Lewandowski', 'tomasz.lewandowski@banking.pl', '506789106', '1982-09-11'),
(3, 'Magdalena', 'Zieliñska', 'magdalena.zielinska@banking.pl', '507890107', '1990-02-14'),
(3, 'Pawe³', 'Szymañski', 'pawel.szymanski@banking.pl', '508901108', '1987-12-03'),
(3, 'Agnieszka', 'WoŸniak', 'agnieszka.wozniak@banking.pl', '509012109', '1995-06-18'),
(4, 'Marcin', 'D¹browski', 'marcin.dabrowski@banking.pl', '510123110', '1984-04-25'),
(4, 'Monika', 'Koz³owska', 'monika.kozlowska@banking.pl', '511234111', '1992-08-09'),
(4, 'Micha³', 'W³odarczyk', 'michal.wlodarczyk@banking.pl', '550123111', '1985-02-11'),
(4, 'Patrycja', 'B³aszczyk', 'patrycja.blaszczyk@banking.pl', '550123112', '1991-10-28'),
(4, 'Kamil', 'Kaczmarek', 'kamil.kaczmarek@banking.pl', '550123113', '1989-04-06'),
(4, 'Adam', 'Paw³owski', 'adam.pawlowski@bank.pl', '516789116', '1983-11-21'),
(4, 'Ewa', 'Michalska', 'ewa.michalska@bank.pl', '517890117', '1987-05-04'),
(4, 'Krzysztof', 'Król', 'krzysztof.krol@bank.pl', '518901118', '1981-02-16'),
(4, 'Weronika', 'Wieczorek', 'weronika.wieczorek@bank.pl', '519012119', '1996-09-28'),
(4, 'Mateusz', 'Jab³oñski', 'mateusz.jablonski@bank.pl', '520123120', '1990-12-07'),
(5, 'Agnieszka', 'Lis', 'agnieszka.lis@bank.pl', '521234121', '1989-04-18'),
(5, 'Damian', 'Zaj¹c', 'damian.zajac@bank.pl', '522345122', '1993-10-25'),
(5, 'Sylwia', 'Sikora', 'sylwia.sikora@bank.pl', '523456123', '1986-06-13'),
(5, 'Bartosz', 'Baran', 'bartosz.baran@bank.pl', '524567124', '1991-08-06'),
(5, 'Paulina', 'Rutkowska', 'paulina.rutkowska@bank.pl', '525678125', '1995-01-31'), 
(5, 'Grzegorz', 'Kaczor', 'grzegorz.kaczor@banking.pl', '550123114', '1981-09-13'),
(5, 'Joanna', 'Czerwiñska', 'joanna.czerwinska@banking.pl', '550123115', '1990-06-22'),
(5, 'Mateusz', 'Bielecki', 'mateusz.bielecki@banking.pl', '550123116', '1994-12-17'),
(5, 'Karolina', 'Kurek', 'karolina.kurek@banking.pl', '550123117', '1988-01-30'),
(5, 'Robert', 'Jankowski', 'robert.jankowski@banking.pl', '512345112', '1981-10-17'),
(5, 'Natalia', 'Mazur', 'natalia.mazur@banking.pl', '513456113', '1994-03-06'),
(5, '£ukasz', 'Krawczyk', 'lukasz.krawczyk@banking.pl', '514567114', '1988-07-30'),
(5, 'Karolina', 'Piotrowska', 'karolina.piotrowska@banking.pl', '515678115', '1991-01-12'),
(6, 'Adam', 'Grabowski', 'adam.grabowski@banking.pl', '516789116', '1986-05-21'),
(6, 'Ewa', 'Paw³owska', 'ewa.pawlowska@banking.pl', '517890117', '1990-11-04'),
(6, 'Krzysztof', 'Michalski', 'krzysztof.michalski@banking.pl', '518901118', '1983-02-26'),
(6, 'Krzysztof', 'Michalski', 'krzysztof.michalski@banking.pl', '518901118', '1983-02-26'),
(6, 'Rafa³', 'Dudek', 'rafal.dudek@banking.pl', '550123118', '1984-05-08'),
(6, 'Ewelina', 'Mucha', 'ewelina.mucha@banking.pl', '550123119', '1992-11-15'),
(6, 'Tomasz', 'Pietrzak', 'tomasz.pietrzak@banking.pl', '550123120', '1987-03-24'),
(6, 'Grzegorz', 'Michalak', 'grzegorz.michalak@bank.pl', '526789126', '1980-03-22'),
(6, 'Justyna', 'Wrona', 'justyna.wrona@bank.pl', '527890127', '1988-11-15'),
(6, 'Daniel', 'Walczak', 'daniel.walczak@bank.pl', '528901128', '1992-07-03'),
(6, 'Marta', 'B³aszczyk', 'marta.blaszczyk@bank.pl', '529012129', '1994-05-29'),
(6, 'Szymon', 'Górski', 'szymon.gorski@bank.pl', '530123130', '1987-09-17'),
(7, 'Beata', 'Szulc', 'beata.szulc@bank.pl', '531234131', '1985-01-12'),
(7, 'Rafa³', 'Dudek', 'rafal.dudek@bank.pl', '532345132', '1990-06-24'),
(7, 'Iwona', 'Adamczyk', 'iwona.adamczyk@bank.pl', '533456133', '1983-10-08'),
(7, 'Jakub', 'Kaczmarek', 'jakub.kaczmarek@bank.pl', '534567134', '1996-02-19'),
(7, 'Julia', 'Sadowska', 'julia.sadowska@bank.pl', '535678135', '1997-11-02'),    
(7, 'Marek', 'Kaczmarczyk', 'marek.kaczmarczyk@banking.pl', '550123121', '1983-08-31'),
(7, 'Klaudia', 'Wrona', 'klaudia.wrona@banking.pl', '550123122', '1996-02-18'),
(7, 'Sebastian', 'Szczurek', 'sebastian.szczurek@banking.pl', '550123123', '1989-07-05'),
(7, 'Daniel', 'Król', 'daniel.krol@banking.pl', '519012119', '1987-09-13'),
(7, 'Aleksandra', 'Wieczorek', 'aleksandra.wieczorek@banking.pl', '520123120', '1993-12-22'),
(8, 'Mateusz', 'Jab³oñski', 'mateusz.jablonski@banking.pl', '521234121', '1989-06-05'),
(8, 'Julia', 'Wróbel', 'julia.wrobel@banking.pl', '522345122', '1996-04-18'),
(8, 'Rafa³', 'Majewski', 'rafal.majewski@banking.pl', '523456123', '1985-10-29'),
(8, '£ukasz', 'Czajkowski', 'lukasz.czajkowski@banking.pl', '550123124', '1985-12-12'),
(8, 'Magdalena', 'Kowal', 'magdalena.kowal@banking.pl', '550123125', '1993-04-27'),
(8, 'Karol', 'Sikorski', 'karol.sikorski@banking.pl', '550123126', '1990-10-09'),
(8, 'Sebastian', 'Wasilewski', 'sebastian.wasilewski@bank.pl', '536789136', '1984-04-27'),
(8, 'Martyna', 'Kubiak', 'martyna.kubiak@bank.pl', '537890137', '1993-08-14'),
(8, 'Kamil', 'Czarnecki', 'kamil.czarnecki@bank.pl', '538901138', '1989-12-05'),
(8, 'Patrycja', 'Ko³odziej', 'patrycja.kolodziej@bank.pl', '539012139', '1991-03-18'),
(8, 'Patrycja', 'Ko³odziej', 'patrycja.kolodziej@bank.pl', '539012139', '1991-03-18'),
(8, 'Wojciech', 'Urbañski', 'wojciech.urbanski@bank.pl', '540123140', '1982-07-26'),
(9, 'Renata', 'Borkowska', 'renata.borkowska@bank.pl', '541234141', '1986-09-09'),
(9, 'Marek', 'Cieœlak', 'marek.cieslak@bank.pl', '542345142', '1981-05-16'),
(9, 'Zuzanna', 'Kaczmarczyk', 'zuzanna.kaczmarczyk@bank.pl', '543456143', '1995-10-21'),
(9, 'Adrian', 'Malinowski', 'adrian.malinowski@bank.pl', '544567144', '1992-01-07'),
(9, 'Dominika', 'Sawicka', 'dominika.sawicka@bank.pl', '545678145', '1997-06-30'),
(9, 'Robert', 'Domañski', 'robert.domanski@banking.pl', '550123127', '1982-06-14'),
(9, 'Weronika', 'Kubiñska', 'weronika.kubinska@banking.pl', '550123128', '1995-01-23'),
(9, 'Pawe³', 'Mróz', 'pawel.mroz@banking.pl', '550123129', '1986-09-17'),
(9, 'Sylwia', 'Olszewska', 'sylwia.olszewska@banking.pl', '524567124', '1992-07-15'),
(9, 'Grzegorz', 'Stêpieñ', 'grzegorz.stepien@banking.pl', '525678125', '1980-03-27'),
(10, 'Marek', 'Jaworski', 'marek.jaworski@banking.pl', '526789126', '1984-12-11'),
(10, 'Weronika', 'Malinowska', 'weronika.malinowska@banking.pl', '527890127', '1995-08-23'),
(10, 'Szymon', 'Górski', 'szymon.gorski@banking.pl', '528901128', '1988-01-07'),
(10, 'Jacek', 'Matusiak', 'jacek.matusiak@bank.pl', '546789146', '1983-08-11'),
(10, 'Izabela', 'Ostrowska', 'izabela.ostrowska@bank.pl', '547890147', '1989-02-28'),
(10, 'Filip', 'Kaczor', 'filip.kaczor@bank.pl', '548901148', '1994-11-19'),
(10, 'Nina', 'Witkowska', 'nina.witkowska@bank.pl', '549012149', '1996-04-03'),
(10, 'Oskar', 'Kubiñski', 'oskar.kubinski@bank.pl', '550123150', '1990-09-25'),
(10, 'Piotr', 'Gajewski', 'piotr.gajewski@banking.pl', '550123130', '1984-03-02'),
(10, 'Iwona', 'Kania', 'iwona.kania@banking.pl', '550123131', '1991-08-20'),
(10, 'Damian', 'Szczepañski', 'damian.szczepanski@banking.pl', '550123132', '1988-11-06'),
(10, 'Natalia', 'Kruk', 'natalia.kruk@banking.pl', '550123133', '1994-05-29'),
(11, 'Marcin', 'Cieœla', 'marcin.ciesla@banking.pl', '550123134', '1983-01-14'),
(11, 'Anna', 'Kowalewska', 'anna.kowalewska@banking.pl', '550123135', '1990-07-08'),
(11, 'Micha³', 'Borowski', 'michal.borowski@banking.pl', '550123136', '1987-10-25'),
(11, 'Iwona', 'Pawlak', 'iwona.pawlak@banking.pl', '529012129', '1986-06-19'),
(11, 'Bartosz', 'Witkowski', 'bartosz.witkowski@banking.pl', '530123130', '1991-10-02'),
(12, 'Damian', 'Rutkowski', 'damian.rutkowski@banking.pl', '531234131', '1987-04-14'),
(12, 'Marta', 'Michalak', 'marta.michalak@banking.pl', '532345132', '1993-09-28'),
(12, 'Patryk', 'Baran', 'patryk.baran@banking.pl', '533456133', '1989-02-10'),
(12, 'Patryk', 'Baran', 'patryk.baran@banking.pl', '533456133', '1989-02-10'),
(12, 'S³awomir', 'B¹k', 'slawomir.bak@banking.pl', '550123137', '1981-04-19'),
(12, 'Monika', 'Kaczmarek', 'monika.kaczmarek@banking.pl', '550123138', '1993-12-01'),
(12, 'Krzysztof', 'Zieliñski', 'krzysztof.zielinski@banking.pl', '550123139', '1985-06-27'),
(13, 'Marta', 'G³owacka', 'marta.glowacka@banking.pl', '550123140', '1992-02-13'),
(13, 'Wojciech', 'Kaczorowski', 'wojciech.kaczorowski@banking.pl', '550123141', '1986-09-30'),
(13, 'Justyna', 'Marcinkowska', 'justyna.marcinkowska@banking.pl', '550123142', '1995-03-16'),
(13, 'Justyna', 'Sikora', 'justyna.sikora@banking.pl', '534567134', '1990-05-16'),
(13, 'Maciej', 'Walczak', 'maciej.walczak@banking.pl', '535678135', '1983-11-21'),
(14, 'Beata', 'Kubiak', 'beata.kubiak@banking.pl', '536789136', '1985-07-08'),
(14, 'Wojciech', 'Czarnecki', 'wojciech.czarnecki@banking.pl', '537890137', '1981-01-25'),
(14, 'Paulina', 'B¹k', 'paulina.bak@banking.pl', '538901138', '1994-06-12'),
(14, 'Andrzej', 'Weso³owski', 'andrzej.wesolowski@banking.pl', '550123143', '1980-11-22'),
(14, 'Paulina', 'Sawicka', 'paulina.sawicka@banking.pl', '550123144', '1991-05-07'),
(14, 'Damian', 'Or³owski', 'damian.orlowski@banking.pl', '550123145', '1988-08-14'),
(15, 'Katarzyna', 'Urban', 'katarzyna.urban@banking.pl', '550123146', '1993-01-28'),
(15, 'Mariusz', 'Lisowski', 'mariusz.lisowski@banking.pl', '550123147', '1984-06-11'),
(15, 'Ewa', 'KaŸmierczak', 'ewa.kazmierczak@banking.pl', '550123148', '1990-10-03'),
(15, 'Sebastian', 'Sobczak', 'sebastian.sobczak@banking.pl', '539012139', '1988-03-31'),
(15, 'Karina', 'Kaczmarek', 'karina.kaczmarek@banking.pl', '540123140', '1992-10-17'),
(16, 'Dawid', 'Urbañski', 'dawid.urbanski@banking.pl', '541234141', '1986-08-04'),
(16, 'Pawe³', 'Wierzbicki', 'pawel.wierzbicki@banking.pl', '550123149', '1987-02-25'),
(16, 'Julia', 'Borkowska', 'julia.borkowska@banking.pl', '550123150', '1996-07-12'),
(16, 'Dariusz', 'Czarnecki', 'dariusz.czarnecki@banking.pl', '550123151', '1982-12-19'),
(16, 'Dariusz', 'Czarnecki', 'dariusz.czarnecki@banking.pl', '550123151', '1982-12-19'),
(17, 'Micha³', 'Szczepanik', 'michal.szczepanik@banking.pl', '550123152', '1989-04-15'),
(17, 'Oliwia', 'Kaczmarek', 'oliwia.kaczmarek@banking.pl', '550123153', '1997-09-06'),
(17, 'Ryszard', 'Pawlik', 'ryszard.pawlik@banking.pl', '550123154', '1979-01-31'),
(17, 'Oskar', 'Lis', 'oskar.lis@banking.pl', '542345142', '1991-12-09'),
(17, 'Emilia', 'Mazurek', 'emilia.mazurek@banking.pl', '543456143', '1995-02-24'),
(18, 'Jan', 'Kalinowski', 'jan.kalinowski@banking.pl', '544567144', '1982-05-13'),
(18, 'Zofia', 'Adamczyk', 'zofia.adamczyk@banking.pl', '545678145', '1990-09-07'),
(18, 'Aleksandra', 'Czajka', 'aleksandra.czajka@banking.pl', '550123155', '1992-06-24'),
(18, 'Janusz', 'Michalak', 'janusz.michalak@banking.pl', '550123156', '1983-10-17'),
(18, 'Beata', 'Górska', 'beata.gorska@banking.pl', '550123157', '1988-03-09'),
(19, 'Kamil', 'Bednarek', 'kamil.bednarek@banking.pl', '550123158', '1991-12-05'),
(19, 'Kamil', 'Bednarek', 'kamil.bednarek@banking.pl', '550123158', '1991-12-05'),
(19, 'Zuzanna', 'Kowalczyk', 'zuzanna.kowalczyk@banking.pl', '550123159', '1995-08-21'),
(19, 'Marek', 'Sikora', 'marek.sikora@banking.pl', '550123160', '1985-05-13'),
(19, 'Kamil', 'Zawadzki', 'kamil.zawadzki@banking.pl', '546789146', '1987-01-29'),
(19, 'Anna', 'Marciniak', 'anna.marciniak@banking.pl', '547890147', '1993-07-16'),
(20, 'Tomasz', 'Szczepañski', 'tomasz.szczepanski@banking.pl', '548901148', '1984-11-05'),
(20, 'Martyna', 'B³aszczyk', 'martyna.blaszczyk@banking.pl', '549012149', '1996-03-22'),
(20, 'Pawe³', 'Kubiak', 'pawel.kubiak2@banking.pl', '550123161', '1987-11-29'),
(20, 'Natalia', 'Witkowska', 'natalia.witkowska@banking.pl', '550123162', '1993-04-08'),
(20, 'Natalia', 'Witkowska', 'natalia.witkowska@banking.pl', '550123162', '1993-04-08'),
(20, 'Tomasz', 'Jasiñski', 'tomasz.jasinski@banking.pl', '550123163', '1981-09-16');

