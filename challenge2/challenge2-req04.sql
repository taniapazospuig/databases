DROP PROCEDURE IF EXISTS req04_currency_conversion;

DELIMITER //

CREATE PROCEDURE req04_currency_conversion(
    IN currency_origin VARCHAR(3),
    IN currency_destination VARCHAR(3),
    IN conversion_date DATE,
    INOUT amount DECIMAL(65,2),
    OUT error_message VARCHAR(255)
)
BEGIN
    DECLARE conversion_rate FLOAT;
    DECLARE result BOOLEAN;

    
    proc: BEGIN

   
    SET currency_origin = UPPER(currency_origin);
    SET currency_destination = UPPER(currency_destination);

    
    SET amount = req01_currency_rounder(amount);

    
    IF amount <= 0 THEN
        SET error_message = 'Amount to be converted must be greater than 0.';
        SET amount = 0;
        LEAVE proc;
    END IF;

    
    IF conversion_date > CURDATE() THEN
        SET error_message = 'Conversion date cannot be in the future.';
        SET amount = 0;
        LEAVE proc;
    END IF;

   
    IF NOT req02_currency_code_exists(currency_origin) THEN
        SET error_message = 'Currency of origin does not exist.';
        SET amount = 0;
        LEAVE proc;
    END IF;

    
    IF NOT req02_currency_code_exists(currency_destination) THEN
        SET error_message = 'Currency of destination does not exist.';
        SET amount = 0;
        LEAVE proc;
    END IF;

    
    IF currency_origin = currency_destination THEN
        SET error_message = 'Currency of origin and destination cannot be the same.';
        SET amount = 0;
        LEAVE proc;
    END IF;

    
    IF currency_origin != 'USD' AND currency_destination != 'USD' THEN
        SET error_message = 'Conversions must involve USD.';
        SET amount = 0;
        LEAVE proc;
    END IF;

    
    CALL req03_check_currency_value(conversion_date, 
        IF(currency_origin = 'USD', currency_destination, currency_origin), 
        result);

    IF NOT result THEN
        SET error_message = 'Conversion rate does not exist or is invalid for the given date.';
        SET amount = 0;
        LEAVE proc;
    END IF;

    
    IF currency_origin = 'USD' THEN
        
        SET @query = CONCAT(
            'SELECT ', currency_destination, 
            ' INTO @conversion_rate 
             FROM FX_from_USD 
             WHERE date = ?'
        );
    ELSE
     
        SET @query = CONCAT(
            'SELECT ', currency_origin, 
            ' INTO @conversion_rate 
             FROM FX_to_USD 
             WHERE date = ?'
        );
    END IF;

    
    SET @conversion_date = conversion_date;

   
    PREPARE stmt FROM @query;
    EXECUTE stmt USING @conversion_date;
    DEALLOCATE PREPARE stmt;

    
    IF @conversion_rate IS NULL OR @conversion_rate = 0 THEN
        SET error_message = 'Conversion rate does not exist or is invalid for the given date.';
        SET amount = 0;
        LEAVE proc;
    END IF;

    SET conversion_rate = IF(currency_origin = 'USD', @conversion_rate, 1 / @conversion_rate);
    SET amount = req01_currency_rounder(amount * conversion_rate);
    

    
    SET error_message = NULL;

    END proc;
END //

DELIMITER ;
/*

SET @amount= 1.00;

CALL req04_currency_conversion('JPY', 'EUR', '2024-10-24', @amount, @error_message);
SELECT @amount, @error_message;
*/
