DROP FUNCTION IF EXISTS req01_currency_rounder;

DELIMITER //
CREATE FUNCTION req01_currency_rounder(float_number FLOAT)
RETURNS FLOAT
DETERMINISTIC 

BEGIN

	IF (float_number != ROUND(float_number,2)) THEN 
		RETURN ROUND(float_number,2);
	ELSE 
		RETURN float_number;
        
	END IF;

END//
DELIMITER ;

-- EXAMPLES 

/* 
SELECT req01_currency_rounder(3.236) ; 	output=3.24

 SELECT req01_currency_rounder(3.23) ;	output=3.23
 */

