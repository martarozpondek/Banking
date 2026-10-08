CREATE TABLE InteractionChannel
(
    InteractionChannelId INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Code VARCHAR(50) NOT NULL CONSTRAINT UQ_InteractionChannel_Code UNIQUE(Code),
    Description NVARCHAR(250) NOT NULL,

    CONSTRAINT PK_InteractionChannel PRIMARY KEY (InteractionChannelId)
);