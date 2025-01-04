DROP FUNCTION IF EXISTS req07_get_preferred_currency;

DELIMITER //

CREATE FUNCTION req07_get_preferred_currency(person_id INT)
RETURNS VARCHAR(3)
DETERMINISTIC
BEGIN
    DECLARE nation VARCHAR(64);

    
    SELECT nationality INTO nation
    FROM person
    WHERE id_person = person_id;
    
    IF nation IS NULL THEN 
		RETURN 0;
	END IF;

    
    RETURN CASE
        WHEN nation = 'United States of America' THEN 'USD'
        WHEN nation = 'Canada' THEN 'CAD'
        WHEN nation = 'United Kingdom' THEN 'GBP'
        WHEN nation = 'Japan' THEN 'JPY'
        WHEN nation IN (
            'Germany', 'France', 'Spain', 'Italy', 'Netherlands', 
            'Belgium', 'Portugal', 'Austria', 'Finland', 'Greece', 'Ireland', 'Luxembourg', 'Malta', 'Slovenia', 'Slovakia', 'Estonia', 'Cyprus', 'Latvia', 'Lithuania', 'Croatia'
        ) THEN 'EUR'
        ELSE NULL
    END;
END //

DELIMITER ;

-- SELECT req07_get_preferred_currency(28417);
-- solution: EUR