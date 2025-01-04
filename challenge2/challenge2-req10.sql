DROP PROCEDURE IF EXISTS req10_fix_minor_consumptions;

DELIMITER //

CREATE PROCEDURE req10_fix_minor_consumptions()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE festivalgoer_id INT;
    DECLARE product_id INT;

    -- identifies the alcohol consumption of minors
    DECLARE cur_bar CURSOR FOR
        SELECT fc.id_festivalgoer, fc.id_product
        FROM festivalgoer_consumes fc
        JOIN product p ON fc.id_product = p.id_product
        JOIN beverage b ON p.id_product = b.id_beverage
        JOIN festivalgoer fg ON fc.id_festivalgoer = fg.id_festivalgoer
        JOIN person per ON fg.id_festivalgoer = per.id_person
        WHERE b.is_alcoholic = 1
        AND per.birth_date > DATE_SUB(CURDATE(), INTERVAL 18 YEAR);  -- Minors under 18

    -- identifies minors who have purchased a beer
    DECLARE cur_beerman CURSOR FOR
        SELECT bs.id_festivalgoer
        FROM beerman_sells bs
        JOIN festivalgoer fg ON bs.id_festivalgoer = fg.id_festivalgoer
        JOIN person p ON fg.id_festivalgoer = p.id_person
        WHERE p.birth_date > DATE_SUB(CURDATE(), INTERVAL 18 YEAR);  -- Minors under 18

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_bar;
    fix_bar_loop: LOOP
        FETCH cur_bar INTO festivalgoer_id, product_id;
        IF done THEN
            LEAVE fix_bar_loop;
        END IF;

        -- assign to festivalgoer 27582
        UPDATE festivalgoer_consumes
        SET id_festivalgoer = 27582
        WHERE id_festivalgoer = festivalgoer_id AND id_product = product_id;
    END LOOP fix_bar_loop;
    CLOSE cur_bar;

    -- Reset done flag for the next cursor
    SET done = FALSE;

    OPEN cur_beerman;
    fix_beerman_loop: LOOP
        FETCH cur_beerman INTO festivalgoer_id;
        IF done THEN
            LEAVE fix_beerman_loop;
        END IF;

        -- assign to festivalgoer 998192
        UPDATE beerman_sells
        SET id_festivalgoer = 998192
        WHERE id_festivalgoer = festivalgoer_id;
    END LOOP fix_beerman_loop;
    CLOSE cur_beerman;

END //

DELIMITER ;

-- We could not implement it due to lost connection to the server
-- CALL req10_fix_minor_consumptions();
