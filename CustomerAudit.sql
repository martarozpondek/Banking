CREATE TABLE CustomerAudit 
(
	CustomerAuditId BIGINT IDENTITY(1,1) NOT NULL,
	CustomerId UNIQUEIDENTIFIER NOT NULL, 
	EmployeeId UNIQUEIDENTIFIER, 
	OldFirstName NVARCHAR(100),
	OldLastName NVARCHAR(100),
	OldEmail VARCHAR(255),
	OldPhoneNumber VARCHAR(20),
	NewFirstName NVARCHAR(100),
	NewLastName NVARCHAR(100),
	NewEmail VARCHAR(255),
	NewPhoneNumber VARCHAR(20),
	ChangedAt DATETIMEOFFSET(0) CONSTRAINT DF_CustomerAudit_ChangedAt DEFAULT SYSDATETIMEOFFSET(),
	Description NVARCHAR(300),

	CONSTRAINT PK_CustomerAudit PRIMARY KEY (CustomerAuditId),
	CONSTRAINT FK_CustomerAudit_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
	CONSTRAINT FK_CustomerAudit_Employee FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);
