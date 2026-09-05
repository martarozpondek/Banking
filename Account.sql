CREATE TABLE Account
(
	AccountId BIGINT IDENTITY(1,1) NOT NULL,
	CustomerId UNIQUEIDENTIFIER NOT NULL,
	AccountNumber VARCHAR(26) NOT NULL CONSTRAINT UQ_Account_AccountNumber UNIQUE (AccountNumber),
	AccountTypeId INT NOT NULL,
	CurrencyCode CHAR(3) NOT NULL,
	CurrentBalance DECIMAL(18,2) NOT NULL CONSTRAINT DF_Account_CurrentBalance DEFAULT (0), /*Total account balance excluding the blocked amount.*/
	AvailableBalance DECIMAL(18,2) NOT NULL CONSTRAINT DF_Account_AvailableBalance DEFAULT (0), /*The amount actually available for immediate use.*/
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_Account_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_Account PRIMARY KEY (AccountId),
	CONSTRAINT FK_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
	CONSTRAINT FK_Account_Currency FOREIGN KEY (CurrencyCode) REFERENCES Currency(CurrencyCode),
	CONSTRAINT FK_Account_AccountType FOREIGN KEY (AccountTypeId) REFERENCES AccountType(AccountTypeId)
);
