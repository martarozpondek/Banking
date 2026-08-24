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