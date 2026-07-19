CREATE DATABASE Banking;
USE Banking;
CREATE TABLE Customer
(
	CustomerId BIGINT UNIQUEIDENTIFIER NOT NULL,
	FirstName NVARCHAR(100) NOT NULL,
	LastName NVARCHAR(100) NOT NULL,
	Email VARCHAR(255),
	PhoneNumber VARCHAR(20),
	BirthDate DATE NOT NULL,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_Customer_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_Customer PRIMARY KEY (CustomerId)
);
CREATE TABLE Account
(
	AccountId BIGINT IDENTITY(1,1) NOT NULL,
	CustomerId BIGINT NOT NULL,
	AccountNumber VARCHAR(26) NOT NULL CONSTRAINT UQ_Account_AccountNumber UNIQUE (AccountNumber),
	AccountType VARCHAR(20) NOT NULL,
	CurrencyCode CHAR(3) NOT NULL,
	CurrentBalance DECIMAL(18,2) NOT NULL CONSTRAINT DF_Account_CurrentBalance DEFAULT (0),
	AvailableBalance DECIMAL(18,2) NOT NULL CONSTRAINT DF_Account_AvailableBalance DEFAULT (0),
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_Account_CreatedAt DEFAULT SYSDATETIMEOFFSET(),
	
	CONSTRAINT PK_Account PRIMARY KEY (AccountId),
	CONSTRAINT FK_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
CREATE TABLE AccountTransaction
(
	TransactionId BIGINT IDENTITY(1,1) NOT NULL,
	TransactionReference VARCHAR(200) NOT NULL,
	AccountId BIGINT NOT NULL,
	Amount DECIMAL(18,2) NOT NULL,
	TransactionType VARCHAR(50) NOT NULL,
	TransactionDate DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_Account_TransactionDate DEFAULT SYSDATETIMEOFFSET(),
	TransactionCurrencyCode CHAR(3) NOT NULL,
	Title NVARCHAR(200) NOT NULL,
	BalanceAfterTransaction DECIMAL(18,2) NOT NULL,
	CounterpartyName NVARCHAR(200) NULL,
	CounterpartyAddress NVARCHAR(300) NULL,

	CONSTRAINT PK_Transaction PRIMARY KEY (TransactionId),
	CONSTRAINT FK_Account FOREIGN KEY Account(AccountId)

);
CREATE TABLE Currency
(
    CurrencyCode CHAR(3) NOT NULL,

    CurrencyName NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_Currency PRIMARY KEY (CurrencyCode),
	CONSTRAINT FK_Transaction_Currency FOREIGN KEY (TransactionCurrencyCode) REFERENCES Currency(CurrencyCode)
);
CREATE TABLE AccountOverdraft
(
	OverdraftId INT IDENTITY(1,1) NOT NULL,
	AccountId INT NOT NULL,
	OverdraftLimit DECIMAL(18,2) NOT NULL,
	InterestRate DECIMAL(5,2) NOT NULL,
	UsedAmount DECIMAL(18,2) NOT NULL,
	AvailableAmount DECIMAL(18,2) NOT NULL,
	ActiveFrom DATE NOT NULL,
	ActiveTo DATE NOT NULL,

	CONSTRAINT PK_AccountOverdraft PRIMARY KEY (AccountId)
	CONSTRAINT FK_AccountOverdraft_Account FOREIGN KEY Account(AccountId)
)