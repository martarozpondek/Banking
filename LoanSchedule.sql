CREATE TABLE LoanSchedule
(
	LoanScheduleId BIGINT IDENTITY(1,1) NOT NULL,
	InstallmentNumber INT NOT NULL,
	LoanId BIGINT NOT NULL,
	LoanInstallmentStatusId BIGINT NOT NULL,
	DueDate DATE NOT NULL,
    PrincipalAmount DECIMAL(18,2) NOT NULL,
    InterestAmount DECIMAL(18,2) NOT NULL,
    TotalAmount AS ( PrincipalAmount + InterestAmount ) PERSISTED,
	PaidAmount DECIMAL(18,2) NOT NULL DEFAULT(0),
    PaidDate DATE NULL,
	RemainingAmount AS (PrincipalAmount + InterestAmount - PaidAmount) PERSISTED,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_LoanSchedule_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_LoanSchedule PRIMARY KEY (LoanScheduleId),
	CONSTRAINT FK_LoanSchedule_Loan FOREIGN KEY (LoanId) REFERENCES Loan(LoanId),
	CONSTRAINT FK_LoanSchedule_LoanInstallmentStatus FOREIGN KEY (LoanInstallmentStatusId) REFERENCES LoanInstallmentStatus(LoanInstallmentStatusId),
	CONSTRAINT CK_LoanSchedule_Amounts CHECK (PrincipalAmount >= 0 AND InterestAmount >= 0),
	CONSTRAINT UQ_LoanSchedule_Installment UNIQUE (LoanId, InstallmentNumber),
	CONSTRAINT CK_LoanSchedule_PaidAmount CHECK (PaidAmount >=0 AND PaidAmount <= TotalAmount)
);