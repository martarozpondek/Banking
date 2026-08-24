CREATE TABLE MerchantCategoryCode
(
    MCCCode CHAR(4) NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_MerchantCategoryCode PRIMARY KEY(MCCCode)
);
