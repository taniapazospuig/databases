DROP TABLE IF EXISTS payments; 

DROP TRIGGER IF EXISTS req08_bar_consumption_payment;
DROP TRIGGER IF EXISTS req08_beerman_sales_payment;

CREATE TABLE payments (
    id_transaction INT AUTO_INCREMENT PRIMARY KEY,          
    transaction_type ENUM('beerman', 'bar') NOT NULL,      
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    price_usd FLOAT NOT NULL,                               
    buyer_id INT(10) UNSIGNED NOT NULL,                                  
    default_currency VARCHAR(3) NOT NULL DEFAULT 'USD',     
    price_in_currency FLOAT NOT NULL, 
    payment_status BOOLEAN NOT NULL,                        
    error_message VARCHAR(255) DEFAULT NULL,               


    FOREIGN KEY (buyer_id) REFERENCES person(id_person)
);


DELIMITER //

CREATE TRIGGER req08_bar_consumption_payment
AFTER INSERT ON festivalgoer_consumes
FOR EACH ROW
BEGIN
    DECLARE buyer_currency VARCHAR(3);
    DECLARE conversion_rate FLOAT DEFAULT 1;
    DECLARE error_msg VARCHAR(255);
    DECLARE price FLOAT;
    DECLARE price_in_currency FLOAT;

    -- buyer's preferred currency
    SET buyer_currency = req07_get_preferred_currency(NEW.id_festivalgoer);

    -- If no preferred currency, use a random valid currency (not USD)
    IF buyer_currency IS NULL THEN
        SELECT COLUMN_NAME INTO buyer_currency
        FROM information_schema.COLUMNS
        WHERE TABLE_NAME = 'FX_from_USD'
          AND COLUMN_NAME != 'date'
          AND COLUMN_NAME != 'USD'
        ORDER BY RAND()
        LIMIT 1;
    END IF;

   
    SELECT bp.unit_price INTO price
    FROM bar_product bp
    WHERE bp.id_product = NEW.id_product AND bp.id_bar = NEW.id_bar;

  
    SET error_msg = NULL;
    SET conversion_rate = 1;

   
    IF buyer_currency != 'USD' THEN
        -- Create a temporary table to get conversion rates for the current day as recommended in the e-mail
        CREATE TEMPORARY TABLE IF NOT EXISTS temp_conversion_rates AS
        SELECT 
            date,
            EUR, JPY, BGN, CZK, DKK, GBP, HUF, PLN, RON, SEK, CHF, ISK, NOK, HRK, RUB, TRL, TRY, AUD, DRL, CAD, CNY, HKD, IDR, ILS, INR, KRW, MXN, MYR, NZD, PHP, SGD, THB, ZAR
        FROM FX_from_USD
        WHERE date = CURDATE();

        
        SET conversion_rate = (
            SELECT CASE 
                WHEN buyer_currency = 'EUR' THEN EUR
                WHEN buyer_currency = 'JPY' THEN JPY
                WHEN buyer_currency = 'BGN' THEN BGN
                WHEN buyer_currency = 'CZK' THEN CZK
                WHEN buyer_currency = 'DKK' THEN DKK
                WHEN buyer_currency = 'GBP' THEN GBP
                WHEN buyer_currency = 'HUF' THEN HUF
                WHEN buyer_currency = 'PLN' THEN PLN
                WHEN buyer_currency = 'RON' THEN RON
                WHEN buyer_currency = 'SEK' THEN SEK
                WHEN buyer_currency = 'CHF' THEN CHF
                WHEN buyer_currency = 'ISK' THEN ISK
                WHEN buyer_currency = 'NOK' THEN NOK
                WHEN buyer_currency = 'HRK' THEN HRK
                WHEN buyer_currency = 'RUB' THEN RUB
                WHEN buyer_currency = 'TRL' THEN TRL
                WHEN buyer_currency = 'TRY' THEN TRY
                WHEN buyer_currency = 'AUD' THEN AUD
                WHEN buyer_currency = 'DRL' THEN DRL
                WHEN buyer_currency = 'CAD' THEN CAD
                WHEN buyer_currency = 'CNY' THEN CNY
                WHEN buyer_currency = 'HKD' THEN HKD
                WHEN buyer_currency = 'IDR' THEN IDR
                WHEN buyer_currency = 'ILS' THEN ILS
                WHEN buyer_currency = 'INR' THEN INR
                WHEN buyer_currency = 'KRW' THEN KRW
                WHEN buyer_currency = 'MXN' THEN MXN
                WHEN buyer_currency = 'MYR' THEN MYR
                WHEN buyer_currency = 'NZD' THEN NZD
                WHEN buyer_currency = 'PHP' THEN PHP
                WHEN buyer_currency = 'SGD' THEN SGD
                WHEN buyer_currency = 'THB' THEN THB
                WHEN buyer_currency = 'ZAR' THEN ZAR
                ELSE 0
            END 
            FROM temp_conversion_rates
            LIMIT 1
        );

        
        DROP TEMPORARY TABLE IF EXISTS temp_conversion_rates;

        
        IF conversion_rate = 0 OR conversion_rate IS NULL THEN
            SET error_msg = 'Currency conversion error.';
        END IF;
    END IF;

    
    IF error_msg IS NOT NULL THEN
        SET price_in_currency = price;  -- Use USD as fallback
    ELSE
        SET price_in_currency = price * conversion_rate;
    END IF;

    
    INSERT INTO payments (
        transaction_type,
        transaction_date,
        price_usd,
        buyer_id,
        default_currency,
        price_in_currency,
        payment_status,
        error_message
    )
    VALUES (
        'bar',
        NOW(),
        price,
        NEW.id_festivalgoer,
        buyer_currency,
        price_in_currency,
        IF(error_msg IS NULL, TRUE, FALSE),
        error_msg
    );

END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER req08_beerman_sales_payment
AFTER INSERT ON beerman_sells
FOR EACH ROW
BEGIN
    DECLARE buyer_currency VARCHAR(3);
    DECLARE conversion_rate FLOAT DEFAULT 1;
    DECLARE error_msg VARCHAR(255);
    DECLARE price FLOAT;
    DECLARE price_in_currency FLOAT;

  
    SET buyer_currency = req07_get_preferred_currency(NEW.id_festivalgoer);

    
    IF buyer_currency IS NULL THEN
        SELECT COLUMN_NAME INTO buyer_currency
        FROM information_schema.COLUMNS
        WHERE TABLE_NAME = 'FX_from_USD'
          AND COLUMN_NAME != 'date'
          AND COLUMN_NAME != 'USD'
        ORDER BY RAND()
        LIMIT 1;
    END IF;

    
    SET price = 3;

    
    SET error_msg = NULL;

    
    IF buyer_currency != 'USD' THEN
       
        CREATE TEMPORARY TABLE IF NOT EXISTS temp_conversion_rates AS
        SELECT 
            date,
            EUR, JPY, BGN, CZK, DKK, GBP, HUF, PLN, RON, SEK, CHF, ISK, NOK, HRK, RUB, TRL, TRY, AUD, DRL, CAD, CNY, HKD, IDR, ILS, INR, KRW, MXN, MYR, NZD, PHP, SGD, THB, ZAR
        FROM FX_from_USD
        WHERE date = CURDATE();

        
        SET conversion_rate = (
            SELECT CASE 
                WHEN buyer_currency = 'EUR' THEN EUR
                WHEN buyer_currency = 'JPY' THEN JPY
                WHEN buyer_currency = 'BGN' THEN BGN
                WHEN buyer_currency = 'CZK' THEN CZK
                WHEN buyer_currency = 'DKK' THEN DKK
                WHEN buyer_currency = 'GBP' THEN GBP
                WHEN buyer_currency = 'HUF' THEN HUF
                WHEN buyer_currency = 'PLN' THEN PLN
                WHEN buyer_currency = 'RON' THEN RON
                WHEN buyer_currency = 'SEK' THEN SEK
                WHEN buyer_currency = 'CHF' THEN CHF
                WHEN buyer_currency = 'ISK' THEN ISK
                WHEN buyer_currency = 'NOK' THEN NOK
                WHEN buyer_currency = 'HRK' THEN HRK
                WHEN buyer_currency = 'RUB' THEN RUB
                WHEN buyer_currency = 'TRL' THEN TRL
                WHEN buyer_currency = 'TRY' THEN TRY
                WHEN buyer_currency = 'AUD' THEN AUD
                WHEN buyer_currency = 'DRL' THEN DRL
                WHEN buyer_currency = 'CAD' THEN CAD
                WHEN buyer_currency = 'CNY' THEN CNY
                WHEN buyer_currency = 'HKD' THEN HKD
                WHEN buyer_currency = 'IDR' THEN IDR
                WHEN buyer_currency = 'ILS' THEN ILS
                WHEN buyer_currency = 'INR' THEN INR
                WHEN buyer_currency = 'KRW' THEN KRW
                WHEN buyer_currency = 'MXN' THEN MXN
                WHEN buyer_currency = 'MYR' THEN MYR
                WHEN buyer_currency = 'NZD' THEN NZD
                WHEN buyer_currency = 'PHP' THEN PHP
                WHEN buyer_currency = 'SGD' THEN SGD
                WHEN buyer_currency = 'THB' THEN THB
                WHEN buyer_currency = 'ZAR' THEN ZAR
                ELSE 0
            END 
            FROM temp_conversion_rates
            LIMIT 1
        );

       
        DROP TEMPORARY TABLE IF EXISTS temp_conversion_rates;

        
        IF conversion_rate = 0 OR conversion_rate IS NULL THEN
            SET error_msg = 'Currency conversion error.';
        END IF;
    END IF;

    
    IF error_msg IS NOT NULL THEN
        SET price_in_currency = price;  
    ELSE
        SET price_in_currency = price * conversion_rate;
    END IF;

  
    INSERT INTO payments (
        transaction_type,
        transaction_date,
        price_usd,
        buyer_id,
        default_currency,
        price_in_currency,
        payment_status,
        error_message
    )
    VALUES (
        'beerman',
        NOW(),
        price,
        NEW.id_festivalgoer,
        buyer_currency,
        price_in_currency,
        IF(error_msg IS NULL, TRUE, FALSE),
        error_msg
    );

END //

DELIMITER ;

-- we have tried with:
/*
INSERT INTO beerman_sells (id_beerman_sells, id_beerman, id_festivalgoer, festival_name, festival_edition, id_stage)
VALUES (1000002, 998908, 27581, 'Hellfest', 2023, 1);
SELECT * FROM payments;
*/

