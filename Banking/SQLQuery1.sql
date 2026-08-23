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
(1, 'Pawe³', 'Kowalczyk', 'pawel.kowalczyk@gmail.com', '550123101', '1986-04-12'),
(1, 'Natalia', 'Krupa', 'natalia.krupa@gmail.com', '550123102', '1992-09-25'),
(1, 'Pawe³', 'Kowalczyk', 'pawel.kowalczyk@gmail.com', '550123101', '1986-04-12'),
(1, 'Mariusz', 'Szulc', 'mariusz.szulc@gmail.com', '550123103', '1983-06-18'),
(1, 'Anna', 'Kowalska', 'anna.kowalska@gmail.com', '501234101', '1988-03-15'),
(1, 'Piotr', 'Nowak', 'piotr.nowak@gmail.com', '502345102', '1985-07-22'),
(1, 'Katarzyna', 'Wiœniewska', 'katarzyna.wisniewska@gmail.com', '503456103', '1991-11-08'),
(1, 'Anna', 'Kowalska', 'anna.kowalska@bank.pl', '501234101', '1988-03-15'),
(1, 'Piotr', 'Nowak', 'piotr.nowak@bank.pl', '502345102', '1985-07-22'),
(1, 'Katarzyna', 'Wójcik', 'katarzyna.wojcik@bank.pl', '503456103', '1991-11-08'),
(1, 'Micha³', 'Kamiñski', 'michal.kaminski@bank.pl', '504567104', '1987-01-19'),
(1, 'Joanna', 'Lewandowska', 'joanna.lewandowska@bank.pl', '505678105', '1993-06-27'),
(2, 'Micha³', 'Wójcik', 'michal.wojcik@gmail.com', '504567104', '1989-01-19'),
(2, 'Joanna', 'Kamiñska', 'joanna.kaminska@gmail.com', '505678105', '1993-05-27'),
(2, 'Alicja', 'Cieœlak', 'alicja.cieslak@gmail.com', '550123104', '1994-01-09'),
(2, 'Rados³aw', 'Borkowski', 'radoslaw.borkowski@gmail.com', '550123105', '1988-11-21'),
(2, 'Dominika', 'Sadowska', 'dominika.sadowska@gmail.com', '550123106', '1995-05-14'),
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
(3, 'Jakub', 'Zaj¹c', 'jakub.zajac@gmail.com', '550123107', '1990-03-27'),
(3, 'Agnieszka', 'Soko³owska', 'agnieszka.sokolowska@gmail.com', '550123108', '1987-08-16'),
(3, 'Przemys³aw', 'Kubiak', 'przemyslaw.kubiak@gmail.com', '550123109', '1982-12-05'),
(3, 'Monika', 'Wysocka', 'monika.wysocka@gmail.com', '550123110', '1993-07-19'),
(3, 'Tomasz', 'Lewandowski', 'tomasz.lewandowski@gmail.com', '506789106', '1982-09-11'),
(3, 'Magdalena', 'Zieliñska', 'magdalena.zielinska@gmail.com', '507890107', '1990-02-14'),
(3, 'Pawe³', 'Szymañski', 'pawel.szymanski@gmail.com', '508901108', '1987-12-03'),
(3, 'Agnieszka', 'WoŸniak', 'agnieszka.wozniak@gmail.com', '509012109', '1995-06-18'),
(4, 'Marcin', 'D¹browski', 'marcin.dabrowski@gmail.com', '510123110', '1984-04-25'),
(4, 'Monika', 'Koz³owska', 'monika.kozlowska@gmail.com', '511234111', '1992-08-09'),
(4, 'Micha³', 'W³odarczyk', 'michal.wlodarczyk@gmail.com', '550123111', '1985-02-11'),
(4, 'Patrycja', 'B³aszczyk', 'patrycja.blaszczyk@gmail.com', '550123112', '1991-10-28'),
(4, 'Kamil', 'Kaczmarek', 'kamil.kaczmarek@gmail.com', '550123113', '1989-04-06'),
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
(5, 'Grzegorz', 'Kaczor', 'grzegorz.kaczor@gmail.com', '550123114', '1981-09-13'),
(5, 'Joanna', 'Czerwiñska', 'joanna.czerwinska@gmail.com', '550123115', '1990-06-22'),
(5, 'Mateusz', 'Bielecki', 'mateusz.bielecki@gmail.com', '550123116', '1994-12-17'),
(5, 'Karolina', 'Kurek', 'karolina.kurek@gmail.com', '550123117', '1988-01-30'),
(5, 'Robert', 'Jankowski', 'robert.jankowski@gmail.com', '512345112', '1981-10-17'),
(5, 'Natalia', 'Mazur', 'natalia.mazur@gmail.com', '513456113', '1994-03-06'),
(5, '£ukasz', 'Krawczyk', 'lukasz.krawczyk@gmail.com', '514567114', '1988-07-30'),
(5, 'Karolina', 'Piotrowska', 'karolina.piotrowska@gmail.com', '515678115', '1991-01-12'),
(6, 'Adam', 'Grabowski', 'adam.grabowski@gmail.com', '516789116', '1986-05-21'),
(6, 'Ewa', 'Paw³owska', 'ewa.pawlowska@gmail.com', '517890117', '1990-11-04'),
(6, 'Krzysztof', 'Michalski', 'krzysztof.michalski@gmail.com', '518901118', '1983-02-26'),
(6, 'Krzysztof', 'Michalski', 'krzysztof.michalski@gmail.com', '518901118', '1983-02-26'),
(6, 'Rafa³', 'Dudek', 'rafal.dudek@gmail.com', '550123118', '1984-05-08'),
(6, 'Ewelina', 'Mucha', 'ewelina.mucha@gmail.com', '550123119', '1992-11-15'),
(6, 'Tomasz', 'Pietrzak', 'tomasz.pietrzak@gmail.com', '550123120', '1987-03-24'),
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
(7, 'Marek', 'Kaczmarczyk', 'marek.kaczmarczyk@gmail.com', '550123121', '1983-08-31'),
(7, 'Klaudia', 'Wrona', 'klaudia.wrona@wp.pl', '550123122', '1996-02-18'),
(7, 'Sebastian', 'Szczurek', 'sebastian.szczurek@wp.pl', '550123123', '1989-07-05'),
(7, 'Daniel', 'Król', 'daniel.krol@wp.pl', '519012119', '1987-09-13'),
(7, 'Aleksandra', 'Wieczorek', 'aleksandra.wieczorek@wp.pl', '520123120', '1993-12-22'),
(8, 'Mateusz', 'Jab³oñski', 'mateusz.jablonski@wp.pl', '521234121', '1989-06-05'),
(8, 'Julia', 'Wróbel', 'julia.wrobel@wp.pl', '522345122', '1996-04-18'),
(8, 'Rafa³', 'Majewski', 'rafal.majewski@wp.pl', '523456123', '1985-10-29'),
(8, '£ukasz', 'Czajkowski', 'lukasz.czajkowski@wp.pl', '550123124', '1985-12-12'),
(8, 'Magdalena', 'Kowal', 'magdalena.kowal@wp.pl', '550123125', '1993-04-27'),
(8, 'Karol', 'Sikorski', 'karol.sikorski@wp.pl', '550123126', '1990-10-09'),
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
(9, 'Robert', 'Domañski', 'robert.domanski@interia.pl', '550123127', '1982-06-14'),
(9, 'Weronika', 'Kubiñska', 'weronika.kubinska@interia.pl', '550123128', '1995-01-23'),
(9, 'Pawe³', 'Mróz', 'pawel.mroz@interia.pl', '550123129', '1986-09-17'),
(9, 'Sylwia', 'Olszewska', 'sylwia.olszewska@interia.pl', '524567124', '1992-07-15'),
(9, 'Grzegorz', 'Stêpieñ', 'grzegorz.stepien@interia.pl', '525678125', '1980-03-27'),
(10, 'Marek', 'Jaworski', 'marek.jaworski@interia.pl', '526789126', '1984-12-11'),
(10, 'Weronika', 'Malinowska', 'weronika.malinowska@interia.pl', '527890127', '1995-08-23'),
(10, 'Szymon', 'Górski', 'szymon.gorski@interia.pl', '528901128', '1988-01-07'),
(10, 'Jacek', 'Matusiak', 'jacek.matusiak@bank.pl', '546789146', '1983-08-11'),
(10, 'Izabela', 'Ostrowska', 'izabela.ostrowska@bank.pl', '547890147', '1989-02-28'),
(10, 'Filip', 'Kaczor', 'filip.kaczor@bank.pl', '548901148', '1994-11-19'),
(10, 'Nina', 'Witkowska', 'nina.witkowska@bank.pl', '549012149', '1996-04-03'),
(10, 'Oskar', 'Kubiñski', 'oskar.kubinski@bank.pl', '550123150', '1990-09-25'),
(10, 'Piotr', 'Gajewski', 'piotr.gajewski@interia.pl', '550123130', '1984-03-02'),
(10, 'Iwona', 'Kania', 'iwona.kania@interia.pl', '550123131', '1991-08-20'),
(10, 'Damian', 'Szczepañski', 'damian.szczepanski@interia.pl', '550123132', '1988-11-06'),
(10, 'Natalia', 'Kruk', 'natalia.kruk@interia.pl', '550123133', '1994-05-29'),
(11, 'Marcin', 'Cieœla', 'marcin.ciesla@interia.pl', '550123134', '1983-01-14'),
(11, 'Anna', 'Kowalewska', 'anna.kowalewska@interia.pl', '550123135', '1990-07-08'),
(11, 'Micha³', 'Borowski', 'michal.borowski@interia.pl', '550123136', '1987-10-25'),
(11, 'Iwona', 'Pawlak', 'iwona.pawlak@interia.pl', '529012129', '1986-06-19'),
(11, 'Bartosz', 'Witkowski', 'bartosz.witkowski@interia.pl', '530123130', '1991-10-02'),
(12, 'Damian', 'Rutkowski', 'damian.rutkowski@interia.pl', '531234131', '1987-04-14'),
(12, 'Marta', 'Michalak', 'marta.michalak@interia.pl', '532345132', '1993-09-28'),
(12, 'Patryk', 'Baran', 'patryk.baran@interia.pl', '533456133', '1989-02-10'),
(12, 'Patryk', 'Baran', 'patryk.baran@interia.pl', '533456133', '1989-02-10'),
(12, 'S³awomir', 'B¹k', 'slawomir.bak@interia.pl', '550123137', '1981-04-19'),
(12, 'Monika', 'Kaczmarek', 'monika.kaczmarek@interia.pl', '550123138', '1993-12-01'),
(12, 'Krzysztof', 'Zieliñski', 'krzysztof.zielinski@interia.pl', '550123139', '1985-06-27'),
(13, 'Marta', 'G³owacka', 'marta.glowacka@interia.pl', '550123140', '1992-02-13'),
(13, 'Wojciech', 'Kaczorowski', 'wojciech.kaczorowski@interia.pl', '550123141', '1986-09-30'),
(13, 'Justyna', 'Marcinkowska', 'justyna.marcinkowska@interia.pl', '550123142', '1995-03-16'),
(13, 'Justyna', 'Sikora', 'justyna.sikora@interia.pl', '534567134', '1990-05-16'),
(13, 'Maciej', 'Walczak', 'maciej.walczak@interia.pl', '535678135', '1983-11-21'),
(14, 'Beata', 'Kubiak', 'beata.kubiak@interia.pl', '536789136', '1985-07-08'),
(14, 'Wojciech', 'Czarnecki', 'wojciech.czarnecki@interia.pl', '537890137', '1981-01-25'),
(14, 'Paulina', 'B¹k', 'paulina.bak@interia.pl', '538901138', '1994-06-12'),
(14, 'Andrzej', 'Weso³owski', 'andrzej.wesolowski@interia.pl', '550123143', '1980-11-22'),
(14, 'Paulina', 'Sawicka', 'paulina.sawicka@gmail.com', '550123144', '1991-05-07'),
(14, 'Damian', 'Or³owski', 'damian.orlowski@gmail.com', '550123145', '1988-08-14'),
(15, 'Katarzyna', 'Urban', 'katarzyna.urban@gmail.com', '550123146', '1993-01-28'),
(15, 'Mariusz', 'Lisowski', 'mariusz.lisowski@gmail.com', '550123147', '1984-06-11'),
(15, 'Ewa', 'KaŸmierczak', 'ewa.kazmierczak@gmail.com', '550123148', '1990-10-03'),
(15, 'Sebastian', 'Sobczak', 'sebastian.sobczak@gmail.com', '539012139', '1988-03-31'),
(15, 'Karina', 'Kaczmarek', 'karina.kaczmarek@gmail.com', '540123140', '1992-10-17'),
(16, 'Dawid', 'Urbañski', 'dawid.urbanski@gmail.com', '541234141', '1986-08-04'),
(16, 'Pawe³', 'Wierzbicki', 'pawel.wierzbicki@gmail.com', '550123149', '1987-02-25'),
(16, 'Julia', 'Borkowska', 'julia.borkowska@gmail.com', '550123150', '1996-07-12'),
(16, 'Dariusz', 'Czarnecki', 'dariusz.czarnecki@gmail.com', '550123151', '1982-12-19'),
(16, 'Dariusz', 'Czarnecki', 'dariusz.czarnecki@gmail.com', '550123151', '1982-12-19'),
(17, 'Micha³', 'Szczepanik', 'michal.szczepanik@gmail.com', '550123152', '1989-04-15'),
(17, 'Oliwia', 'Kaczmarek', 'oliwia.kaczmarek@gmail.com', '550123153', '1997-09-06'),
(17, 'Ryszard', 'Pawlik', 'ryszard.pawlik@gmail.com', '550123154', '1979-01-31'),
(17, 'Oskar', 'Lis', 'oskar.lis@gmail.com', '542345142', '1991-12-09'),
(17, 'Emilia', 'Mazurek', 'emilia.mazurek@gmail.com', '543456143', '1995-02-24'),
(18, 'Jan', 'Kalinowski', 'jan.kalinowski@outlook.com', '544567144', '1982-05-13'),
(18, 'Zofia', 'Adamczyk', 'zofia.adamczyk@outlook.com', '545678145', '1990-09-07'),
(18, 'Aleksandra', 'Czajka', 'aleksandra.czajka@outlook.com', '550123155', '1992-06-24'),
(18, 'Janusz', 'Michalak', 'janusz.michalak@outlook.com', '550123156', '1983-10-17'),
(18, 'Beata', 'Górska', 'beata.gorska@outlook.com', '550123157', '1988-03-09'),
(19, 'Kamil', 'Bednarek', 'kamil.bednarek@outlook.com', '550123158', '1991-12-05'),
(19, 'Kamil', 'Bednarek', 'kamil.bednarek@outlook.com', '550123158', '1991-12-05'),
(19, 'Zuzanna', 'Kowalczyk', 'zuzanna.kowalczyk@outlook.com', '550123159', '1995-08-21'),
(19, 'Marek', 'Sikora', 'marek.sikora@outlook.com', '550123160', '1985-05-13'),
(19, 'Kamil', 'Zawadzki', 'kamil.zawadzki@outlook.com', '546789146', '1987-01-29'),
(19, 'Anna', 'Marciniak', 'anna.marciniak@outlook.com', '547890147', '1993-07-16'),
(20, 'Tomasz', 'Szczepañski', 'tomasz.szczepanski@outlook.com', '548901148', '1984-11-05'),
(20, 'Martyna', 'B³aszczyk', 'martyna.blaszczyk@outlook.com', '549012149', '1996-03-22'),
(20, 'Pawe³', 'Kubiak', 'pawel.kubiak2@outlook.com', '550123161', '1987-11-29'),
(20, 'Natalia', 'Witkowska', 'natalia.witkowska@outlook.com', '550123162', '1993-04-08'),
(20, 'Natalia', 'Witkowska', 'natalia.witkowska@outlook.com', '550123162', '1993-04-08'),
(20, 'Tomasz', 'Jasiñski', 'tomasz.jasinski@outlook.com', '550123163', '1981-09-16');

INSERT INTO Customer(FirstName, LastName, Email, PhoneNumber, BirthDate)
VALUES
('Anna', 'Kowalska', 'anna.kowalska001@outlook.com', '501234001', '1990-04-12'),
('Anna', 'Kowalska', 'anna.kowalska001@outlook.com', '501234001', '1990-04-12'),
('Piotr', 'Nowak', 'piotr.nowak002@outlook.com', '501234002', '1987-09-23'),
('Katarzyna', 'Wiœniewska', 'katarzyna.wisniewska003@outlook.com', '501234003', '1992-01-15'),
('Marek', 'Wójcik', 'marek.wojcik004@outlook.com', '501234004', '1985-11-08'),
('Tomasz', 'Kowalczyk', 'tomasz.kowalczyk005@outlook.com', '501234005', '1988-06-21'),
('Magdalena', 'Kamiñska', 'magdalena.kaminska006@outlook.com', '501234006', '1993-03-17'),
('Pawe³', 'Lewandowski', 'pawel.lewandowski007@interia.pl', '501234007', '1986-12-04'),
('Joanna', 'Zieliñska', 'joanna.zielinska008@outlook.com', '501234008', '1991-07-29'),
('Micha³', 'Szymañski', 'michal.szymanski009@interia.pl', '501234009', '1979-02-18'),
('Agnieszka', 'D¹browska', 'agnieszka.dabrowska010@interia.pl', '501234010', '1989-10-03'),
('Piotr', 'Nowak', 'piotr.nowak002@interia.pl', '501234002', '1987-09-23'),
('Katarzyna', 'Wiœniewska', 'katarzyna.wisniewska003@outlook.com', '501234003', '1972-01-15'),
('Marek', 'Wójcik', 'marek.wojcik004@interia.pl', '501234004', '1985-11-08'),
('Tomasz', 'Kowalczyk', 'tomasz.kowalczyk005@outlook.com', '501234005', '1988-06-21'),
('Magdalena', 'Kamiñska', 'magdalena.kaminska006@interia.pl', '501234006', '1993-03-17'),
('Pawe³', 'Lewandowski', 'pawel.lewandowski007@outlook.com', '501234007', '1986-12-04'),
('Joanna', 'Zieliñska', 'joanna.zielinska008@outlook.com', '501234008', '1991-07-29'),
('Micha³', 'Szymañski', 'michal.szymanski009@outlook.com', '501234009', '1979-02-18'),
('Agnieszka', 'D¹browska', 'agnieszka.dabrowska010@outlook.com', '501234010', '1989-10-03'),
('Krzysztof', 'WoŸniak', 'krzysztof.wozniak011@outlook.com', '501234011', '1982-05-14'),
('Monika', 'Koz³owska', 'monika.kozlowska012@outlook.com', '501234012', '1994-08-25'),
('Marcin', 'Jankowski', 'marcin.jankowski013@outlook.com', '501234013', '1984-03-11'),
('Natalia', 'Mazur', 'natalia.mazur014@outlook.com', '501234014', '1996-06-19'),
('Jakub', 'Kwiatkowski', 'jakub.kwiatkowski015@outlook.com', '501234015', '1993-12-27'),
('Aleksandra', 'Krawczyk', 'aleksandra.krawczyk016@outlook.com', '501234016', '1991-04-06'),
('Mateusz', 'Piotrowski', 'mateusz.piotrowski017@interia.pl', '501234017', '1988-09-14'),
('Karolina', 'Grabowska', 'karolina.grabowska018@outlook.com', '501234018', '1995-02-22'),
('£ukasz', 'Paw³owski', 'lukasz.pawlowski019@outlook.com', '501234019', '1983-07-05'),
('Zuzanna', 'Michalska', 'zuzanna.michalska020@interia.pl', '501234020', '1997-11-16'),
('Szymon', 'Król', 'szymon.krol021@outlook.com', '501234021', '1990-01-28'),
('Wiktoria', 'Wieczorek', 'wiktoria.wieczorek022@outlook.com', '501234022', '1978-05-09'),
('Adam', 'Jab³oñski', 'adam.jablonski023@interia.pl', '501234023', '1981-10-20'),
('Julia', 'Wróbel', 'julia.wrobel024@outlook.com', '501234024', '1996-03-02'),
('Dawid', 'Majewski', 'dawid.majewski025@outlook.com', '501234025', '1989-08-13'),
('Weronika', 'Olszewska', 'weronika.olszewska026@outlook.com', '501234026', '1994-12-01'),
('Kamil', 'Jaworski', 'kamil.jaworski027@interia.pl', '501234027', '1987-06-24'),
('Marta', 'Malinowska', 'marta.malinowska028@interia.pl', '501234028', '1992-09-07'),
('Bartosz', 'Adamczyk', 'bartosz.adamczyk029@outlook.com', '501234029', '1985-01-19'),
('Patrycja', 'Dudek', 'patrycja.dudek030@interia.pl', '501234030', '1993-05-31'),
('Maciej', 'Górski', 'maciej.gorski031@outlook.com', '501234031', '1980-11-12'),
('Oliwia', 'Pawlik', 'oliwia.pawlik032@interia.pl', '501234032', '1999-02-17'),
('Rafa³', 'Witkowski', 'rafal.witkowski033@outlook.com', '501234033', '1986-07-26'),
('Paulina', 'Walczak', 'paulina.walczak034@outlook.com', '501234034', '1995-10-08'),
('Damian', 'Stêpieñ', 'damian.stepien035@outlook.com', '501234035', '1988-04-29'),
('Ewa', 'Rutkowska', 'ewa.rutkowska036@gmail.com', '501234036', '1982-12-15'),
('Sebastian', 'Baran', 'sebastian.baran037@gmail.com', '501234037', '1991-06-03'),
('Grzegorz', 'Michalak', 'grzegorz.michalak038@gmail.com', '501234038', '1978-09-18'),
('Kinga', 'Szewczyk', 'kinga.szewczyk039@gmail.com', '501234039', '1997-01-24'),
('Karol', 'Sikora', 'karol.sikora040@gmail.com', '501234040', '1984-05-11'),
('Natalia', 'Kaczmarek', 'natalia.kaczmarek041@gmail.com', '501234041', '1993-08-22'),
('Micha³', 'Szulc', 'michal.szulc042@gmail.com', '501234042', '1989-02-05'),
('Martyna', 'Marciniak', 'martyna.marciniak043@gmail.com', '501234043', '1996-11-19'),
('Robert', 'B³aszczyk', 'robert.blaszczyk044@gmail.com', '501234044', '1983-03-27'),
('Sylwia', 'Zawadzka', 'sylwia.zawadzka045@gmail.com', '501234045', '1990-07-14'),
('Daniel', 'Ostrowski', 'daniel.ostrowski046@gmail.com', '501234046', '1987-10-30'),
('Beata', 'Sadowska', 'beata.sadowska047@gmail.com', '501234047', '1981-04-16'),
('Konrad', 'Czarnecki', 'konrad.czarnecki048@gmail.com', '501234048', '1974-09-21'),
('Iwona', 'Kubiak', 'iwona.kubiak049@gmail.com', '501234049', '1979-12-09'),
('Przemys³aw', 'Lis', 'przemyslaw.lis050@gmail.com', '501234050', '1986-06-18'),
('Anna', 'Kaczmarek', 'anna.kaczmarek051@gmail.com', '501234051', '1952-02-11'),
('Piotr', 'Sikora', 'piotr.sikora052@gmail.com', '501234052', '1985-08-04'),
('Katarzyna', 'Szulc', 'katarzyna.szulc053@gmail.com', '501234053', '1995-01-23'),
('Marek', 'Marciniak', 'marek.marciniak054@gmail.com', '501234054', '1988-10-17'),
('Tomasz', 'B³aszczyk', 'tomasz.blaszczyk055@gmail.com', '501234055', '1983-05-28'),
('Magdalena', 'Zawadzka', 'magdalena.zawadzka056@gmail.com', '501234056', '1997-09-12'),
('Pawe³', 'Ostrowski', 'pawel.ostrowski057@gmail.com', '501234057', '1990-03-06'),
('Joanna', 'Sadowska', 'joanna.sadowska058@gmail.com', '501234058', '1987-11-25'),
('Krzysztof', 'Czarnecki', 'krzysztof.czarnecki059@wp.pl', '501234059', '1982-07-19'),
('Monika', 'Kubiak', 'monika.kubiak060@wp.pl', '501234060', '1994-04-03'),
('Marcin', 'Lis', 'marcin.lis061@onet.pl', '501234061', '1989-12-28'),
('Natalia', 'Kaczmarek', 'natalia.kaczmarek062@wp.pl', '501234062', '1996-06-15'),
('Jakub', 'Sikora', 'jakub.sikora063@gmail.com', '501234063', '1984-02-09'),
('Aleksandra', 'Szulc', 'aleksandra.szulc064@onet.pl', '501234064', '1991-08-31'),
('Mateusz', 'Marciniak', 'mateusz.marciniak065@wp.pl', '501234065', '1986-01-14'),
('Karolina', 'B³aszczyk', 'karolina.blaszczyk066@onet.pl', '501234066', '1993-10-22'),
('£ukasz', 'Zawadzki', 'lukasz.zawadzki067@onet.pl', '501234067', '1980-05-07'),
('Zuzanna', 'Ostrowska', 'zuzanna.ostrowska068@onet.pl', '501234068', '1968-12-16'),
('Szymon', 'Sadowski', 'szymon.sadowski069@gmail.com', '501234069', '1987-03-29'),
('Wiktoria', 'Czarnecka', 'wiktoria.czarnecka070@onet.pl', '501234070', '1995-07-11'),
('Adam', 'Kubiak', 'adam.kubiak071@wp.pl', '501234071', '1983-09-24'),
('Julia', 'Lis', 'julia.lis072@gmail.com', '501234072', '1999-04-18'),
('Dawid', 'Kaczmarek', 'dawid.kaczmarek073@wp.pl', '501234073', '1990-11-02'),
('Weronika', 'Sikora', 'weronika.sikora074@gmail.com', '501234074', '1996-06-27'),
('Kamil', 'Szulc', 'kamil.szulc075@gmail.com', '501234075', '1988-01-08'),
('Marta', 'Marciniak', 'marta.marciniak076@onet.pl', '501234076', '1992-09-19'),
('Bartosz', 'B³aszczyk', 'bartosz.blaszczyk077@wp.pl', '501234077', '1985-12-04'),
('Patrycja', 'Zawadzka', 'patrycja.zawadzka078@wp.pl', '501234078', '1994-03-15'),
('Maciej', 'Ostrowski', 'maciej.ostrowski079@onet.pl', '501234079', '1981-08-26'),
('Oliwia', 'Sadowska', 'oliwia.sadowska080@wp.pl', '501234080', '1997-05-12'),
('Rafa³', 'Czarnecki', 'rafal.czarnecki081@wp.pl', '501234081', '1989-10-29'),
('Paulina', 'Kubiak', 'paulina.kubiak082@wp.pl', '501234082', '1993-02-21'),
('Damian', 'Lis', 'damian.lis083@gmail.com', '501234083', '1986-07-03'),
('Ewa', 'Kaczmarek', 'ewa.kaczmarek084@onet.pl', '501234084', '1991-11-17'),
('Sebastian', 'Sikora', 'sebastian.sikora085@wp.pl', '501234085', '1984-04-09'),
('Grzegorz', 'Szulc', 'grzegorz.szulc086@onet.pl', '501234086', '1979-09-28'),
('Kinga', 'Marciniak', 'kinga.marciniak087@wp.pl', '501234087', '1998-01-06'),
('Karol', 'B³aszczyk', 'karol.blaszczyk088@onet.pl', '501234088', '1987-06-14'),
('Sylwia', 'Zawadzka', 'sylwia.zawadzka089@wp.pl', '501234089', '1992-12-23'),
('Robert', 'Ostrowski', 'robert.ostrowski090@onet.pl', '501234090', '1983-05-16'),
('Daniel', 'Sadowski', 'daniel.sadowski091@wp.pl', '501234091', '1995-08-07'),
('Beata', 'Czarnecka', 'beata.czarnecka092@wp.pl', '501234092', '1988-03-19'),
('Konrad', 'Kubiak', 'konrad.kubiak093@wp.pl', '501234093', '1994-10-25'),
('Iwona', 'Lis', 'iwona.lis094@wp.pl', '501234094', '1980-07-31'),
('Przemys³aw', 'Kaczmarek', 'przemyslaw.kaczmarek095@wp.pl', '501234095', '1985-01-12'),
('Anna', 'Sikora', 'anna.sikora096@wp.pl', '501234096', '1990-09-05'),
('Piotr', 'Szulc', 'piotr.szulc097@wp.pl', '501234097', '1982-11-18'),
('Katarzyna', 'Marciniak', 'katarzyna.marciniak098@wp.pl', '501234098', '1996-04-27'),
('Marek', 'B³aszczyk', 'marek.blaszczyk099@wp.pl', '501234099', '1989-06-08'),
('Tomasz', 'Zawadzki', 'tomasz.zawadzki100@wp.pl', '501234100', '1987-12-15'),
('Tomasz', 'Zawadzki', 'tomasz.zawadzki100@wp.pl', '501234100', '1987-12-15'),
('Ewa', 'Kaczmarek', 'ewa.kaczmarek084@wp.pl', '791234084', '1991-11-17'),
('Kinga', 'Sokó³', 'kinga.sokol@wp.pl', '501242087', '1998-01-06'),
('Karol', 'Zawada', 'karol.zawada088@wp.pl', '501234338', '1987-08-12'),
('Sylwia', 'Zawidzka', 'sylwia.zawidzka089@wp.pl', '501334089', '1992-11-13'),
('Szymon', 'Ostrowski', 'szymon.ostrowski090@wp.pl', '793234090', '1983-01-16'),
('Damian', 'Sadowski', 'damian.sadowski091@wp.pl', '501284898', '1995-08-27'),
('Barbara', 'Czarnecka', 'barbara.czarnecka092@wp.pl', '701288092', '1988-03-29'),
('Konrad', 'Kluska', 'konrad.kluska093@wp.pl', '501234000', '1994-10-25'),
('Iwona', 'Lisowska', 'iwona.lisowska094@wp.pl', '501239004', '1980-07-31'),
('Przemys³aw', 'Król', 'przemyslaw.krol095@wp.pl', '701834095', '1985-01-12'),
('Anita', 'Sikora', 'anita.sikora096@wp.pl', '501214296', '1960-09-05'),
('Piotr', 'Szuc', 'piotr.szuc097@wp.pl', '501234011', '1982-11-18'),
('Micha³', 'Wójcik', 'michal.wojcik004@gmail.com', '504567004', '1985-06-08'),
('Magdalena', 'Kamiñska', 'magdalena.kaminska005@outlook.com', '505678005', '1965-11-29'),
('Tomasz', 'Lewandowski', 'tomasz.lewandowski006@gmail.com', '506789006', '1989-03-14'),
('Joanna', 'Zieliñska', 'joanna.zielinska007@outlook.com', '507890007', '1991-07-21'),
('Pawe³', 'Szymañski', 'pawel.szymanski008@gmail.com', '508901008', '1983-12-05'),
('Monika', 'WoŸniak', 'monika.wozniak009@outlook.com', '509012009', '1994-02-26'),
('Marcin', 'D¹browski', 'marcin.dabrowski010@gmail.com', '510123010', '1986-08-19'),
('Agnieszka', 'Koz³owska', 'agnieszka.kozlowska011@outlook.com', '511234011', '1993-05-03'),
('Krzysztof', 'Jankowski', 'krzysztof.jankowski012@gmail.com', '512345012', '1981-10-15'),
('Natalia', 'Mazur', 'natalia.mazur013@outlook.com', '513456013', '1997-04-28'),
('£ukasz', 'Kwiatkowski', 'lukasz.kwiatkowski014@gmail.com', '514567014', '1988-01-09'),
('Karolina', 'Krawczyk', 'karolina.krawczyk015@outlook.com', '515678015', '1946-09-17'),
('Robert', 'Piotrowski', 'robert.piotrowski016@gmail.com', '516789016', '1984-06-24'),
('Aleksandra', 'Grabowska', 'aleksandra.grabowska017@outlook.com', '517890017', '1991-12-11'),
('Damian', 'Paw³owski', 'damian.pawlowski018@gmail.com', '518901018', '1990-03-30'),
('Ewa', 'Michalska', 'ewa.michalska019@outlook.com', '519012019', '1987-07-06'),
('Jakub', 'Król', 'jakub.krol020@gmail.com', '520123020', '1995-11-18'),
('Weronika', 'Wieczorek', 'weronika.wieczorek021@outlook.com', '521234021', '1998-02-13'),
('Mateusz', 'Jab³oñski', 'mateusz.jablonski022@gmail.com', '522345022', '1989-05-27'),
('Sylwia', 'Wróbel', 'sylwia.wrobel023@outlook.com', '523456023', '1992-10-04'),
('Adrian', 'Nowicki', 'adrian.nowicki024@gmail.com', '524567024', '1986-01-22'),
('Paulina', 'Majewska', 'paulina.majewska025@outlook.com', '525678025', '1994-08-16'),
('Szymon', 'Olszewski', 'szymon.olszewski026@gmail.com', '526789026', '1982-04-07'),
('Marta', 'Stêpieñ', 'marta.stepien027@outlook.com', '527890027', '1993-12-19'),
('Rafa³', 'Jaworski', 'rafal.jaworski028@gmail.com', '528901028', '1985-07-31'),
('Beata', 'Malinowska', 'beata.malinowska029@outlook.com', '529012029', '1990-02-08'),
('Dawid', 'Adamczyk', 'dawid.adamczyk030@gmail.com', '530123030', '1987-06-12'),
('Iwona', 'Dudek', 'iwona.dudek031@outlook.com', '531234031', '1988-09-25'),
('Bartosz', 'Walczak', 'bartosz.walczak032@gmail.com', '532345032', '1981-03-16'),
('Justyna', 'Baran', 'justyna.baran033@outlook.com', '533456033', '1995-10-29'),
('Patryk', 'Sikora', 'patryk.sikora034@gmail.com', '534567034', '1989-12-03'),
('Kinga', 'Rutkowska', 'kinga.rutkowska035@outlook.com', '535678035', '1996-05-21'),
('Wojciech', 'Górski', 'wojciech.gorski036@gmail.com', '536789036', '1983-08-14'),
('Emilia', 'Pawlik', 'emilia.pawlik037@outlook.com', '537890037', '1992-01-30'),
('Maciej', 'Michalak', 'maciej.michalak038@gmail.com', '538901038', '1987-06-18'),
('Zuzanna', 'Szulc', 'zuzanna.szulc039@outlook.com', '539012039', '1968-11-07'),
('Kamil', 'Lis', 'kamil.lis040@gmail.com', '540123040', '1994-03-25'),
('Julia', 'Czarnecka', 'julia.czarnecka041@outlook.com', '541234041', '1969-07-13'),
('Sebastian', 'Sadowski', 'sebastian.sadowski042@gmail.com', '542345042', '1985-10-22'),
('Dominika', 'B³aszczyk', 'dominika.blaszczyk043@outlook.com', '543456043', '1993-04-09'),
('Konrad', 'Marciniak', 'konrad.marciniak044@gmail.com', '544567044', '1990-12-28'),
('Oliwia', 'Witkowska', 'oliwia.witkowska045@outlook.com', '545678045', '1997-02-15'),
('Przemys³aw', 'Wasilewski', 'przemyslaw.wasilewski046@gmail.com', '546789046', '1982-09-04'),
('Wiktoria', 'Zawadzka', 'wiktoria.zawadzka047@outlook.com', '547890047', '1996-06-27'),
('Daniel', 'Borkowski', 'daniel.borkowski048@gmail.com', '548901048', '1988-03-11'),
('Patrycja', 'Kaczmarek', 'patrycja.kaczmarek049@outlook.com', '549012049', '1995-08-23'),
('Grzegorz', 'Kubiak', 'grzegorz.kubiak050@gmail.com', '550123050', '1984-01-19'),
('Alicja', 'Soko³owska', 'alicja.sokolowska051@outlook.com', '551234051', '1991-05-12'),
('Damian', 'Urbañski', 'damian.urbanski052@gmail.com', '552345052', '1989-11-26'),
('Izabela', 'Cieœlak', 'izabela.cieslak053@outlook.com', '553456053', '1994-07-08'),
('Marek', 'Zakrzewski', 'marek.zakrzewski054@gmail.com', '554567054', '1981-02-17'),
('Nina', 'Szczepañska', 'nina.szczepanska055@outlook.com', '555678055', '1998-09-30'),
('Artur', 'Domañski', 'artur.domanski056@gmail.com', '556789056', '1986-12-14'),
('Gabriela', 'Ostrowska', 'gabriela.ostrowska057@outlook.com', '557890057', '1973-03-06'),
('Filip', 'Wróblewski', 'filip.wroblewski058@gmail.com', '558901058', '1977-10-21'),
('Klaudia', 'Kubiñska', 'klaudia.kubinska059@outlook.com', '559012059', '1992-06-15'),
('Norbert', 'Kaczmarek', 'norbert.kaczmarek060@gmail.com', '560123060', '1987-04-02'),
('Renata', 'Sikorska', 'renata.sikorska061@outlook.com', '561234061', '1985-11-09'),
('Marcel', 'Czerwiñski', 'marcel.czerwinski062@gmail.com', '562345062', '1999-01-27'),
('Lena', 'Kalinowska', 'lena.kalinowska063@outlook.com', '563456063', '2000-05-18'),
('Hubert', 'W³odarczyk', 'hubert.wlodarczyk064@gmail.com', '564567064', '1991-09-12'),
('Milena', 'Szczepañska', 'milena.szczepanska065@outlook.com', '565678065', '1996-02-24'),
('Mariusz', 'Bielecki', 'mariusz.bielecki066@gmail.com', '566789066', '1983-07-19'),
('Laura', 'Kurek', 'laura.kurek067@outlook.com', '567890067', '1998-12-05'),
('B³a¿ej', 'Czajkowski', 'blazej.czajkowski068@gmail.com', '568901068', '1989-06-28'),
('Sandra', 'Mazurek', 'sandra.mazurek069@outlook.com', '569012069', '1974-10-13'),
('Rados³aw', 'Ko³odziej', 'radoslaw.kolodziej070@gmail.com', '570123070', '1982-03-22'),
('Celina', 'Szulc', 'celina.szulc071@outlook.com', '571234071', '1990-08-07'),
('Tymon', 'Kozio³', 'tymon.koziol072@gmail.com', '572345072', '1997-01-15'),
('Amelia', 'B¹k', 'amelia.bak073@outlook.com', '573456073', '2000-09-24'),
('Oskar', 'Miko³ajczyk', 'oskar.mikolajczyk074@gmail.com', '574567074', '1955-04-16'),
('Blanka', 'Konieczna', 'blanka.konieczna075@outlook.com', '575678075', '1999-11-03'),
('Kacper', 'Tomczak', 'kacper.tomczak076@gmail.com', '576789076', '1993-07-29'),
('Martyna', 'Kubiak', 'martyna.kubiak077@outlook.com', '577890077', '1996-05-11'),
('Alan', 'B³aszczyk', 'alan.blaszczyk078@gmail.com', '578901078', '1998-02-20'),
('Natasza', 'Gajewska', 'natasza.gajewska079@outlook.com', '579012079', '1992-10-06'),
('Igor', 'Pietrzak', 'igor.pietrzak080@gmail.com', '580123080', '1988-12-17'),
('Roksana', 'Musia³', 'roksana.musial081@outlook.com', '581234081', '1995-03-09'),
('Borys', 'Wilk', 'borys.wilk082@gmail.com', '582345082', '1990-06-26'),
('Lidia', 'Bednarek', 'lidia.bednarek083@outlook.com', '583456083', '1987-09-18'),
('Miko³aj', 'Czajka', 'mikolaj.czajka084@gmail.com', '584567084', '1999-04-30'),
('Eliza', 'Szczurek', 'eliza.szczurek085@outlook.com', '585678085', '1993-11-12'),
('Jan', 'Wrona', 'jan.wrona086@gmail.com', '586789086', '1984-05-07'),
('Oliwier', 'Pi¹tek', 'oliwier.piatek087@outlook.com', '587890087', '1967-08-21'),
('Aurelia', 'B³aszak', 'aurelia.blaszak088@gmail.com', '588901088', '1961-01-16'),
('Wiktor', 'Kaczor', 'wiktor.kaczor089@outlook.com', '589012089', '1986-10-28'),
('Karol', 'Mucha', 'karol.mucha090@gmail.com', '590123090', '1994-06-03'),
('Daria', 'G³owacka', 'daria.glowacka091@outlook.com', '591234091', '1998-03-17'),
('Ryszard', 'Brzeziñski', 'ryszard.brzezinski092@gmail.com', '592345092', '1980-07-24'),
('Elena', 'Markowska', 'elena.markowska093@outlook.com', '593456093', '1992-12-08'),
('Cezary', 'Sawicki', 'cezary.sawicki094@gmail.com', '594567094', '1985-02-19'),
('Lena', 'Kowalczyk', 'lena.kowalczyk095@outlook.com', '595678095', '1999-09-14'),
('Bartosz', 'Zaj¹c', 'bartosz.zajac096@gmail.com', '596789096', '1990-04-27'),
('Aneta', 'Matusiak', 'aneta.matusiak097@outlook.com', '597890097', '1988-11-06'),
('Seweryn', 'Kaczorowski', 'seweryn.kaczorowski098@gmail.com', '598901098', '1995-05-23'),
('Kornelia', 'Szczepañska', 'kornelia.szczepanska099@outlook.com', '599012099', '1997-08-09'),
('Tomasz', 'Gajda', 'tomasz.gajda100@gmail.com', '600123100', '1983-12-21'),
('Lena', 'Urbañska', 'lena.urbanska141@interia.pl', '641234141', '1988-05-12'),
('Mariusz', 'Sawicki', 'mariusz.sawicki142@wp.pl', '642345142', '1983-11-20'),
('Gabriela', 'Malinowska', 'gabriela.malinowska143@interia.pl', '643456143', '1991-03-15'),
('Konrad', 'Ko³odziej', 'konrad.kolodziej144@wp.pl', '644567144', '1987-06-27'),
('Amelia', 'Witkowska', 'amelia.witkowska145@interia.pl', '645678145', '2000-09-03'),
('Oskar', 'Brzeziñski', 'oskar.brzezinski146@wp.pl', '646789146', '1996-01-29'),
('Izabela', 'Domañska', 'izabela.domanska147@interia.pl', '647890147', '1989-04-11'),
('Maciej', 'G³owacki', 'maciej.glowacki148@wp.pl', '648901148', '1985-10-24'),
('Sandra', 'Mazurek', 'sandra.mazurek149@interia.pl', '649012149', '1993-07-06'),
('Maja', 'Zieliñska', 'maja.zielinska131@interia.pl', '631234131', '2000-03-08'),
('Rafa³', 'Walczak', 'rafal.walczak132@wp.pl', '632345132', '1985-07-22'),
('Oliwia', 'Koz³owska', 'oliwia.kozlowska133@interia.pl', '633456133', '1999-10-17'),
('Grzegorz', 'Szulc', 'grzegorz.szulc134@wp.pl', '634567134', '1981-01-25'),
('Patrycja', 'Nowicka', 'patrycja.nowicka135@interia.pl', '635678135', '1944-06-10'),
('Wojciech', 'Jaworski', 'wojciech.jaworski136@wp.pl', '636789136', '1988-12-01'),
('Alicja', 'Pawlik', 'alicja.pawlik137@interia.pl', '637890137', '1997-04-23'),
('Sebastian', 'Wasilewski', 'sebastian.wasilewski138@wp.pl', '638901138', '1984-09-14'),
('Martyna', 'Krawczyk', 'martyna.krawczyk121@interia.pl', '621234121', '1994-03-26'),
('Adrian', 'Sadowski', 'adrian.sadowski122@wp.pl', '622345122', '1989-10-09'),
('Julia', 'Pietrzak', 'julia.pietrzak123@interia.pl', '623456123', '1997-01-18'),
('Krzysztof', 'Wilk', 'krzysztof.wilk124@wp.pl', '624567124', '1982-05-07'),
('Emilia', 'Jankowska', 'emilia.jankowska125@interia.pl', '625678125', '1995-12-16'),
('Marcin', 'Wrona', 'marcin.wrona126@wp.pl', '626789126', '1986-04-28'),
('Daria', 'Matusiak', 'daria.matusiak127@interia.pl', '627890127', '1998-09-05'),
('Filip', 'Borkowski', 'filip.borkowski128@wp.pl', '628901128', '1998-06-19'),
('Wiktoria', 'Kaczmarek', 'wiktoria.kaczmarek129@interia.pl', '629012129', '1986-02-27'),
('Daniel', 'Cieœlak', 'daniel.cieslak130@wp.pl', '630123130', '1990-11-13'),
('Nina', 'Kurek', 'nina.kurek139@interia.pl', '639012139', '1992-02-06'),
('Paulina', 'Wieczorek', 'paulina.wieczorek111@interia.pl', '611234111', '1995-10-07'),
('Robert', 'Kubiak', 'robert.kubiak112@wp.pl', '612345112', '1983-03-21'),
('Zuzanna', 'Baran', 'zuzanna.baran113@interia.pl', '613456113', '1998-07-15'),
('Damian', 'Michalski', 'damian.michalski114@wp.pl', '614567114', '1990-12-29'),
('Aleksandra', 'Górska', 'aleksandra.gorska115@interia.pl', '615678115', '1983-06-04'),
('Bartosz', 'Lis', 'bartosz.lis116@wp.pl', '616789116', '1987-09-18'),
('Weronika', 'D¹browska', 'weronika.dabrowska117@interia.pl', '617890117', '1976-11-23'),
('Pawe³', 'Mazur', 'pawel.mazur118@wp.pl', '618901118', '1984-02-14'),
('Klaudia', 'Grabowska', 'klaudia.grabowska119@interia.pl', '619012119', '1969-05-30'),
('Szymon', 'Olszewski', 'szymon.olszewski120@wp.pl', '620123120', '1996-08-11'),
('Natalia', 'Kaczmarek', 'natalia.kaczmarek101@interia.pl', '601234101', '1993-05-14'),
('Micha³', 'Dudek', 'michal.dudek102@wp.pl', '602345102', '1988-11-22'),
('Karolina', 'Wójcik', 'karolina.wojcik103@interia.pl', '603456103', '1966-02-08'),
('Tomasz', 'Paw³owski', 'tomasz.pawlowski104@wp.pl', '604567104', '1985-07-19'),
('Agnieszka', 'Król', 'agnieszka.krol105@interia.pl', '605678105', '1961-09-27'),
('Mateusz', 'Gajewski', 'mateusz.gajewski106@wp.pl', '606789106', '1974-12-03'),
('Joanna', 'Czarnecka', 'joanna.czarnecka107@interia.pl', '607890107', '1989-04-16'),
('Kamil', 'Kowalczyk', 'kamil.kowalczyk108@wp.pl', '608901108', '1997-08-25'),
('Monika', 'Sikora', 'monika.sikora109@interia.pl', '609012109', '1992-01-31'),
('£ukasz', 'Zaj¹c', 'lukasz.zajac110@wp.pl', '610123110', '1986-06-12'),
('Hubert', 'Czajkowski', 'hubert.czajkowski140@wp.pl', '640123140', '1995-08-29'),
('Norbert', 'Sikorski', 'norbert.sikorski150@wp.pl', '650123150', '1990-12-18');

INSERT INTO Account
(
    CustomerId,
    AccountNumber,
    AccountTypeId,
    CurrencyCode,
    CurrentBalance,
    AvailableBalance
)
SELECT TOP (700)

    CustomerId,

    '101' +
    RIGHT(
        '00000000000000000000000' +
        CAST(ROW_NUMBER() OVER (ORDER BY CustomerId) AS VARCHAR(23)),
        23
    ) AS AccountNumber,

    CASE
	WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 13 = 0 THEN 6
	WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 22 = 0 THEN 8
    WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 20 = 0 THEN 4
	WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 18 = 0 THEN 10
    WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 10 = 0 THEN 3
    WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 5 = 0 THEN 2
    ELSE 1
	END AS AccountTypeId,

    CASE
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 25 = 0 THEN 'USD'
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 20 = 0 THEN 'GBP'
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 15 = 0 THEN 'EUR'
        WHEN ROW_NUMBER() OVER (ORDER BY CustomerId) % 30 = 0 THEN 'CHF'
        ELSE 'PLN'
    END AS CurrencyCode,

    b.Bal AS CurrentBalance,

    b.Bal AS AvailableBalance

FROM dbo.Customer

CROSS APPLY
(
    SELECT CAST(
        (ABS(CHECKSUM(NEWID())) % 1000000) / 100.0
        AS DECIMAL(18,2)
    ) AS Bal
) b

ORDER BY CustomerId;

INSERT INTO AccountOverdraft
(
    AccountId,
    OverdraftLimit,
    InterestRate,
    UsedAmount,
    ActiveFrom,
    ActiveTo
)
SELECT TOP (100)
    a.AccountId,
    r.OverdraftLimit,
    r.InterestRate,
    CAST(
        ROUND(r.OverdraftLimit * r.UsedPct, 2)
        AS DECIMAL(18,2)
    ) AS UsedAmount,
    d.ActiveFrom,
    d.ActiveTo

FROM Account a

/* sprawdzamy, czy konto nie ma ju¿ overdraftu
left join AccountId Unique - only one overdraft to one account*/
LEFT JOIN AccountOverdraft ao ON ao.AccountId = a.AccountId

-- losujemy limit, oprocentowanie i procent wykorzystania
CROSS APPLY
(
    SELECT
        CAST(
            (ABS(CHECKSUM(NEWID())) % 1900000 + 100000) / 100.0 
			/*CHECKSUM(NEWID()) change random value to number, 
			ABS without a minus sign - absolute value,
			range from 100 000 to 1 999 999*/
            AS DECIMAL(18,2) /*a maximum of 18 digits, including 2 after the decimal point */
        ) AS OverdraftLimit,

        CAST(
            (ABS(CHECKSUM(NEWID())) % 1001 + 800) / 100.0 /*(800 – 1800)/100 -- 8.00 – 18.00 */
            AS DECIMAL(5,2)
        ) AS InterestRate,

        CAST(
            ABS(CHECKSUM(NEWID())) % 81 /*Maximum - 80% */
            AS DECIMAL(5,2)
        ) / 100.0 AS UsedPct
) r

-- losujemy datê rozpoczêcia i ewentualnego zakoñczenia
CROSS APPLY
(
    SELECT
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 1500), /* date from the last of 1500 days */
            CAST(GETDATE() AS DATE) /*data only without time */
        ) AS ActiveFrom
) startDate

CROSS APPLY
(
    SELECT
        startDate.ActiveFrom AS ActiveFrom,

        CASE
            -- oko³o 15% overdraftów zakoñczonych
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 15
            THEN DATEADD(
                DAY,
                ABS(CHECKSUM(NEWID()))
                % (
                    DATEDIFF(
                        DAY,
                        startDate.ActiveFrom,
                        CAST(GETDATE() AS DATE)
                    ) + 1
                ),
                startDate.ActiveFrom
            )
            ELSE NULL
        END AS ActiveTo
) d

WHERE ao.AccountId IS NULL

ORDER BY NEWID();

INSERT INTO dbo.AccountTransaction
(
    TransactionReference,
    TransactionTypeId,
    TransactionStatusId,
    TransactionDirection,
    MerchantId,
    AccountId,
    Amount,
    TransactionDate,
    TransactionCurrencyCode,
    Title,
    BalanceAfterTransaction
)
SELECT TOP (10000)

    -- numer transakcji
    'TRX' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', '') AS TransactionReference,

    -- typ transakcji
    t.TransactionTypeId,

    -- status
    s.TransactionStatusId,

    -- kierunek
    d.TransactionDirection,

    -- merchant
    CASE
        WHEN t.TransactionTypeId IN (1, 6, 11)
            THEN m.MerchantId
        ELSE NULL
    END AS MerchantId,

    -- konto
    a.AccountId,

    -- kwota
    x.Amount,

    -- data
    DATEADD(
        DAY,
        -(ABS(CHECKSUM(NEWID())) % 730),
        SYSDATETIMEOFFSET()
    ) AS TransactionDate,

    -- waluta konta
    a.CurrencyCode AS TransactionCurrencyCode,

    -- tytu³
    COALESCE(
        CASE
            WHEN t.TransactionTypeId IN (1, 6, 11)
                THEN m.Name
        END,
        tt.Name,
        'Transaction'
    ) + ' - ' +
    CONVERT(
        VARCHAR(19),
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 730),
            SYSDATETIMEOFFSET()
        ),
        120
    ) AS Title,

    -- saldo po transakcji
    CASE
        WHEN d.TransactionDirection = 'D'
            THEN CAST(a.CurrentBalance - x.Amount AS DECIMAL(18,2))
        ELSE
            CAST(a.CurrentBalance + x.Amount AS DECIMAL(18,2))
    END AS BalanceAfterTransaction

FROM dbo.Account a

CROSS APPLY
(
    SELECT
        ABS(CHECKSUM(NEWID())) % 100 AS RandomType
) rt

CROSS APPLY
(
    SELECT
        CASE
            WHEN rt.RandomType < 40 THEN 1
            WHEN rt.RandomType < 55 THEN 2
            WHEN rt.RandomType < 63 THEN 3
            WHEN rt.RandomType < 66 THEN 4
            WHEN rt.RandomType < 71 THEN 5
            WHEN rt.RandomType < 78 THEN 6
            WHEN rt.RandomType < 82 THEN 7
            WHEN rt.RandomType < 87 THEN 8
            WHEN rt.RandomType < 90 THEN 9
            WHEN rt.RandomType < 95 THEN 10
            ELSE 11
        END AS TransactionTypeId
) t

CROSS APPLY
(
    SELECT
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 85 THEN 3
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 92 THEN 1
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 96 THEN 2
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 98 THEN 4
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 99 THEN 5
            ELSE 6
        END AS TransactionStatusId
) s

CROSS APPLY
(
    SELECT
        CASE
            WHEN t.TransactionTypeId IN (1, 3, 6, 7, 10, 11)
                THEN 'D'

            WHEN t.TransactionTypeId IN (4, 5, 8, 9)
                THEN 'C'

            WHEN t.TransactionTypeId = 2
                THEN
                    CASE
                        WHEN ABS(CHECKSUM(NEWID())) % 2 = 0
                            THEN 'C'
                        ELSE 'D'
                    END
        END AS TransactionDirection
) d

CROSS APPLY
(
    SELECT
        CASE

            WHEN t.TransactionTypeId = 1
                THEN CAST(
                    10 + ABS(CHECKSUM(NEWID())) % 1491
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 2
                THEN CAST(
                    100 + ABS(CHECKSUM(NEWID())) % 9901
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 3
                THEN CAST(
                    50 + ABS(CHECKSUM(NEWID())) % 1951
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 4
                THEN CAST(
                    500 + ABS(CHECKSUM(NEWID())) % 9501
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 5
                THEN CAST(
                    4000 + ABS(CHECKSUM(NEWID())) % 9001
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 6
                THEN CAST(
                    30 + ABS(CHECKSUM(NEWID())) % 971
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 7
                THEN CAST(
                    5 + ABS(CHECKSUM(NEWID())) % 96
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 8
                THEN CAST(
                    20 + ABS(CHECKSUM(NEWID())) % 1481
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 9
                THEN CAST(
                    10 + ABS(CHECKSUM(NEWID())) % 491
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 10
                THEN CAST(
                    500 + ABS(CHECKSUM(NEWID())) % 3001
                    AS DECIMAL(18,2)
                )

            WHEN t.TransactionTypeId = 11
                THEN CAST(
                    100 + ABS(CHECKSUM(NEWID())) % 1901
                    AS DECIMAL(18,2)
                )

        END AS Amount
) x

OUTER APPLY
(
    SELECT TOP (1)
        MerchantId,
        Name
    FROM dbo.Merchant
    ORDER BY NEWID()
) m

LEFT JOIN dbo.TransactionType tt
    ON tt.TransactionTypeId = t.TransactionTypeId

ORDER BY NEWID();
use Banking
INSERT INTO dbo.Loan
(
    CurrencyCode,
    LoanStatusId,
    CustomerId,
    InterestRateTypeId,
    Amount,
    CurrentMonthlyPayment,
    LoanTermMonth,
    Principal,
    OutstandingPrincipal,
    AnnualInterestRate,
    AccruedInterest,
    NextInstallmentDate,
    ActiveFrom,
    ActiveTo
)
SELECT TOP (100)

    -- WALUTA
    cur.CurrencyCode,

    -- STATUS KREDYTU
    ls.LoanStatusId,

    -- KLIENT
    cu.CustomerId,

    -- TYP OPROCENTOWANIA
    ir.InterestRateTypeId,

    -- KWOTA KREDYTU
    v.Amount,

    -- RATA MIESIÊCZNA
    CAST(
        CASE
            WHEN v.MonthlyRate = 0
                THEN v.Principal / v.LoanTermMonth

            ELSE
                v.Principal *
                (
                    v.MonthlyRate *
                    POWER(
                        1 + v.MonthlyRate,
                        v.LoanTermMonth
                    )
                )
                /
                (
                    POWER(
                        1 + v.MonthlyRate,
                        v.LoanTermMonth
                    ) - 1
                )
        END
        AS DECIMAL(18,2)
    ) AS CurrentMonthlyPayment,

    -- OKRES KREDYTU
    v.LoanTermMonth,

    -- KAPITA£
    v.Principal,

    -- POZOSTA£Y KAPITA£
    v.OutstandingPrincipal,

    -- OPROCENTOWANIE ROCZNE
    v.AnnualInterestRate,

    -- NALICZONE ODSETKI
    v.AccruedInterest,

    -- NASTÊPNA RATA
    DATEADD(
        MONTH,
        1,
        v.ActiveFrom
    ) AS NextInstallmentDate,

    -- DATA ROZPOCZÊCIA
    v.ActiveFrom,

    -- DATA ZAKOÑCZENIA
    v.ActiveTo

FROM dbo.Customer cu

-- losowa waluta dla ka¿dego kredytu
CROSS APPLY
(
    SELECT TOP (1)
        CurrencyCode
    FROM dbo.Currency
    ORDER BY NEWID()
) cur

-- losowy status dla ka¿dego kredytu
CROSS APPLY
(
    SELECT TOP (1)
        LoanStatusId
    FROM dbo.LoanStatus
    ORDER BY NEWID()
) ls

-- losowy typ oprocentowania dla ka¿dego kredytu
CROSS APPLY
(
    SELECT TOP (1)
        InterestRateTypeId
    FROM dbo.InterestRateType
    ORDER BY NEWID()
) ir

-- generowanie parametrów kredytu
CROSS APPLY
(
    SELECT

        -- kwota 10 000 - 300 000
        CAST(
            10000 +
            ABS(CHECKSUM(NEWID())) % 290001
            AS DECIMAL(18,2)
        ) AS Amount,

        -- okres 12 - 120 miesiêcy
        12 +
        ABS(CHECKSUM(NEWID())) % 109 AS LoanTermMonth,

        -- oprocentowanie 5.00% - 15.00%
        CAST(
            5.00 +
            (ABS(CHECKSUM(NEWID())) % 1001) / 100.0
            AS DECIMAL(5,2)
        ) AS AnnualInterestRate,

        -- data rozpoczêcia z ostatnich 5 lat
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 1825),
            CAST(GETDATE() AS DATE)
        ) AS ActiveFrom

) base

-- wyliczamy kapita³ i oprocentowanie miesiêczne
CROSS APPLY
(
    SELECT

        base.Amount AS Amount,

        base.LoanTermMonth AS LoanTermMonth,

        base.AnnualInterestRate AS AnnualInterestRate,

        CAST(
            base.AnnualInterestRate / 100.0 / 12.0
            AS DECIMAL(18,10)
        ) AS MonthlyRate,

        base.ActiveFrom AS ActiveFrom,

        -- Principal = 90-100% kwoty kredytu
        CAST(
            base.Amount *
            (
                0.90 +
                (ABS(CHECKSUM(NEWID())) % 11) / 100.0
            )
            AS DECIMAL(18,2)
        ) AS Principal

) calc

-- wyliczamy pozosta³y kapita³ i odsetki
CROSS APPLY
(
    SELECT

        calc.Amount,

        calc.LoanTermMonth,

        calc.AnnualInterestRate,

        calc.MonthlyRate,

        calc.ActiveFrom,

        calc.Principal,

        -- pozosta³o 0-100% kapita³u
        CAST(
            calc.Principal *
            (
                ABS(CHECKSUM(NEWID())) % 101
            ) / 100.0
            AS DECIMAL(18,2)
        ) AS OutstandingPrincipal,

        -- naliczone odsetki 0-500 z³
        CAST(
            ABS(CHECKSUM(NEWID())) % 501
            AS DECIMAL(18,2)
        ) AS AccruedInterest,

        -- 70% kredytów nadal aktywnych
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 70
                THEN NULL

            ELSE
                DATEADD(
                    MONTH,
                    calc.LoanTermMonth,
                    calc.ActiveFrom
                )
        END AS ActiveTo

) v

WHERE
    -- gwarantujemy, ¿e kolejna rata mo¿e byæ po ActiveFrom
    v.ActiveFrom <= DATEADD(
        MONTH,
        -1,
        CAST(GETDATE() AS DATE)
    )

ORDER BY NEWID();
use Banking
select * from LoanPaymentStatus

INSERT INTO dbo.LoanSchedule
(
    InstallmentNumber,
    LoanId,
    LoanInstallmentStatusId,
    DueDate,
    PrincipalAmount,
    InterestAmount,
    PaidAmount,
    PaidDate
)
SELECT
    n.InstallmentNumber,

    l.LoanId,

    -- STATUS RATY
    CASE
        -- przysz³a rata
        WHEN d.DueDate > CAST(GETDATE() AS DATE)
            THEN lsScheduled.LoanInstallmentStatusId

        -- rata zap³acona
        WHEN p.IsPaid = 1
            THEN lsPaid.LoanInstallmentStatusId

        -- rata czêœciowo zap³acona
        WHEN p.IsPartiallyPaid = 1
            THEN lsPartial.LoanInstallmentStatusId

        -- rata przeterminowana
        ELSE lsOverdue.LoanInstallmentStatusId
    END AS LoanInstallmentStatusId,

    d.DueDate,

    -- KAPITA£
    calc.PrincipalAmount,

    -- ODSETKI
    calc.InterestAmount,

    -- ZAP£ACONA KWOTA
    CASE
        WHEN p.IsPaid = 1
            THEN calc.TotalAmount

        WHEN p.IsPartiallyPaid = 1
            THEN CAST(
                calc.TotalAmount *
                (
                    30 +
                    ABS(CHECKSUM(NEWID())) % 51
                ) / 100.0
                AS DECIMAL(18,2)
            )

        ELSE 0
    END AS PaidAmount,

    -- DATA ZAP£ATY
    CASE
        WHEN p.IsPaid = 1
            THEN DATEADD(
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 10),
                d.DueDate
            )

        WHEN p.IsPartiallyPaid = 1
            THEN DATEADD(
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 5),
                d.DueDate
            )

        ELSE NULL
    END AS PaidDate

FROM dbo.Loan l

-- generowanie numerów rat 1-120
CROSS APPLY
(
    SELECT TOP (120)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS InstallmentNumber
    FROM sys.all_columns a1
    CROSS JOIN sys.all_columns a2
) n

-- tylko tyle rat, ile ma dany kredyt
CROSS APPLY
(
    SELECT
        DATEADD(
            MONTH,
            n.InstallmentNumber - 1,
            l.ActiveFrom
        ) AS DueDate
) d

-- wyliczenie kapita³u i odsetek
CROSS APPLY
(
    SELECT

        -- kapita³ raty
        CAST(
            CASE
                -- ostatnia rata = wszystko co zosta³o
                WHEN n.InstallmentNumber = l.LoanTermMonth
                    THEN
                        l.Principal
                        -
                        (
                            CAST(
                                l.Principal / l.LoanTermMonth
                                AS DECIMAL(18,2)
                            )
                            * (l.LoanTermMonth - 1)
                        )

                ELSE
                    CAST(
                        l.Principal / l.LoanTermMonth
                        AS DECIMAL(18,2)
                    )
            END
            AS DECIMAL(18,2)
        ) AS PrincipalAmount,

        -- odsetki od pozosta³ego kapita³u
        CAST(
            (
                l.Principal
                -
                (
                    CAST(
                        l.Principal / l.LoanTermMonth
                        AS DECIMAL(18,2)
                    )
                    * (n.InstallmentNumber - 1)
                )
            )
            *
            (
                l.AnnualInterestRate / 100.0 / 12.0
            )
            AS DECIMAL(18,2)
        ) AS InterestAmount
) raw

-- ca³kowita rata
CROSS APPLY
(
    SELECT
        raw.PrincipalAmount,
        raw.InterestAmount,
        CAST(
            raw.PrincipalAmount + raw.InterestAmount
            AS DECIMAL(18,2)
        ) AS TotalAmount
) calc

-- ustalamy czy rata zosta³a zap³acona
CROSS APPLY
(
    SELECT
        CASE
            WHEN d.DueDate < CAST(GETDATE() AS DATE)
                 AND ABS(CHECKSUM(NEWID())) % 100 < 85
                THEN 1
            ELSE 0
        END AS IsPaid,

        CASE
            WHEN d.DueDate < CAST(GETDATE() AS DATE)
                 AND ABS(CHECKSUM(NEWID())) % 100 BETWEEN 85 AND 94
                THEN 1
            ELSE 0
        END AS IsPartiallyPaid
) p

-- STATUS: SCHEDULED
CROSS APPLY
(
    SELECT TOP (1)
        LoanInstallmentStatusId
    FROM dbo.LoanInstallmentStatus
    WHERE Code = 'SCHEDULED'
) lsScheduled

-- STATUS: PAID
CROSS APPLY
(
    SELECT TOP (1)
        LoanInstallmentStatusId
    FROM dbo.LoanInstallmentStatus
    WHERE Code = 'PAID'
) lsPaid

-- STATUS: PARTIALLY_PAID
CROSS APPLY
(
    SELECT TOP (1)
        LoanInstallmentStatusId
    FROM dbo.LoanInstallmentStatus
    WHERE Code = 'PARTIALLY_PAID'
) lsPartial

-- STATUS: OVERDUE
CROSS APPLY
(
    SELECT TOP (1)
        LoanInstallmentStatusId
    FROM dbo.LoanInstallmentStatus
    WHERE Code = 'OVERDUE'
) lsOverdue

WHERE
    n.InstallmentNumber <= l.LoanTermMonth

    -- zabezpieczenie przed ponownym wstawieniem tych samych rat
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.LoanSchedule existing
        WHERE existing.LoanId = l.LoanId
          AND existing.InstallmentNumber = n.InstallmentNumber
    );

INSERT INTO dbo.LoanPayment
(
    LoanScheduleId,
    LoanPaymentStatusId,
    PaymentDate,
    LoanPaymentTypeId,
    Amount,
    PaymentReference
)
SELECT
    ls.LoanScheduleId,

    -- STATUS P£ATNOŒCI
    CASE
        WHEN r.StatusRandom < 85 THEN 3   -- COMPLETED
        WHEN r.StatusRandom < 90 THEN 1   -- PENDING
        WHEN r.StatusRandom < 94 THEN 2   -- PROCESSING
        WHEN r.StatusRandom < 97 THEN 4   -- FAILED
        WHEN r.StatusRandom < 99 THEN 5   -- CANCELLED
        ELSE 6                            -- REVERSED
    END AS LoanPaymentStatusId,

    -- DATA P£ATNOŒCI
    CASE
        WHEN ls.PaidDate IS NOT NULL
            THEN ls.PaidDate
        ELSE
            DATEADD(
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 5),
                ls.DueDate
            )
    END AS PaymentDate,

    -- TYP P£ATNOŒCI
    CASE
        WHEN r.TypeRandom < 65 THEN 6   -- AUTOMATIC_DEBIT
        WHEN r.TypeRandom < 85 THEN 7   -- BANK_TRANSFER
        WHEN r.TypeRandom < 95 THEN 9   -- CARD_PAYMENT
        WHEN r.TypeRandom < 98 THEN 8   -- CASH_PAYMENT
        ELSE 10                          -- REFUND
    END AS LoanPaymentTypeId,

    -- KWOTA
    ls.PaidAmount AS Amount,

    -- REFERENCJA
    'LP-' +
    REPLACE(
        CONVERT(VARCHAR(36), NEWID()),
        '-',
        ''
    ) AS PaymentReference

FROM dbo.LoanSchedule ls

CROSS APPLY
(
    SELECT
        ABS(CHECKSUM(NEWID())) % 100 AS StatusRandom,
        ABS(CHECKSUM(NEWID())) % 100 AS TypeRandom
) r

WHERE
    ls.PaidAmount > 0

    -- tylko raty, które mia³y termin
    AND ls.DueDate <= CAST(GETDATE() AS DATE)

    -- zabezpieczenie przed duplikowaniem p³atnoœci
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.LoanPayment lp
        WHERE lp.LoanScheduleId = ls.LoanScheduleId
    );

INSERT INTO dbo.LoanInterestAccrual
(
    LoanId,
    AccrualDate,
    PrincipalBalance,
    InterestRate,
    InterestAmount
)
SELECT
    l.LoanId,

    d.AccrualDate,

    -- saldo kapita³u
    CAST(
        CASE
            WHEN l.OutstandingPrincipal > 0
                THEN l.OutstandingPrincipal
            ELSE 0
        END
        AS DECIMAL(18,2)
    ) AS PrincipalBalance,

    l.AnnualInterestRate AS InterestRate,

    -- dzienne odsetki
    CAST(
        CASE
            WHEN l.OutstandingPrincipal > 0
                THEN
                    l.OutstandingPrincipal
                    * l.AnnualInterestRate
                    / 100.0
                    / 365.0
            ELSE 0
        END
        AS DECIMAL(18,2)
    ) AS InterestAmount

FROM dbo.Loan l

CROSS APPLY
(
    SELECT TOP (30)
        DATEADD(
            DAY,
            -(n - 1),
            CAST(GETDATE() AS DATE)
        ) AS AccrualDate
    FROM
    (
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM sys.all_columns a1
        CROSS JOIN sys.all_columns a2
    ) x
) d

WHERE
    l.ActiveFrom <= d.AccrualDate

    -- je¿eli kredyt ma ActiveTo,
    -- nie generujemy odsetek po jego zakoñczeniu
    AND
    (
        l.ActiveTo IS NULL
        OR l.ActiveTo >= d.AccrualDate
    )

    -- zabezpieczenie przed duplikatami
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.LoanInterestAccrual lia
        WHERE lia.LoanId = l.LoanId
          AND lia.AccrualDate = d.AccrualDate
    );

INSERT INTO dbo.LoanStatusHistory
(
    LoanId,
    OldStatusId,
    NewStatusId,
    ChangedAt
)

-- =====================================================
-- 1. PENDING ? ACTIVE
-- =====================================================

SELECT
    l.LoanId,
    1 AS OldStatusId,
    2 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 30,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId IN (2,3,4,5,6)

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 2
)


UNION ALL


-- =====================================================
-- 2. ACTIVE ? PAID_OFF
-- =====================================================

SELECT
    l.LoanId,
    2 AS OldStatusId,
    3 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 365,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId = 3

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 3
)


UNION ALL


-- =====================================================
-- 3. ACTIVE ? OVERDUE
-- =====================================================

SELECT
    l.LoanId,
    2 AS OldStatusId,
    4 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 365,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId IN (4,5)

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 4
)


UNION ALL


-- =====================================================
-- 4. OVERDUE ? DEFAULTED
-- =====================================================

SELECT
    l.LoanId,
    4 AS OldStatusId,
    5 AS NewStatusId,

    DATEADD(
        DAY,
        365 + ABS(CHECKSUM(NEWID())) % 365,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId = 5

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 5
)


UNION ALL


-- =====================================================
-- 5. ACTIVE ? SUSPENDED
-- =====================================================

SELECT
    l.LoanId,
    2 AS OldStatusId,
    6 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 365,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId = 6

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 6
)


UNION ALL


-- =====================================================
-- 6. PENDING ? CANCELLED
-- =====================================================

SELECT
    l.LoanId,
    1 AS OldStatusId,
    7 AS NewStatusId,

    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % 30,
        CAST(l.ActiveFrom AS DATETIMEOFFSET)
    ) AS ChangedAt

FROM dbo.Loan l

WHERE l.LoanStatusId = 7

AND NOT EXISTS
(
    SELECT 1
    FROM dbo.LoanStatusHistory h
    WHERE h.LoanId = l.LoanId
      AND h.NewStatusId = 7
);

SELECT
    t.name AS TableName,
    SUM(p.rows) AS RecordsCount
FROM sys.tables AS t
INNER JOIN sys.partitions AS p
    ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;









INSERT INTO dbo.Card
(
    CustomerId,
    AccountId,
    CardHolderName,
    CardNumberHash,
    LastFourDigits,
    IssuedAt,
    CardStatusId,
    ActivatedAt,
    ExpiresAt
)
SELECT
    a.CustomerId,

    a.AccountId,

    CONCAT(
        c.FirstName,
        ' ',
        c.LastName
    ) AS CardHolderName,

    HASHBYTES(
        'SHA2_512',
        '4' +
        RIGHT(
            '000000000000000' +
            CAST(a.AccountId AS VARCHAR(15)),
            15
        )
    ) AS CardNumberHash,

    RIGHT(
        RIGHT(
            '000000000000000' +
            CAST(a.AccountId AS VARCHAR(15)),
            15
        ),
        4
    ) AS LastFourDigits,

    d.IssuedAt,

    s.CardStatusId,

    CASE
        WHEN s.Code IN ('ACTIVE', 'BLOCKED')
            THEN DATEADD(
                DAY,
                ABS(CHECKSUM(NEWID())) % 30,
                CAST(d.IssuedAt AS DATETIME)
            )
        ELSE NULL
    END AS ActivatedAt,

    DATEADD(
        YEAR,
        4,
        d.IssuedAt
    ) AS ExpiresAt

FROM dbo.Account a

INNER JOIN dbo.Customer c
    ON c.CustomerId = a.CustomerId

CROSS APPLY
(
    SELECT
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 1000),
            CAST(GETDATE() AS DATE)
        ) AS IssuedAt
) d

CROSS APPLY
(
    SELECT TOP (1)
        cs.CardStatusId,
        cs.Code
    FROM dbo.CardStatus cs
    ORDER BY NEWID()
) s

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Card card
    WHERE card.AccountId = a.AccountId
);


INSERT INTO dbo.CardSecurity
(
    CardId,
    PinRetryCount,
    BlockedUntil,
    IsBlocked,
    PinChangedAt
)
SELECT
    c.CardId,

    x.PinRetryCount,

    CASE
        WHEN x.IsBlocked = 1
        THEN DATEADD(
            HOUR,
            1 + ABS(CHECKSUM(NEWID())) % 72,
            SYSDATETIMEOFFSET()
        )
        ELSE NULL
    END AS BlockedUntil,

    x.IsBlocked,

    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 90
        THEN DATEADD(
            DAY,
            ABS(CHECKSUM(NEWID())) % 365,
            CAST(c.IssuedAt AS DATETIMEOFFSET)
        )
        ELSE NULL
    END AS PinChangedAt

FROM dbo.Card c

CROSS APPLY
(
    SELECT
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 80 THEN 0
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 95 THEN 1
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 99 THEN 2
            ELSE 3
        END AS PinRetryCount
) p

CROSS APPLY
(
    SELECT
        p.PinRetryCount,
        CASE
            WHEN p.PinRetryCount = 3 THEN 1
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 2 THEN 1
            ELSE 0
        END AS IsBlocked
) x

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.CardSecurity cs
    WHERE cs.CardId = c.CardId
);

INSERT INTO dbo.CardTransactionAuthorization
(
    CardId,
    MerchantId,
    Amount,
    CardTransactionAuthorizationStatusId,
    AuthorizedAt,
    CreatedAt,
    UpdatedAt,
    AuthorizationCode,
    CurrencyCode,
    TransactionId
)
SELECT TOP (500)
    c.CardId,

    m.MerchantId,

    CAST(
        (ABS(CHECKSUM(NEWID())) % 500000) / 100.0 + 5.00
        AS DECIMAL(18,2)
    ) AS Amount,

    s.CardTransactionAuthorizationStatusId,

    d.AuthorizedAt,

    d.AuthorizedAt AS CreatedAt,

    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 70
        THEN DATEADD(
            MINUTE,
            ABS(CHECKSUM(NEWID())) % 1440,
            d.AuthorizedAt
        )
        ELSE NULL
    END AS UpdatedAt,

    RIGHT(
        '000000' +
        CAST(
            ABS(CHECKSUM(NEWID())) % 1000000
            AS VARCHAR(6)
        ),
        6
    ) AS AuthorizationCode,

    cur.CurrencyCode,

    NULL AS TransactionId

FROM dbo.Card c

CROSS APPLY
(
    SELECT TOP (1)
        m1.MerchantId
    FROM dbo.Merchant m1
    ORDER BY NEWID()
) m

CROSS APPLY
(
    SELECT TOP (1)
        s1.CardTransactionAuthorizationStatusId
    FROM dbo.CardTransactionAuthorizationStatus s1
    ORDER BY NEWID()
) s

CROSS APPLY
(
    SELECT TOP (1)
        c1.CurrencyCode
    FROM dbo.Currency c1
    ORDER BY NEWID()
) cur

CROSS APPLY
(
    SELECT
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 365),
            SYSDATETIMEOFFSET()
        ) AS AuthorizedAt
) d

ORDER BY NEWID();

SELECT *
FROM dbo.CardTransactionAuthorizationStatus;


INSERT INTO dbo.CardTransactionAuthorizationStatusHistory
(
    CardTransactionAuthorizationId,
    OldStatusId,
    NewStatusId,
    ChangedAt
)

-- =====================================================
-- 1. PENDING ? APPROVED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    2 AS NewStatusId,
    DATEADD(
        MINUTE,
        1 + ABS(CHECKSUM(NEWID())) % 10,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 2


UNION ALL


-- =====================================================
-- 2. PENDING ? DECLINED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    3 AS NewStatusId,
    DATEADD(
        MINUTE,
        1 + ABS(CHECKSUM(NEWID())) % 10,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 3


UNION ALL


-- =====================================================
-- 3. PENDING ? REVERSED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    2 AS NewStatusId,
    DATEADD(
        MINUTE,
        1 + ABS(CHECKSUM(NEWID())) % 10,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 4

UNION ALL

SELECT
    a.CardTransactionAuthorizationId,
    2 AS OldStatusId,
    4 AS NewStatusId,
    DATEADD(
        MINUTE,
        30 + ABS(CHECKSUM(NEWID())) % 1440,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 4


UNION ALL


-- =====================================================
-- 4. PENDING ? EXPIRED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    5 AS NewStatusId,
    DATEADD(
        HOUR,
        1 + ABS(CHECKSUM(NEWID())) % 48,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 5


UNION ALL


-- =====================================================
-- 5. PENDING ? CANCELLED
-- =====================================================

SELECT
    a.CardTransactionAuthorizationId,
    1 AS OldStatusId,
    6 AS NewStatusId,
    DATEADD(
        MINUTE,
        1 + ABS(CHECKSUM(NEWID())) % 60,
        a.AuthorizedAt
    ) AS ChangedAt
FROM dbo.CardTransactionAuthorization a
WHERE a.CardTransactionAuthorizationStatusId = 6;




;WITH Dates AS
(
    SELECT
        CAST(DATEADD(DAY, -364, GETDATE()) AS DATE) AS RateDate

    UNION ALL

    SELECT
        DATEADD(DAY, 1, RateDate)
    FROM Dates
    WHERE RateDate < CAST(GETDATE() AS DATE)
),
Rates AS
(
    SELECT
        c.CurrencyCode,
        d.RateDate,

        CASE c.CurrencyCode
            WHEN 'EUR' THEN 4.25
            WHEN 'USD' THEN 3.65
            WHEN 'GBP' THEN 4.95
            WHEN 'CHF' THEN 4.55
            WHEN 'CZK' THEN 0.17
            WHEN 'DKK' THEN 0.57
            WHEN 'HUF' THEN 0.011
            WHEN 'JPY' THEN 0.023
            WHEN 'NOK' THEN 0.37
            WHEN 'SEK' THEN 0.38
            WHEN 'CAD' THEN 2.65
            WHEN 'AUD' THEN 2.40
        END AS BaseRate

    FROM dbo.Currency c
    CROSS JOIN Dates d
    WHERE c.CurrencyCode <> 'PLN'
)
INSERT INTO dbo.ExchangeRate
(
    CurrencyCode,
    ExchangeRateDate,
    CurrencyConversionRate,
    Multiplier
)
SELECT
    CurrencyCode,

    DATEADD(
        SECOND,
        0,
        CAST(RateDate AS DATETIMEOFFSET)
    ) AS ExchangeRateDate,

    CAST(
        BaseRate +
        (
            (ABS(CHECKSUM(
                NEWID()
            )) % 2001 - 1000) / 100000.0
        )
        AS DECIMAL(10,4)
    ) AS CurrencyConversionRate,

    1.0000 AS Multiplier

FROM Rates r

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.ExchangeRate er
    WHERE er.CurrencyCode = r.CurrencyCode
      AND er.ExchangeRateDate =
          CAST(r.RateDate AS DATETIMEOFFSET)
)
OPTION (MAXRECURSION 400);

INSERT INTO dbo.LedgerEntry
(
    AccountId,
    TransactionId,
    Debit,
    Credit,
    BalanceAfterEntry,
    PostingDate
)
SELECT
    t.AccountId,
    t.TransactionId,

    -- Debit = pieni¹dze wychodz¹ce z konta
    CASE
        WHEN t.TransactionDirection = 'D'
            THEN t.Amount
        ELSE 0
    END AS Debit,

    -- Credit = pieni¹dze wp³ywaj¹ce na konto
    CASE
        WHEN t.TransactionDirection = 'C'
            THEN t.Amount
        ELSE 0
    END AS Credit,

    t.BalanceAfterTransaction AS BalanceAfterEntry,

    t.TransactionDate AS PostingDate

FROM dbo.AccountTransaction t

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.LedgerEntry l
    WHERE l.TransactionId = t.TransactionId
);

INSERT INTO dbo.OverdraftUsage
(
    OverdraftId,
    OverdraftUsageTypeId,
    TransactionId,
    AmountUsed
)
SELECT TOP (150)
    ao.OverdraftId,

    (
        SELECT TOP (1)
            OverdraftUsageTypeId
        FROM dbo.OverdraftUsageType
        ORDER BY NEWID()
    ) AS OverdraftUsageTypeId,

    at.TransactionId,

    CAST(
        ABS(at.BalanceAfterTransaction)
        AS DECIMAL(18,2)
    ) AS AmountUsed

FROM dbo.AccountOverdraft ao

INNER JOIN dbo.AccountTransaction at
    ON at.AccountId = ao.AccountId

WHERE
    at.TransactionDirection = 'D'
    AND at.BalanceAfterTransaction < 0

    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.OverdraftUsage ou
        WHERE ou.TransactionId = at.TransactionId
    )

ORDER BY NEWID();

INSERT INTO dbo.OverdraftInterest
(
    OverdraftId,
    TransactionStatusId,
    TransactionId,
    InterestDate,
    InterestPeriodFrom,
    InterestPeriodTo,
    Amount,
    Rate
)
SELECT
    ao.OverdraftId,

    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 85 THEN 3
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 95 THEN 1
        ELSE 2
    END AS TransactionStatusId,

    NULL AS TransactionId,

    DATEADD(
        DAY,
        -(ABS(CHECKSUM(NEWID())) % 365),
        SYSDATETIMEOFFSET()
    ) AS InterestDate,

    DATEADD(
        DAY,
        -30,
        CAST(GETDATE() AS DATE)
    ) AS InterestPeriodFrom,

    CAST(GETDATE() AS DATE) AS InterestPeriodTo,

    CAST(
        ROUND(
            ao.UsedAmount
            * (ao.InterestRate / 100.0)
            * (30.0 / 365.0),
            2
        )
        AS DECIMAL(18,2)
    ) AS Amount,

    ao.InterestRate AS Rate

FROM dbo.AccountOverdraft ao
WHERE ao.UsedAmount > 0;

INSERT INTO dbo.StandingOrder
(
    StandingOrderFrequencyId,
    Amount,
    NextExecutionDate,
    LastExecutionDate,
    FromAccountId,
    ToAccountNumber,
    RecipientName,
    Title,
    CurrencyCode,
    IsActive,
    StartDate,
    EndDate
)
SELECT TOP (100)

    -- losowa czêstotliwoœæ
    (
        SELECT TOP (1)
            StandingOrderFrequencyId
        FROM dbo.StandingOrderFrequency
        ORDER BY NEWID()
    ),

    -- kwota 50 - 5000 PLN/EUR itd.
    CAST(
        50 + (ABS(CHECKSUM(NEWID())) % 495001) / 100.0
        AS DECIMAL(18,2)
    ),

    -- nastêpna realizacja 1-60 dni od dzisiaj
    DATEADD(
        DAY,
        1 + ABS(CHECKSUM(NEWID())) % 60,
        CAST(GETDATE() AS DATE)
    ),

    NULL,

    -- konto Ÿród³owe
    a.AccountId,

    -- 26-cyfrowy numer rachunku odbiorcy
    RIGHT(
        '00000000000000000000000000' +
        CAST(
            ABS(CHECKSUM(NEWID())) % 100000000
            AS VARCHAR(26)
        ),
        26
    ),

    -- odbiorca
    CASE ABS(CHECKSUM(NEWID())) % 10
        WHEN 0 THEN 'Zak³ad Energetyczny'
        WHEN 1 THEN 'Orange Polska'
        WHEN 2 THEN 'T-Mobile Polska'
        WHEN 3 THEN 'PGE'
        WHEN 4 THEN 'Wspólnota Mieszkaniowa'
        WHEN 5 THEN 'Play'
        WHEN 6 THEN 'Polsat Box'
        WHEN 7 THEN 'ZUS'
        WHEN 8 THEN 'Urz¹d Skarbowy'
        ELSE 'Przelew w³asny'
    END,

    -- tytu³
    CASE ABS(CHECKSUM(NEWID())) % 8
        WHEN 0 THEN 'Op³ata za energiê elektryczn¹'
        WHEN 1 THEN 'Op³ata za telefon'
        WHEN 2 THEN 'Op³ata za internet'
        WHEN 3 THEN 'Czynsz'
        WHEN 4 THEN 'Op³ata za mieszkanie'
        WHEN 5 THEN 'Rachunek miesiêczny'
        WHEN 6 THEN 'Sta³y przelew'
        ELSE 'Op³ata cykliczna'
    END,

    -- waluta taka jak na koncie
    a.CurrencyCode,

    -- 85% aktywnych
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 85
        THEN 1
        ELSE 0
    END,

    -- StartDate
    s.StartDate,

    -- EndDate zawsze po NextExecutionDate
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 20
        THEN DATEADD(
            DAY,
            180 + ABS(CHECKSUM(NEWID())) % 730,
            DATEADD(
                DAY,
                1 + ABS(CHECKSUM(NEWID())) % 60,
                CAST(GETDATE() AS DATE)
            )
        )
        ELSE NULL
    END

FROM dbo.Account a

CROSS APPLY
(
    SELECT
        DATEADD(
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 365),
            CAST(GETDATE() AS DATE)
        ) AS StartDate
) s

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.StandingOrder so
    WHERE so.FromAccountId = a.AccountId
)

ORDER BY NEWID();


INSERT INTO dbo.StandingOrderExecution
(
    StandingOrderId,
    TransactionId,
    ExecutionDate,
    Amount,
    StandingOrderExecutionStatusId,
    FailureReason
)
SELECT TOP (250)

    so.StandingOrderId,

    -- tylko czêœæ wykonanych zleceñ bêdzie
    -- powi¹zana z transakcj¹
    CASE
        WHEN s.StatusId = 3
             AND ABS(CHECKSUM(NEWID())) % 100 < 80
        THEN
            (
                SELECT TOP (1)
                    at.TransactionId
                FROM dbo.AccountTransaction at
                WHERE at.AccountId = so.FromAccountId
                  AND at.Amount = so.Amount
                  AND at.TransactionDirection = 'D'
                ORDER BY NEWID()
            )
        ELSE NULL
    END AS TransactionId,

    -- data wykonania
    s.ExecutionDate,

    -- kwota taka sama jak w zleceniu
    so.Amount,

    s.StatusId,

    -- powód b³êdu tylko dla FAILED
    CASE
        WHEN s.StatusId = 4 THEN
            CASE ABS(CHECKSUM(NEWID())) % 5
                WHEN 0 THEN 'Insufficient funds'
                WHEN 1 THEN 'Account blocked'
                WHEN 2 THEN 'Transaction rejected by bank'
                WHEN 3 THEN 'Technical error'
                ELSE 'Execution failed'
            END
        WHEN s.StatusId = 5 THEN
            'Standing order cancelled'
        ELSE NULL
    END AS FailureReason

FROM dbo.StandingOrder so

CROSS APPLY
(
    SELECT
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 70 THEN 3
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 82 THEN 1
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 90 THEN 2
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 96 THEN 4
            ELSE 5
        END AS StatusId,

        DATEADD(
            DAY,
            ABS(CHECKSUM(NEWID())) % 365,
            so.StartDate
        ) AS ExecutionDate
) s

WHERE s.ExecutionDate <= CAST(GETDATE() AS DATE)

ORDER BY NEWID();