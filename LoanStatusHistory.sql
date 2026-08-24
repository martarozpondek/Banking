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