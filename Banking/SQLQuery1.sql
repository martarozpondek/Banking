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
)
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
	CONSTRAINT CK_CardSecurity_PinRetryCountCHECK(PinRetryCount BETWEEN 0 AND 3) /*PIN entry limit: 0–3 attempts */
);
/*
CREATE TABLE CardTransactionAuthorizationStatus
(
	CardTransactionAuthorizationStatusId INT IDENTITY(1,1) NOT NULL,
	Code NOT NULL
);
CREATE TABLE CardTransactionAuthorization
(
	CardTransactionAuthorizationId BIGINT IDENTITY(1,1) NOT NULL,
	MerchantId INT NOT NULL,
	MCCCode CHAR(4) NOT NULL,

	CONSTRAINT PK_CardTransactionAuthorization PRIMARY KEY (CardTransactionAuthorizationId),
	CONSTRAINT FK_CardTransactionAuthorization_Merchant FOREIGN KEY (MerchantId) REFERENCES Merchant(MerchantId),
	CONSTRAINT FK_CardTransactionAuthorization_MCCCode FOREIGN KEY (MCCCode) REFERENCES MerchantCategoryCode(MCCCode),
);
*/