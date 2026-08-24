CREATE TABLE TransactionType
(
	TransactionTypeId INT IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(150) NOT NULL,
	Code VARCHAR(50) NOT NULL CONSTRAINT UQ_TransactionType_Code UNIQUE(Code),
	Description NVARCHAR(250) NOT NULL,

	CONSTRAINT PK_TransactionType PRIMARY KEY (TransactionTypeId)
);