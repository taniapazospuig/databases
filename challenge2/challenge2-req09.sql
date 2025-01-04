-- Insert lew sid's song in the database if it does not exist already
INSERT INTO song (title, version, written_by, duration, release_date, type_of_music, album)
SELECT 'Fried Rice', 1, 'Lew Sid', 215, '2023-11-01', 'Hip Hop', 'Japan'
WHERE NOT EXISTS (
    SELECT 1
    FROM song
    WHERE title = 'Fried Rice'
      AND version = 1
      AND written_by = 'Lew Sid'
      AND duration = 215
      AND release_date = '2023-11-01'
      AND type_of_music = 'Hip Hop'
      AND album = 'Japan'
);

DROP PROCEDURE IF EXISTS req09_insert_lew_song;

DELIMITER //

CREATE PROCEDURE req09_insert_lew_song()
BEGIN
    -- Insert "Fried Rice" for all shows that don't already have it
    INSERT INTO show_song (id_show, title, version, written_by, ordinality)
    SELECT DISTINCT 
        s.id_show,                        
        song.title,                       
        song.version,                     
        song.written_by,                  
        (SELECT COALESCE(MAX(ordinality), 0) + 1 -- Set ordinality as the maximum ordinality or 0 in case of now songs for that show + 1
         FROM show_song ss 
         WHERE ss.id_show = s.id_show)    
    FROM `show` s
    CROSS JOIN song                      
    LEFT JOIN show_song ss
        ON s.id_show = ss.id_show 
        AND ss.title = song.title 
        AND ss.version = song.version 
        AND ss.written_by = song.written_by
    WHERE song.title = 'Fried Rice'      
      AND song.written_by = 'Lew Sid' 
      AND ss.id_show IS NULL;            -- Ensure the song isn't already in the show
END;
//
DELIMITER ;

DROP EVENT IF EXISTS req09_event;

CREATE EVENT req09_event
ON SCHEDULE EVERY 1 DAY
STARTS '2024-11-26 20:08:00'
ENDS '2024-12-31 23:59:59'
DO
    CALL req09_insert_lew_song();

