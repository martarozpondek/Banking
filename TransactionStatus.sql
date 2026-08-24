CREATE TABLE TransactionStatus
(
    TransactionStatusId INT IDENTITY(1,1) NOT NULL,
    Code VARCHAR(50) NOT NULL CONSTRAINT UQ_TransactionStatus_Code UNIQUE(Code),
    Name NVARCHAR(100) NOT NULL,

	CONSTRAINT PK_TransactionStatus PRIMARY KEY (TransactionStatusId)
);