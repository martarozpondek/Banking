CREATE TABLE InteractionType
(
	InteractionTypeId INT IDENTITY(1,1) NOT NULL,
	Name NVARCHAR(150) NOT NULL,
	Code VARCHAR(50) NOT NULL CONSTRAINT UQ_InteractionType_Code UNIQUE(Code),
	Description NVARCHAR(250) NOT NULL,

	CONSTRAINT PK_InteractionType PRIMARY KEY (InteractionTypeId)
);

