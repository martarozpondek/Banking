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
	OverdraftUsageTypeName VARCHAR(100) NOT NULL,

	CONSTRAINT PK_OverdraftUsageType PRIMARY KEY (OverdraftUsageTypeId)
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

