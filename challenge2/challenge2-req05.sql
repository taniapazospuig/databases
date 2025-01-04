DROP PROCEDURE IF EXISTS req05_populate_conversion_data;
DELIMITER //

SET SQL_SAFE_UPDATES = 0;

CREATE PROCEDURE req05_populate_conversion_data()
BEGIN
    DECLARE last_date DATE;
    DECLARE curr_date DATE;
    DECLARE currency_code VARCHAR(255);
    DECLARE done BOOLEAN DEFAULT FALSE;

    -- Cursor to iterate through all currency codes in the conversion tables
    DECLARE cur CURSOR FOR
        SELECT COLUMN_NAME
        FROM information_schema.COLUMNS
        WHERE TABLE_NAME = 'FX_from_USD'
        AND COLUMN_NAME != 'date'
        AND TABLE_SCHEMA = 'P101_20_challange2_music_festival';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT MAX(date) INTO last_date FROM FX_from_USD; -- Last date available in the conversion table

	SET @last_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY); -- Last date will be one day after the current date
    SET curr_date = DATE_ADD(last_date, INTERVAL 1 DAY); -- First date we will add is one day after the last available date
    
    -- While to insert a new row with NULL values in both conversion tables
     WHILE curr_date <= @last_date DO
        SET @curr_date = curr_date;

        INSERT INTO FX_from_USD (`date`)
        VALUES (@curr_date);

        INSERT INTO FX_to_USD (`date`)
        VALUES (@curr_date);

        SET curr_date = DATE_ADD(@curr_date, INTERVAL 1 DAY); -- Next iteration
    END WHILE;

    OPEN cur; -- Open the cursor

    -- Iterate through all currencies
    fetch_loop: LOOP
        FETCH cur INTO currency_code;

        -- Exit the loop if no more currencies
        IF done THEN
            LEAVE fetch_loop;
        END IF;
		
        SET @currency_code = currency_code;
        
        SET curr_date = DATE_ADD(last_date, INTERVAL 1 DAY);

        -- Loop through each missing date
        populate_loop: WHILE curr_date <= @last_date DO 
            SET @curr_date = curr_date;

            -- Retrieve the last conversion rate for the current currency
            SET @query_last_conversion = CONCAT(
                'SELECT ', @currency_code, ' INTO @last_conversion_rate FROM FX_from_USD WHERE date = ? LIMIT 1'
            );

            PREPARE stmt FROM @query_last_conversion;
            SET @r_date = DATE_SUB(@curr_date, INTERVAL 1 DAY);
            EXECUTE stmt USING @r_date;
            DEALLOCATE PREPARE stmt;

            -- Determine the new conversion rate
            IF @last_conversion_rate = 0 THEN
                SET @new_conversion_rate = 0;
            ELSE
                -- Pick a random value greater than 0 from last year
                SET @query_new_conversion_rate = CONCAT(
                    'SELECT ', @currency_code, 
                    ' INTO @new_conversion_rate FROM FX_from_USD WHERE date BETWEEN ? AND ? AND ', @currency_code, ' > 0 ORDER BY RAND() LIMIT 1'
                );

                PREPARE stmt FROM @query_new_conversion_rate;
                SET @start_date = DATE_SUB(@curr_date, INTERVAL 1 YEAR);
                SET @end_date = DATE_SUB(@curr_date, INTERVAL 1 DAY);
                EXECUTE stmt USING @start_date, @end_date;
                DEALLOCATE PREPARE stmt;
            END IF;

            -- Update the new conversion rate
            SET @update_query_from_usd = CONCAT(
                'UPDATE FX_from_USD SET ', @currency_code, ' = ? WHERE date = ?'
            );

            PREPARE stmt FROM @update_query_from_usd;
            SET @insert_value = @new_conversion_rate;
            EXECUTE stmt USING @insert_value, @curr_date;
            DEALLOCATE PREPARE stmt;

            -- Calculate the reciprocal conversion rate for FX_to_USD
            IF @new_conversion_rate != 0 THEN
                SET @reciprocal_rate = 1 / @new_conversion_rate;
            ELSE
                SET @reciprocal_rate = 0;
            END IF;

            -- Update the new conversion rate
            SET @update_query_to_usd = CONCAT(
                'UPDATE FX_to_USD SET ', @currency_code, ' = ? WHERE date = ?'
            );

            PREPARE stmt FROM @update_query_to_usd;
            EXECUTE stmt USING @reciprocal_rate, @curr_date;
            DEALLOCATE PREPARE stmt;

            -- Increment curr_date for the next iteration
            SET curr_date = DATE_ADD(@curr_date, INTERVAL 1 DAY);
        END WHILE;

    END LOOP;

    CLOSE cur;
END;
//
DELIMITER ;

-- CALL req05_populate_conversion_data();