USE Banking;
GO

:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\Currency.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\AccountType.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\TransactionType.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\TransactionStatus.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\MerchantCategoryCode.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\CardStatus.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\CardTransactionAuthorizationStatus.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\OverdraftUsageType.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\StandingOrderFrequency.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\StandingOrderExecutionStatus.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\LoanStatus.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\LoanInstallmentStatus.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\LoanPaymentType.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\LoanPaymentStatus.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\InterestRateType.sql"

-- Core entities
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\Branch.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\Customer.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\Employee.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\Merchant.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\Account.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\AccountOverdraft.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\ExchangeRate.sql"

-- Transactions and dependent entities
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\AccountTransaction.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\LedgerEntry.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\OverdraftUsage.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\OverdraftInterest.sql"

-- Card domain
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\Card.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\CardSecurity.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\CardTransactionAuthorization.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\CardTransactionAuthorizationStatusHistory.sql"

-- Loan domain
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\Loan.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\LoanStatusHistory.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\LoanInterestAccrual.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\LoanSchedule.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\LoanPayment.sql"

-- Standing orders
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\StandingOrder.sql"
:r "C:\Users\marta\Documents\SQL Server Management Studio 21\Projects\Banking\StandingOrderExecution.sql"