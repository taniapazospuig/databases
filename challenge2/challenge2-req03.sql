DROP PROCEDURE IF EXISTS req03_check_currency_value;

DELIMITER //

CREATE PROCEDURE req03_check_currency_value(
    IN check_date DATE,
    IN currency_code VARCHAR(3),
    OUT result BOOLEAN
)
BEGIN
    DECLARE currency_value FLOAT;

    -- Capitalize the currency code
    SET currency_code = LOWER(currency_code);

    -- Prepare the statement to dynamically select the value of the given currency on the specified date
    SET @query = CONCAT(
        'SELECT SUM(', 
        currency_code, 
        ') 
        INTO @currency_value 
        FROM (
            SELECT ', currency_code, ' FROM FX_from_USD WHERE date = ? 
            UNION ALL 
            SELECT ', currency_code, ' FROM FX_to_USD WHERE date = ?
        ) AS combined_data'
    );

    -- Use a prepared statement to execute the dynamic SQL
    PREPARE stmt FROM @query;
    SET @check_date = check_date;
    EXECUTE stmt USING @check_date, @check_date;

    -- Clean up
    DEALLOCATE PREPARE stmt;

    -- Evaluate if the currency value is NULL or 0, set result accordingly
    IF @currency_value IS NULL OR @currency_value = 0 THEN
        SET result = FALSE;
    ELSE
        SET result = TRUE;
    END IF;

END;
//
DELIMITER ;

-- Example of usage:
/*
CALL req03_check_currency_value('2024-10-23', 'EUR', @result);
SELECT @result;  -- RESULT 1 TRUE 

CALL req03_check_currency_value('2024-10-23', 'RUB', @result);
SELECT @result;  -- RESULT 0 FALSE 
*/
