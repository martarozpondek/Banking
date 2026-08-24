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