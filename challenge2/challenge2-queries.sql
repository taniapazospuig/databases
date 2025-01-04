DROP VIEW IF EXISTS query_01;
DROP VIEW IF EXISTS query_02;
DROP VIEW IF EXISTS query_02_extra;
DROP VIEW IF EXISTS query_03;
DROP VIEW IF EXISTS query_04;
DROP VIEW IF EXISTS query_05;
DROP VIEW IF EXISTS query_05_extra;
DROP VIEW IF EXISTS query_06;
DROP VIEW IF EXISTS query_07;
DROP VIEW IF EXISTS query_07_extra;
DROP VIEW IF EXISTS query_08;
DROP VIEW IF EXISTS query_09;
DROP VIEW IF EXISTS query_10;
DROP VIEW IF EXISTS query_10_extra;
DROP VIEW IF EXISTS query_11;
DROP VIEW IF EXISTS query_12;
DROP VIEW IF EXISTS query_13;
DROP VIEW IF EXISTS query_13_extra;
DROP VIEW IF EXISTS query_14;
DROP VIEW IF EXISTS query_14_extra;
DROP VIEW IF EXISTS query_15;
DROP VIEW IF EXISTS query_16;
DROP VIEW IF EXISTS query_17;
DROP VIEW IF EXISTS query_18;
DROP VIEW IF EXISTS query_19;
DROP VIEW IF EXISTS query_20;

CREATE VIEW query_01 AS 
	SELECT p.name, p.description
    FROM food f
    JOIN product p
    ON f.id_food = p.id_product 
    WHERE f.is_spicy = FALSE  AND f.is_veggie_friendly = TRUE AND p.description LIKE '%rice%';
    
-- total: 1 row 
    
    
CREATE VIEW query_02 AS 
	SELECT 
		SUM(CASE WHEN is_armed= TRUE THEN 1 ELSE 0 END) AS armed_guards,
		SUM(CASE WHEN knows_martial_arts= TRUE THEN 1 ELSE 0 END) AS martial_guards
	FROM `security`;
    
-- total: 1 row


CREATE VIEW query_02_extra AS 
	SELECT 
		s.festival_name,
		SUM(CASE WHEN s.is_armed= TRUE THEN 1 ELSE 0 END) AS armed_guards,
		SUM(CASE WHEN s.knows_martial_arts= TRUE THEN 1 ELSE 0 END) AS martial_guards
	FROM `security` s
    INNER JOIN festival f ON s.festival_name = f.name
    GROUP BY s.festival_name;
    
-- total: 12 row


CREATE VIEW query_03 AS 
SELECT v.name AS ticket_vendor, t.type AS ticket_type
FROM ticket t
JOIN vendor v ON t.id_vendor = v.id_vendor
JOIN festivalgoer f ON f.id_festivalgoer = t.id_festivalgoer
JOIN person p ON p.id_person = f.id_festivalgoer
WHERE p.name = 'Jan' AND p.surname = 'Laporta' AND t.festival_name = 'Primavera Sound' AND t.festival_edition = 2018;

-- total: 1 row


CREATE VIEW query_04 AS 
	SELECT 
		name,
        COUNT(edition) AS edition_count
	FROM festival
    GROUP BY name
    ORDER BY edition_count DESC;
    
-- total: 12 rows 


CREATE VIEW query_05 AS 
	SELECT 
		festival_name,
        COUNT(*) AS total_tickets
	FROM ticket
    GROUP BY festival_name
    ORDER BY total_tickets DESC
    LIMIT 1;
	
-- total: 1 row 


CREATE VIEW query_05_extra AS 
	SELECT 
		festival_name,
        festival_edition,
        COUNT(*) AS total_tickets
	FROM ticket
    GROUP BY festival_name, festival_edition
    ORDER BY festival_name ASC, festival_edition ASC;
    
-- total: 54 rows 


CREATE VIEW query_06 AS 
	SELECT 
		prefered_instrument,
        COUNT(*) AS musician_count
	FROM artist
    GROUP BY prefered_instrument
    ORDER BY musician_count DESC;
    
-- total: 6 rows 


CREATE VIEW query_07 AS 
SELECT 
    s.id_staff,
    p.name,
    p.surname,
    p.nationality,
    p.birth_date,
    DATEDIFF(s.contract_expiration_date, s.hire_date) AS contract_duration_days 
FROM staff s
JOIN person p ON s.id_staff = p.id_person
WHERE DATEDIFF(s.contract_expiration_date, s.hire_date) < 730
ORDER BY contract_duration_days ASC;

-- total: 47 rows 


CREATE VIEW query_07_extra AS
SELECT 
    q7.id_staff,
    q7.name,
    q7.surname,
    q7.nationality,
    q7.birth_date,
    q7.contract_duration_days,
    CASE
        WHEN EXISTS (SELECT 1 FROM beerman b WHERE b.id_beerman = q7.id_staff) THEN 'beerman'
        WHEN EXISTS (SELECT 1 FROM bartender bt WHERE bt.id_bartender = q7.id_staff) THEN 'bartender'
        WHEN EXISTS (SELECT 1 FROM security sc WHERE sc.id_security = q7.id_staff) THEN 'security'
        WHEN EXISTS (SELECT 1 FROM community_manager cm WHERE cm.id_community_manager = q7.id_staff) THEN 'community_manager'
        ELSE 'unknown' -- Handle the case where id_staff does not correspond to one of the worker roles
    END AS worker_type
FROM query_07 q7;

-- SELECT COUNT(*) VIEW FROM query_07_extra;
-- total: 47 rows


CREATE VIEW query_08 AS 
SELECT 
    p.name,
    p.surname,
    p.nationality,
    p.birth_date,
    a.band_country
FROM person p
JOIN artist a ON p.id_person= a.id_artist
WHERE a.band_name = 'Coldplay' ;

-- total: 10 rows 


CREATE VIEW query_09 AS 
SELECT DISTINCT
	p.name, p.description
FROM beverage b
JOIN product p ON b.id_beverage= p.id_product
JOIN bar_product bp ON p.id_product= bp.id_product
JOIN product_provider_bar ppb ON bp.id_product = ppb.id_product
JOIN provider pr ON ppb.id_provider = pr.id_provider
WHERE b.is_alcoholic = FALSE AND pr.name = 'Spirits Source';

-- total: 5 rows 


CREATE VIEW query_10 AS 
SELECT DISTINCT
    p.name,
    p.surname,
    p.nationality,
    p.birth_date 
FROM festivalgoer_consumes fc
JOIN festivalgoer fg ON fc.id_festivalgoer = fg.id_festivalgoer
JOIN person p ON fg.id_festivalgoer = p.id_person
JOIN product pr ON fc.id_product = pr.id_product
JOIN beverage b ON pr.id_product = b.id_beverage
WHERE b.is_alcoholic = TRUE 
  AND p.birth_date > DATE_SUB(CURDATE(), INTERVAL 18 YEAR);

-- SELECT COUNT(*) VIEW FROM query_10;	
-- total: 2455 rows


CREATE VIEW query_10_extra AS 
SELECT DISTINCT
    p.name AS underage_name,
    p.surname AS underage_surname,
    p.nationality AS underage_nationality,
    p.birth_date AS underage_birth_date,
    f_friend.name AS friend_name,
    f_friend.surname AS friend_surname,
    f_friend.nationality AS friend_nationality,
    f_friend.birth_date AS friend_birth_date
FROM festivalgoer_consumes fc
JOIN festivalgoer fg ON fc.id_festivalgoer = fg.id_festivalgoer
JOIN person p ON fg.id_festivalgoer = p.id_person
JOIN product pr ON fc.id_product = pr.id_product
JOIN beverage b ON pr.id_product = b.id_beverage
LEFT JOIN festivalgoer_friends ff ON fg.id_festivalgoer = ff.id_festivalgoer
LEFT JOIN person f_friend ON ff.id_festivalgoer_friend = f_friend.id_person
WHERE b.is_alcoholic = TRUE 
  AND p.birth_date > DATE_SUB(CURDATE(), INTERVAL 18 YEAR);
  
-- SELECT COUNT(*) VIEW FROM query_10_extra;
-- total: 2731 rows


CREATE VIEW query_11 AS 
SELECT 
    bm.id_beerman,
    p.name,
    p.surname, 
    p.nationality, 
    p.birth_date,
    COUNT(bs.id_beerman_sells) AS beers_sold
FROM beerman bm
JOIN person p ON bm.id_beerman = p.id_person
JOIN beerman_sells bs ON bm.id_beerman = bs.id_beerman
JOIN `show` s ON bs.festival_name = s.festival_name
WHERE s.festival_name = 'Hellfest' AND s.band_name = 'The Beatles'
GROUP BY bm.id_beerman, p.name, p.surname, p.nationality, p.birth_date
ORDER BY beers_sold DESC
LIMIT 1;

-- total: 1 row 


CREATE VIEW query_12 AS 
SELECT DISTINCT 
	a.id_artist,
    p.name,
    p.surname,
    p.nationality,
    b.name AS band_name,
    b.country AS band_country
FROM artist a 
JOIN person p ON a.id_artist = p.id_person 
JOIN band b ON a.band_name=b.name AND a.band_country = b.country
JOIN band_collab bc ON b.name = bc.band_name AND  b.country = bc.band_country
WHERE bc.band_name != 'Ebri Knight' AND bc.collaborator_name = 'Ebri Knight' 
ORDER BY  bc.band_name ASC , band_country ASC;
 
-- total: 10 rows 


CREATE VIEW query_13 AS 
SELECT DISTINCT
	s.*
FROM song s
JOIN show_song ss ON s.title = ss.title
JOIN `show` sh On ss.id_show = sh.id_show 
JOIN artist a ON sh.band_name = a.band_name AND sh.band_country = a.band_country 
JOIN person p ON a.id_artist = p.id_person 
WHERE p.name = 'Cordie' AND p.surname= 'Paucek';

-- total: 48 rows 


CREATE VIEW query_13_extra AS 
SELECT p.name AS artist_name, p.surname AS artist_surname, SUM(s.duration) AS total_duration_seconds 
FROM song s 
JOIN show_song ss ON s.title = ss.title
JOIN `show` sh ON ss.id_show = sh.id_show 
JOIN artist a ON sh.band_name = a.band_name AND sh.band_country = a.band_country 
JOIN person p ON a.id_artist = p.id_person 
WHERE p.name = 'Cordie' AND p.surname = 'Paucek' ;

-- total: 1 row


CREATE VIEW query_14 AS
SELECT 
    s.id_staff,
    p.name,
    p.surname
FROM staff s
JOIN person p ON s.id_staff = p.id_person
LEFT JOIN bartender b ON s.id_staff = b.id_bartender
LEFT JOIN beerman bm ON s.id_staff = bm.id_beerman
LEFT JOIN `security` sec ON s.id_staff = sec.id_security
LEFT JOIN community_manager cm ON s.id_staff = cm.id_community_manager
WHERE (CASE WHEN b.id_bartender IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN bm.id_beerman IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN sec.id_security IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN cm.id_community_manager IS NOT NULL THEN 1 ELSE 0 END) > 1;

-- total: 0 rows


CREATE VIEW query_14_extra AS
SELECT 
    s.id_staff,
    p.name,
    p.surname,
    (CASE WHEN b.id_bartender IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN bm.id_beerman IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN sec.id_security IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN cm.id_community_manager IS NOT NULL THEN 1 ELSE 0 END) AS role_count -- Add the total number of roles
FROM staff s
JOIN person p ON s.id_staff = p.id_person
LEFT JOIN bartender b ON s.id_staff = b.id_bartender
LEFT JOIN beerman bm ON s.id_staff = bm.id_beerman
LEFT JOIN `security` sec ON s.id_staff = sec.id_security
LEFT JOIN community_manager cm ON s.id_staff = cm.id_community_manager
WHERE (CASE WHEN b.id_bartender IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN bm.id_beerman IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN sec.id_security IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN cm.id_community_manager IS NOT NULL THEN 1 ELSE 0 END) > 1;
       
-- total: 0 rows


CREATE VIEW query_15 AS
SELECT DISTINCT 
    p.name,
    p.surname,
    p.nationality,
    p.birth_date,
    s.hire_date, 
    s.contract_expiration_date,
    cm.id_community_manager
FROM community_manager cm
JOIN staff s ON cm.id_community_manager = s.id_staff
JOIN person p ON s.id_staff = p.id_person
JOIN cm_account_festival cmaf ON cmaf.id_community_manager = cm.id_community_manager
WHERE cmaf.festival_name = 'Primavera Sound' AND cmaf.festival_edition = 2023;

-- total: 6 rows 


CREATE VIEW query_16 AS 
SELECT 
    p.id_person,
    p.name,
    p.surname,
    p.nationality,
    p.birth_date
FROM festivalgoer fg
JOIN person p ON fg.id_festivalgoer = p.id_person
LEFT JOIN ticket t ON fg.id_festivalgoer = t.id_festivalgoer
WHERE t.id_ticket IS NULL
ORDER BY p.id_person ASC;

-- total: 53958 rows 


CREATE VIEW query_17 AS 
SELECT 
    fg.id_festivalgoer, 
    IFNULL(SUM(t.price),0) AS total_ticket_price,
    IFNULL(COUNT(bs.id_beerman_sells) * 3 ,0) AS total_beers_price,
    IFNULL(SUM(bp.unit_price),0) AS total_bar_spending,
	(IFNULL(SUM(t.price),0)+ IFNULL(COUNT(bs.id_beerman_sells)* 3 ,0) + IFNULL(SUM(bp.unit_price),0)) AS total_spendings
FROM festivalgoer fg
LEFT JOIN ticket t ON fg.id_festivalgoer = t.id_festivalgoer
LEFT JOIN beerman_sells bs ON fg.id_festivalgoer = bs.id_festivalgoer
LEFT JOIN festivalgoer_consumes fc ON fg.id_festivalgoer = fc.id_festivalgoer
LEFT JOIN bar_product bp ON fc.id_product = bp.id_product AND fc.id_bar = bp.id_bar
WHERE fg.id_festivalgoer = 27577;

-- total: 1 row 


CREATE VIEW query_18 AS 
SELECT * FROM band b
WHERE b.name IN (
	SELECT name
    FROM band
    GROUP BY name
    HAVING COUNT(*) >1
);

-- total: 69 rows 
-- SELECT COUNT(*) VIEW FROM query_18;	


CREATE VIEW query_19 AS 
SELECT
	p.name,
    p.surname,
    p.nationality,
    p.birth_date,
    ac.followers,
    ac.platform_name
FROM community_manager cm
JOIN cm_account_festival cmaf ON cm.id_community_manager= cmaf.id_community_manager
JOIN `account` ac ON cmaf.account_name = ac.account_name 
JOIN staff s ON cm.id_community_manager = s.id_staff
JOIN person p ON s.id_staff = p.id_person
WHERE cm.is_freelance= TRUE AND cmaf.festival_name='Creamfields' AND  ( 500000 <= ac.followers <= 700000)
ORDER BY cm.id_community_manager ASC;

-- SELECT COUNT(*) VIEW FROM query_19;	
-- total: 82 rows


CREATE VIEW query_20 AS
SELECT p.name, p.surname
FROM person p
JOIN festivalgoer f ON p.id_person = f.id_festivalgoer
WHERE NOT EXISTS (
    SELECT 1
    FROM festival fe
    WHERE fe.name = 'Primavera Sound'
      AND NOT EXISTS (
          SELECT 1
          FROM ticket t
          WHERE t.id_festivalgoer = f.id_festivalgoer
            AND t.festival_name = fe.name
            AND t.festival_edition = fe.edition
      )
);

-- total: 0 rows







