CREATE TABLE CustomerInteraction
(
	CustomerInteractionId BIGINT IDENTITY(1,1) NOT NULL,
	CustomerId UNIQUEIDENTIFIER NOT NULL,
	EmployeeId UNIQUEIDENTIFIER NOT NULL,
	BranchId BIGINT NOT NULL,
	InteractionTypeId INT NOT NULL,
	InteractionChannelId INT NOT NULL,
	InteractionDate DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_CustomerInteraction_InteractionDate DEFAULT SYSDATETIMEOFFSET(),
	Notes VARCHAR(300),

	CONSTRAINT PK_CustomerInteraction PRIMARY KEY(CustomerInteractionId),
	CONSTRAINT FK_CustomerInteraction_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId),
	CONSTRAINT FK_CustomerInteraction_Employee FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId),
	CONSTRAINT FK_CustomerInteraction_Branch FOREIGN KEY (BranchId) REFERENCES Branch(BranchId),
	CONSTRAINT FK_CustomerInteraction_InteractionType FOREIGN KEY (InteractionTypeId) REFERENCES InteractionType(InteractionTypeId),
	CONSTRAINT FK_CustomerInteraction_InteractionChannel FOREIGN KEY (InteractionChannelId) REFERENCES InteractionChannel(InteractionChannelId)
)

use Banking;

select * from InteractionChannel