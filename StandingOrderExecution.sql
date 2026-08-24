CREATE TABLE StandingOrderExecution
(
    StandingOrderExecutionId BIGINT IDENTITY(1,1) NOT NULL,
    StandingOrderId BIGINT NOT NULL,
    TransactionId BIGINT NULL,
    ExecutionDate DATE NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    StandingOrderExecutionStatusId BIGINT NOT NULL,
    FailureReason NVARCHAR(250) NULL,
    CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_StandingOrderExecution_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

    CONSTRAINT PK_StandingOrderExecution PRIMARY KEY (StandingOrderExecutionId),
    CONSTRAINT FK_StandingOrderExecution_StandingOrder FOREIGN KEY (StandingOrderId) REFERENCES StandingOrder(StandingOrderId),
    CONSTRAINT FK_StandingOrderExecution_Transaction FOREIGN KEY (TransactionId) REFERENCES AccountTransaction(TransactionId),
    CONSTRAINT FK_StandingOrderExecution_Status FOREIGN KEY (StandingOrderExecutionStatusId) REFERENCES StandingOrderExecutionStatus(StandingOrderExecutionStatusId),
	CONSTRAINT CK_StandingOrderExecution_Amount CHECK (Amount > 0)
);