CREATE TABLE ExchangeRate
(
	ExchangeRateId INT IDENTITY(1,1) NOT NULL,
	CurrencyCode CHAR(3) NOT NULL,
	ExchangeRateDate DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_ExchangeRate_ExchangeRateDate DEFAULT SYSDATETIMEOFFSET(),
	CurrencyConversionRate DECIMAL(10, 4) NOT NULL,
	Multiplier DECIMAL(10,4) NOT NULL CONSTRAINT DF_ExchangeRate_Multiplier DEFAULT (1), 
	CreatedAt DATETIMEOFFSET(0) NOT NULL CONSTRAINT DF_ExchangeRate_CreatedAt DEFAULT SYSDATETIMEOFFSET(),

	CONSTRAINT PK_ExchangeRate PRIMARY KEY (ExchangeRateId),
	CONSTRAINT FK_ExchangeRate_Currency FOREIGN KEY (CurrencyCode) REFERENCES Currency(CurrencyCode),
	CONSTRAINT UQ_ExchangeRate_CurrencyDate UNIQUE (CurrencyCode, ExchangeRateDate),
	CONSTRAINT CK_ExchangeRate_Rate CHECK (CurrencyConversionRate > 0),
	CONSTRAINT CK_ExchangeRate_Multiplier CHECK (Multiplier > 0)
);