CREATE PROCEDURE CheckCardPinBlock
(
	@CardId BIGINT
)
AS
BEGIN
	IF EXISTS
	(
		SELECT CardId FROM CardSecurity
		WHERE @CardId = CardId AND IsBlocked = 1
		AND BlockedUntil IS NOT NULL
		AND BlockedUntil <= SYSDATETIMEOFFSET() 
	)
	BEGIN
	    UPDATE CardSecurity
        SET PinRetryCount = 0,
            IsBlocked = 0,
            BlockedUntil = NULL,
            UpdatedAt = SYSDATETIMEOFFSET()
        WHERE CardId = @CardId;
        
        PRINT 'PIN BLOCK EXPIRED. CARD IS UNBLOCKED.';
	END
	  BEGIN
        PRINT 'NO EXPIRED PIN BLOCK FOUND.';
    END;	
END;




