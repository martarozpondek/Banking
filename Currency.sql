CREATE TABLE Currency
(
    CurrencyCode CHAR(3) NOT NULL,
    CurrencyName NVARCHAR(50) NOT NULL,
	CurrencySymbol NVARCHAR(5) NOT NULL,

    CONSTRAINT PK_Currency PRIMARY KEY (CurrencyCode)
	
);