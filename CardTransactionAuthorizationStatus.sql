CREATE TABLE CardTransactionAuthorizationStatus
(
	CardTransactionAuthorizationStatusId INT IDENTITY(1,1) NOT NULL,
	Code NVARCHAR(50) NOT NULL CONSTRAINT UQ_CardTransactionAuthorizationStatus_Code UNIQUE (Code),
	Name VARCHAR(100) NOT NULL,

	CONSTRAINT PK_CardTransactionAuthorizationStatus PRIMARY KEY (CardTransactionAuthorizationStatusId)
);