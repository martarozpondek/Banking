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