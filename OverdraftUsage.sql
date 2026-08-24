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