CREATE PROCEDURE RegisterFailedCardPinAttempt
(
	@CardId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;
	IF NOT EXISTS
    (
        SELECT 1
        FROM CardSecurity
        WHERE CardId = @CardId
    )
    BEGIN
        PRINT 'CARD SECURITY RECORD NOT FOUND';
        RETURN;
    END;
    /* uruchomienie procedury, która sprawdza, 
    czy blokada PIN-u wygasła. 
    Jeśli tak, usuwa blokadę i zeruje licznik. */
    EXEC CheckCardPinBlock
        @CardId = @CardId;

    /* sprawdzenie aktualnego stanu w tabeli po wykonaniu poprzedniej procedury */
    IF EXISTS
    (
        SELECT 1
        FROM CardSecurity
        WHERE CardId = @CardId
          AND IsBlocked = 1
    )
    BEGIN
        PRINT 'CARD IS BLOCKED';
        RETURN;
    END;

    UPDATE CardSecurity
    SET PinRetryCount = PinRetryCount + 1,
        UpdatedAt = SYSDATETIMEOFFSET()
    WHERE CardId = @CardId;

    /*Zablokowanie karty po trzech nieudanych próbach */
    IF EXISTS
    (
        SELECT 1
        FROM CardSecurity
        WHERE CardId = @CardId
          AND PinRetryCount = 3
    )
    BEGIN
        UPDATE CardSecurity
        SET IsBlocked = 1,
            BlockedUntil = DATEADD(MINUTE, 1, SYSDATETIMEOFFSET()),
            UpdatedAt = SYSDATETIMEOFFSET()
        WHERE CardId = @CardId;

        PRINT 'CARD BLOCKED FOR 1 MINUTE AFTER 3 FAILED PIN ATTEMPTS';
        RETURN;
    END;

    
    PRINT 'FAILED PIN ATTEMPT REGISTERED';
 
END;



SELECT
    CardAuthorizationId,
    CardId,
    PinRetryCount,
    IsBlocked,
    BlockedUntil
FROM dbo.CardSecurity
ORDER BY CardId;

EXEC dbo.RegisterFailedCardPinAttempt
    @CardId = 1;

SELECT CardId, PinRetryCount, IsBlocked, BlockedUntil
FROM dbo.CardSecurity
WHERE CardId = 1;