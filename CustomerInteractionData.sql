INSERT INTO CustomerInteraction
(
    CustomerId,
    EmployeeId,
    BranchId,
    InteractionTypeId,
    InteractionChannelId,
    InteractionDate,
    Notes
)
SELECT
    c.CustomerId,
    e.EmployeeId,
    b.BranchId,
    it.InteractionTypeId,
    ic.InteractionChannelId,
    DATEADD(
        DAY,
        -(ABS(CHECKSUM(NEWID())) % 365),
        SYSDATETIMEOFFSET()
    ),
    CASE it.Code
        WHEN 'ACCOUNT_BALANCE_INQUIRY'
            THEN 'Customer requested information about account balance.'

        WHEN 'ACCOUNT_OPENING'
            THEN 'Customer opened a new bank account.'

        WHEN 'ACCOUNT_CLOSURE'
            THEN 'Customer requested closure of a bank account.'

        WHEN 'ACCOUNT_SERVICE'
            THEN 'Customer requested assistance with an existing bank account.'

        WHEN 'BILL_PAYMENT'
            THEN 'Customer made a payment for a bill or regular service.'

        WHEN 'BANK_TRANSFER'
            THEN 'Customer requested assistance with a bank transfer.'

        WHEN 'CASH_DEPOSIT'
            THEN 'Customer deposited cash into an account.'

        WHEN 'CASH_WITHDRAWAL'
            THEN 'Customer withdrew cash from an account.'

        WHEN 'CASHIER_SERVICE'
            THEN 'Customer received assistance with a cash transaction.'

        WHEN 'CARD_SERVICE'
            THEN 'Customer requested assistance with a payment card.'

        WHEN 'CARD_ISSUANCE'
            THEN 'Customer requested a new payment card.'

        WHEN 'CARD_BLOCKING'
            THEN 'Customer requested blocking of a payment card.'

        WHEN 'COMPLAINT'
            THEN 'Customer submitted a complaint about a banking service.'

        WHEN 'CURRENCY_EXCHANGE'
            THEN 'Customer exchanged one currency for another.'

        WHEN 'DIGITAL_BANKING_SUPPORT'
            THEN 'Customer requested assistance with digital banking services.'

        WHEN 'DIRECT_DEBIT_SETUP'
            THEN 'Customer requested setup of a direct debit.'

        WHEN 'FINANCIAL_ADVICE'
            THEN 'Customer requested financial or banking advice.'

        WHEN 'GENERAL_INQUIRY'
            THEN 'Customer requested general information about banking products or services.'

        WHEN 'LOAN_INQUIRY'
            THEN 'Customer requested information about a loan.'

        WHEN 'LOAN_APPLICATION'
            THEN 'Customer submitted or discussed a loan application.'

        WHEN 'LOAN_SERVICE'
            THEN 'Customer requested assistance with an existing loan.'

        WHEN 'PAYMENT_ISSUE'
            THEN 'Customer reported a problem with a payment or transaction.'

        WHEN 'PERSONAL_DATA_UPDATE'
            THEN 'Customer requested a change to personal information.'

        WHEN 'STANDING_ORDER_SETUP'
            THEN 'Customer requested setup of a standing order.'

        WHEN 'STANDING_ORDER_CANCELLATION'
            THEN 'Customer requested cancellation of a standing order.'

        WHEN 'TRANSACTION_INQUIRY'
            THEN 'Customer requested information about a specific transaction.'

        ELSE
            'Customer requested assistance with a banking service.'
    END
FROM dbo.Customer AS c

-- 4 interactions per customer
CROSS JOIN
(
    VALUES
        (1),
        (2),
        (3),
        (4)
) AS interaction_number(Number)

-- Select the branch where the interaction actually took place.
-- 65% of interactions happen in the customer's home branch,
-- 35% in another randomly selected branch.
CROSS APPLY
(
    SELECT TOP (1)
        br.BranchId
    FROM dbo.Branch AS br
    WHERE
        (
            ABS(CHECKSUM(NEWID())) % 100 < 65
            AND br.BranchId = c.BranchId
        )
        OR
        (
            ABS(CHECKSUM(NEWID())) % 100 >= 65
        )
    ORDER BY NEWID()
) AS b

-- Select an employee working in the branch where
-- the interaction actually took place.
CROSS APPLY
(
    SELECT TOP (1)
        emp.EmployeeId
    FROM dbo.Employee AS emp
    WHERE emp.BranchId = b.BranchId
    ORDER BY NEWID()
) AS e

-- Select a random interaction type.
CROSS APPLY
(
    SELECT TOP (1)
        i.InteractionTypeId,
        i.Code
    FROM dbo.InteractionType AS i
    ORDER BY NEWID()
) AS it

-- Select a realistic channel for the selected interaction type.
CROSS APPLY
(
    SELECT TOP (1)
        ch.InteractionChannelId
    FROM dbo.InteractionChannel AS ch
    WHERE
        (
            it.Code = 'CASH_WITHDRAWAL'
            AND ch.Code IN ('BRANCH', 'ATM')
        )
        OR
        (
            it.Code = 'CASH_DEPOSIT'
            AND ch.Code = 'BRANCH'
        )
        OR
        (
            it.Code = 'CASHIER_SERVICE'
            AND ch.Code = 'BRANCH'
        )
        OR
        (
            it.Code = 'ACCOUNT_OPENING'
            AND ch.Code IN ('BRANCH', 'VIDEO_CALL')
        )
        OR
        (
            it.Code = 'ACCOUNT_CLOSURE'
            AND ch.Code IN ('BRANCH', 'PHONE')
        )
        OR
        (
            it.Code = 'ACCOUNT_SERVICE'
            AND ch.Code IN ('BRANCH', 'PHONE', 'CHAT')
        )
        OR
        (
            it.Code = 'ACCOUNT_BALANCE_INQUIRY'
            AND ch.Code IN
                ('BRANCH', 'PHONE', 'MOBILE_APP', 'INTERNET_BANKING')
        )
        OR
        (
            it.Code = 'BILL_PAYMENT'
            AND ch.Code IN
                ('BRANCH', 'PHONE', 'MOBILE_APP', 'INTERNET_BANKING')
        )
        OR
        (
            it.Code = 'BANK_TRANSFER'
            AND ch.Code IN
                ('BRANCH', 'PHONE', 'MOBILE_APP', 'INTERNET_BANKING')
        )
        OR
        (
            it.Code = 'CARD_SERVICE'
            AND ch.Code IN ('BRANCH', 'PHONE', 'CHAT')
        )
        OR
        (
            it.Code = 'CARD_ISSUANCE'
            AND ch.Code IN ('BRANCH', 'PHONE')
        )
        OR
        (
            it.Code = 'CARD_BLOCKING'
            AND ch.Code IN ('BRANCH', 'PHONE', 'MOBILE_APP')
        )
        OR
        (
            it.Code = 'COMPLAINT'
            AND ch.Code IN ('BRANCH', 'PHONE', 'EMAIL')
        )
        OR
        (
            it.Code = 'CURRENCY_EXCHANGE'
            AND ch.Code IN
                ('BRANCH', 'MOBILE_APP', 'INTERNET_BANKING')
        )
        OR
        (
            it.Code = 'DIGITAL_BANKING_SUPPORT'
            AND ch.Code IN ('BRANCH', 'PHONE', 'CHAT')
        )
        OR
        (
            it.Code = 'DIRECT_DEBIT_SETUP'
            AND ch.Code IN
                ('BRANCH', 'PHONE', 'MOBILE_APP', 'INTERNET_BANKING')
        )
        OR
        (
            it.Code = 'FINANCIAL_ADVICE'
            AND ch.Code IN ('BRANCH', 'PHONE', 'VIDEO_CALL')
        )
        OR
        (
            it.Code = 'GENERAL_INQUIRY'
            AND ch.Code IN ('BRANCH', 'PHONE', 'EMAIL', 'CHAT')
        )
        OR
        (
            it.Code = 'LOAN_INQUIRY'
            AND ch.Code IN ('BRANCH', 'PHONE', 'VIDEO_CALL')
        )
        OR
        (
            it.Code = 'LOAN_APPLICATION'
            AND ch.Code IN ('BRANCH', 'PHONE', 'VIDEO_CALL')
        )
        OR
        (
            it.Code = 'LOAN_SERVICE'
            AND ch.Code IN ('BRANCH', 'PHONE', 'VIDEO_CALL')
        )
        OR
        (
            it.Code = 'PAYMENT_ISSUE'
            AND ch.Code IN ('BRANCH', 'PHONE', 'CHAT')
        )
        OR
        (
            it.Code = 'PERSONAL_DATA_UPDATE'
            AND ch.Code IN
                ('BRANCH', 'PHONE', 'INTERNET_BANKING')
        )
        OR
        (
            it.Code = 'STANDING_ORDER_SETUP'
            AND ch.Code IN
                ('BRANCH', 'PHONE', 'MOBILE_APP', 'INTERNET_BANKING')
        )
        OR
        (
            it.Code = 'STANDING_ORDER_CANCELLATION'
            AND ch.Code IN
                ('BRANCH', 'PHONE', 'MOBILE_APP', 'INTERNET_BANKING')
        )
        OR
        (
            it.Code = 'TRANSACTION_INQUIRY'
            AND ch.Code IN
                ('BRANCH', 'PHONE', 'MOBILE_APP', 'INTERNET_BANKING')
        )
    ORDER BY NEWID()
) AS ic;