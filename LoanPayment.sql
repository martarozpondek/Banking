CREATE TABLE LoanPayment
(
	LoanPaymentId BIGINT IDENTITY(1,1) NOT NULL,
	LoanScheduleId BIGINT NULL,
	LoanPaymentStatusId BIGINT NOT NULL,
	PaymentDate DATE NOT NULL,
	LoanPaymentTypeId BIGINT NOT NULL,
	Amount DECIMAL(18,2) NOT NULL,
	PaymentReference VARCHAR(50) UNIQUE,
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_LoanPayment_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_LoanPayment PRIMARY KEY (LoanPaymentId),
	CONSTRAINT FK_LoanPayment_LoanSchedule FOREIGN KEY (LoanScheduleId) REFERENCES LoanSchedule(LoanScheduleId),
	CONSTRAINT FK_LoanPayment_LoanPaymentType FOREIGN KEY (LoanPaymentTypeId) REFERENCES LoanPaymentType(LoanPaymentTypeId),
	CONSTRAINT FK_LoanPayment_LoanPaymentStatus FOREIGN KEY (LoanPaymentStatusId) REFERENCES LoanPaymentStatus(LoanPaymentStatusId),
	CONSTRAINT CK_LoanPayment_Amount CHECK (Amount > 0)
);