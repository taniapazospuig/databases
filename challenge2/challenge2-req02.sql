DROP FUNCTION IF EXISTS req02_currency_code_exists;

DELIMITER //
CREATE FUNCTION req02_currency_code_exists(currency_code VARCHAR(3))
RETURNS BOOLEAN
DETERMINISTIC 

BEGIN

	DECLARE flag BOOLEAN;
    SET currency_code = UPPER(currency_code); -- to pass to capital 
    
    SELECT EXISTS (
		SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_NAME IN('FX_from_USD','FX_to_USD')
			AND COLUMN_NAME = currency_code
	)INTO flag;
    
    RETURN(currency_code ='USD' OR flag);

END//
DELIMITER ;

-- EXAMPLES 

/*
 SELECT req02_currency_code_exists('EUR') ; 	output=1

 SELECT req02_currency_code_exists('USD') ;		output=1
 SELECT req02_currency_code_exists('XXX') ;		output=0
 
 
*/
