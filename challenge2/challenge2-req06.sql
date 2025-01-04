DROP EVENT IF EXISTS req06_schedule;

CREATE EVENT req06_schedule
ON SCHEDULE EVERY 1 DAY
STARTS '2024-11-26 20:08:00'
ENDS '2024-12-31 23:59:59'
DO
    CALL req05_populate_conversion_data();
