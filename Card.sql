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