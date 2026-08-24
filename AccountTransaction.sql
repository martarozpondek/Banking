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