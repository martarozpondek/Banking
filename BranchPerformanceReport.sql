USE Banking;

CREATE PROCEDURE BranchPerformanceReport
(
	@BranchId BIGINT
)
AS
BEGIN
/*AverageBalancePerCustomer
ile średnio środków przypada na klienta oddziału?*/
    WITH CustomerBalances AS
    (
        SELECT
            c.CustomerId,
            c.BranchId,
            SUM(a.AvailableBalance) AS CustomerBalance
        FROM dbo.Customer AS c
        JOIN dbo.Account AS a
            ON c.CustomerId = a.CustomerId
        WHERE c.BranchId = @BranchId
        GROUP BY
            c.CustomerId,
            c.BranchId
    )
    SELECT COUNT(CustomerId) AS 'CustomerCount', AVG(CustomerBalance) AS 'AverageBalancePerCustomer'
	    FROM CustomerBalances;



/*AverageLoanPerCustomer jaka jest średnia ekspozycja kredytowa na klienta?
TotalLoanAmount — łączna kwota udzielonych kredytów
AverageLoanAmountPerCustomer — średnia kwota kredytów na klienta
TotalOutstandingPrincipal — aktualny kapitał pozostały do spłaty
OverdueLoanCount — liczba przeterminowanych kredytów*/

    WITH CustomerLoans AS
    (
        SELECT c.CustomerId, c.BranchId, 
        SUM(l.Amount) AS LoanAmountPerCustomer, 
        SUM(l.OutstandingPrincipal) AS OutstandingPrincipalPerCustomer,
        SUM(
            CASE
                WHEN ls.Name = 'OVERDUE' THEN 1
                ELSE 0
            END
            ) AS OverdueLoansPerCustomer
        FROM Customer AS c 
        JOIN 
        Loan AS l ON c.CustomerId = l.CustomerId
        JOIN 
        LoanStatus AS ls ON l.LoanStatusId = ls.LoanStatusId
        WHERE c.BranchId = @BranchId
        GROUP BY c.CustomerId, c.BranchId
    )
   
    SELECT
    SUM(LoanAmountPerCustomer) AS 'TotalLoanAmount', 
    AVG(LoanAmountPerCustomer) AS 'AverageLoanAmountPerCustomer',
    SUM(OutstandingPrincipalPerCustomer) AS 'TotalOutstandingPrincipal',
    SUM(OverdueLoansPerCustomer) AS 'LoanOverdueCount'
    FROM CustomerLoans;



/*CustomersPerEmployee

Czyli:

ilu klientów obsługuje średnio jeden pracownik?*/

    WITH CustomersPerEmployee AS
    (
        SELECT e.EmployeeId,
        COUNT(DISTINCT ci.CustomerId) AS CustomersPerEmployee
        FROM dbo.Employee AS e
        LEFT JOIN dbo.CustomerInteraction AS ci
        ON ci.EmployeeId = e.EmployeeId
        AND ci.BranchId = @BranchId
        WHERE e.BranchId = @BranchId
        GROUP BY e.EmployeeId
    )
    SELECT AVG(CAST(CustomersPerEmployee AS DECIMAL(10,2))) AS 'AverageCustomersPerEmployee' 
    FROM CustomersPerEmployee;


/*EmployeeCount
Ilu pracowników jest przypisanych do tego oddziału?*/

SELECT COUNT(*) AS EmployeeCount FROM Employee WHERE BranchId = @BranchId;

/*TotalCustomerInteractions
Ile wszystkich interakcji z klientami obsłużył oddział? */

SELECT COUNT(*) AS TotalCustomerInteractions FROM CustomerInteraction WHERE BranchId = @BranchId;

/* AverageInteractionsPerEmployee
Średnia liczba interakcji na pracownika */
    WITH WorkStatisticByBranch AS
    (
        SELECT
            e.EmployeeId,
            COUNT(ci.CustomerInteractionId) AS TotalCustomerInteractions
        FROM dbo.Employee AS e
        LEFT JOIN dbo.CustomerInteraction AS ci
            ON e.EmployeeId = ci.EmployeeId
            AND ci.BranchId = @BranchId
        WHERE e.BranchId = @BranchId
        GROUP BY e.EmployeeId
    )
    SELECT
        COUNT(EmployeeId) AS EmployeeCount,
        SUM(TotalCustomerInteractions) AS TotalCustomerInteractions,
        AVG(CAST(TotalCustomerInteractions AS DECIMAL(10,2)))
            AS AverageInteractionsPerEmployee
    FROM WorkStatisticByBranch;

    /* CustomersWithLoans
    Ilu klientów oddziału posiada przynajmniej jeden kredyt? */
    /*CustomersWithLoans | TotalLoans | ActiveLoans | OverdueLoans */
    SELECT COUNT(DISTINCT l.CustomerId) AS CustmerWithLoan, 
    COUNT(l.LoanId) AS TotalLoans,
        SUM(
            CASE
                WHEN ls.Name = 'Active' THEN 1
                ELSE 0
            END
            ) AS ActiveLoans,
        SUM(
            CASE 
                WHEN ls.Name = 'Overdue' THEN 1
                ELSE 0
            END
            ) AS OverdueLoans
        FROM Customer AS c 
        JOIN 
        Loan AS l ON c.CustomerId = l.CustomerId
        JOIN 
        LoanStatus AS ls ON l.LoanStatusId = ls.LoanStatusId
        WHERE c.BranchId = @BranchId;
    

    /* LoanPenetration – jaki % klientów oddziału ma kredyt
ActiveLoanRate – jaki % wszystkich kredytów jest aktywnych
OverdueLoanRate – jaki % wszystkich kredytów jest przeterminowanych 
Jaki procent klientów oddziału posiada kredyt?*/

SELECT COUNT(DISTINCT l.CustomerId) AS 'CustmerWithLoan',
COUNT(l.LoanId) AS 'TotalNumberOfLoan',
CAST(
    COUNT(DISTINCT l.CustomerId) * 100.0 /
    NULLIF(
    (SELECT COUNT(*) FROM Customer WHERE BranchId = @BranchId), 0
    ) AS DECIMAL(5,2) 
    ) AS 'LoanPenetration',
CAST(    
    SUM( 
        CASE 
            WHEN ls.Name = 'ACTIVE' THEN 1
            ELSE 0
        END
    ) * 100.0 /
    NULLIF(COUNT(l.LoanId),0) AS DECIMAL(5,2)
    )AS 'ActiveLoans',
CAST(
    SUM(
        CASE
            WHEN ls.Name = 'OVERDUE' THEN 1
            ELSE 0
        END
     ) * 100.0 /
    NULLIF(COUNT(l.LoanId),0) AS DECIMAL(5,2)
    )AS 'OverdueLoans'
FROM Loan AS l 
JOIN LoanStatus AS ls 
ON l.LoanStatusId = ls.LoanStatusId
JOIN Customer AS c
ON l.CustomerId = c.CustomerId
WHERE c.BranchId = @BranchId;
    
/*Overdue Loan Rate*/

/*Średnie saldo oddziału TotalBranchBalance Ile pieniędzy znajduje się łącznie na kontach klientów tego oddziału?*/
WITH CustomerBalance AS
(
    SELECT c.CustomerId, SUM(a.AvailableBalance) AS 'TotalBalanceForClient' FROM Customer AS c JOIN Account AS a ON c.CustomerId = a.CustomerId
    WHERE c.BranchId = @BranchId GROUP BY c.CustomerId
)
SELECT SUM(TotalBalanceForClient) AS 'TotalBranchBalance', 
AVG(TotalBalanceForClient) AS 'AverageBranchBalance' FROM CustomerBalance;
/*Liczba rachunków
Ile rachunków posiadają klienci tego oddziału? */

WITH AccountsCountPerClient AS
(
    SELECT c.CustomerId, COUNT(a.AccountId) AS 'AccountsCount' FROM Customer AS c 
    JOIN Account AS a 
    ON c.CustomerId = a.CustomerId
    WHERE c.BranchId = @BranchId 
    GROUP BY c.CustomerId
)

SELECT SUM(AccountsCount) AS 'TotalAccountsCount' FROM AccountsCountPerClient;
END;
GO




EXEC dbo.BranchPerformanceReport
    @BranchId = 2;


    
/*DROP PROCEDURE IF EXISTS dbo.BranchPerformanceReport;
GO */