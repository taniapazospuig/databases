DROP TABLE IF EXISTS SALE;
DROP TABLE IF EXISTS TICKET_SELLER;
DROP TABLE IF EXISTS TICKET;
DROP TABLE IF EXISTS GAME;
DROP TABLE IF EXISTS SEATS;
DROP TABLE IF EXISTS ZONE;
DROP TABLE IF EXISTS SECURITY_STAFF;
DROP TABLE IF EXISTS STADIUM;
DROP TABLE IF EXISTS CLEANING_STAFF;
DROP TABLE IF EXISTS BARTENDER;
DROP TABLE IF EXISTS MASCOT;
DROP TABLE IF EXISTS STAFF;
DROP TABLE IF EXISTS DRAFT_PROCESS;
DROP TABLE IF EXISTS DRAFT_LIST;
DROP TABLE IF EXISTS PLAYER_FRANCHISE;
DROP TABLE IF EXISTS FRANCHISE_REGULAR_SEASON;
DROP TABLE IF EXISTS REGULAR_SEASON;
DROP TABLE IF EXISTS FRANCHISE_HEAD_COACH;
DROP TABLE IF EXISTS NATIONAL_HEAD_COACH;
DROP TABLE IF EXISTS HEAD_COACH;
DROP TABLE IF EXISTS ASSISTANT_COACH;
DROP TABLE IF EXISTS COACH;
DROP TABLE IF EXISTS FRANCHISE;
DROP TABLE IF EXISTS WESTERN_CONFERENCE;
DROP TABLE IF EXISTS EASTERN_CONFERENCE;
DROP TABLE IF EXISTS CONFERENCE;
DROP TABLE IF EXISTS PLAYER_NATIONAL_TEAM;
DROP TABLE IF EXISTS NATIONAL_TEAM;
DROP TABLE IF EXISTS PLAYER;

CREATE TABLE IF NOT EXISTS PLAYER (
	id_card INT UNSIGNED NOT NULL PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    nationality VARCHAR(100),
    gender ENUM ('M', 'F', 'O') NOT NULL,
    age TINYINT UNSIGNED,
    year_pro YEAR,
    university_from VARCHAR(100),
    nba_championships TINYINT UNSIGNED
);

CREATE TABLE IF NOT EXISTS NATIONAL_TEAM (
	country VARCHAR(100) NOT NULL,
    year_roster_selection YEAR NOT NULL,
    PRIMARY KEY (country, year_roster_selection)
);

CREATE TABLE IF NOT EXISTS PLAYER_NATIONAL_TEAM (
    player_id_card INT UNSIGNED NOT NULL,
    national_team_country VARCHAR(100) NOT NULL,
    national_year_roster YEAR NOT NULL,
    PRIMARY KEY (player_id_card, national_team_country, national_year_roster),
    FOREIGN KEY (player_id_card) REFERENCES PLAYER(id_card),
    FOREIGN KEY (national_team_country, national_year_roster) REFERENCES NATIONAL_TEAM(country, year_roster_selection)
);

CREATE TABLE IF NOT EXISTS CONFERENCE (
    name VARCHAR(100) NOT NULL PRIMARY KEY,
    location VARCHAR(100)
);     

CREATE TABLE IF NOT EXISTS EASTERN_CONFERENCE (
    name_eastern VARCHAR(100) NOT NULL,
    FOREIGN KEY (name_eastern) REFERENCES CONFERENCE(name),
    PRIMARY KEY (name_eastern)
); 
  
CREATE TABLE IF NOT EXISTS WESTERN_CONFERENCE (
    name_western VARCHAR(100) NOT NULL,
    FOREIGN KEY (name_western) REFERENCES CONFERENCE(name),
    PRIMARY KEY (name_western)
);   

CREATE TABLE IF NOT EXISTS FRANCHISE (
	name VARCHAR(100) NOT NULL PRIMARY KEY,
    city VARCHAR(100),
    anual_budget DECIMAL(12,2),
    championship_rings TINYINT UNSIGNED DEFAULT 0,
    name_conference VARCHAR(100),
    FOREIGN KEY (name_conference) REFERENCES CONFERENCE(name)
);

CREATE TABLE IF NOT EXISTS COACH (
	id_card INT UNSIGNED NOT NULL PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    gender ENUM ('M', 'F', 'O') NOT NULL,
    age TINYINT UNSIGNED,
    nationality VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS ASSISTANT_COACH (
	id_card_assistant INT UNSIGNED NOT NULL,
    speciality VARCHAR(100),
    franchise_name VARCHAR(100),
    id_card_boss INT UNSIGNED,
    FOREIGN KEY (id_card_assistant) REFERENCES COACH(id_card),
    FOREIGN KEY (id_card_boss) REFERENCES ASSISTANT_COACH(id_card_assistant),
    FOREIGN KEY (franchise_name) REFERENCES FRANCHISE(name),
    PRIMARY KEY (id_card_assistant)
);

CREATE TABLE IF NOT EXISTS HEAD_COACH (
	id_card_head INT UNSIGNED NOT NULL,
    percentile_victories DECIMAL(5,2),
    salary DECIMAL(12,2) UNSIGNED,
    FOREIGN KEY (id_card_head) REFERENCES COACH(id_card),
    PRIMARY KEY (id_card_head)
);

CREATE TABLE IF NOT EXISTS NATIONAL_HEAD_COACH (
    head_coach_id INT UNSIGNED NOT NULL,
    country_national VARCHAR(100) NOT NULL, 
    year_roster_national YEAR NOT NULL,
    FOREIGN KEY (head_coach_id) REFERENCES HEAD_COACH(id_card_head),
    FOREIGN KEY (country_national, year_roster_national) REFERENCES NATIONAL_TEAM(country, year_roster_selection),
    PRIMARY KEY (head_coach_id, country_national, year_roster_national)
);

CREATE TABLE IF NOT EXISTS FRANCHISE_HEAD_COACH (
	head_coach_id INT UNSIGNED NOT NULL,
    franchise_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (head_coach_id) REFERENCES HEAD_COACH(id_card_head),
    FOREIGN KEY (franchise_name) REFERENCES FRANCHISE(name),
    PRIMARY KEY (head_coach_id, franchise_name)
);   

CREATE TABLE IF NOT EXISTS REGULAR_SEASON (
	year YEAR NOT NULL PRIMARY KEY,
    date_start DATE,
    date_end DATE
);      

CREATE TABLE IF NOT EXISTS FRANCHISE_REGULAR_SEASON (
	franchise_name VARCHAR(100) NOT NULL,
	regular_season_year YEAR NOT NULL,
    does_win BIT(1) DEFAULT 0,
    FOREIGN KEY (franchise_name) REFERENCES FRANCHISE(name),
	FOREIGN KEY (regular_season_year) REFERENCES REGULAR_SEASON(year),
    PRIMARY KEY (franchise_name, regular_season_year)
);    

CREATE TABLE IF NOT EXISTS PLAYER_FRANCHISE (
    franchise_name VARCHAR(100) NOT NULL,
    player_id_card INT UNSIGNED NOT NULL,
    shirt_number TINYINT UNSIGNED,
    salary DECIMAL(12,2) UNSIGNED,
    date_signed_out DATE,
	date_signed_in DATE,
    FOREIGN KEY (franchise_name) REFERENCES FRANCHISE(name),
    FOREIGN KEY (player_id_card) REFERENCES PLAYER(id_card),
    PRIMARY KEY (franchise_name, player_id_card)
);   

CREATE TABLE IF NOT EXISTS DRAFT_LIST (
    year YEAR NOT NULL PRIMARY KEY
);   

CREATE TABLE IF NOT EXISTS DRAFT_PROCESS (
    year_draft_list YEAR NOT NULL,
    player_id_card INT UNSIGNED NOT NULL,
    franchise_name VARCHAR(100) NOT NULL,
    position_draft_list TINYINT UNSIGNED,
    FOREIGN KEY (year_draft_list) REFERENCES DRAFT_LIST(year),
	FOREIGN KEY (player_id_card) REFERENCES PLAYER(id_card),
	FOREIGN KEY (franchise_name) REFERENCES FRANCHISE(name),
    PRIMARY KEY (year_draft_list, player_id_card, franchise_name)
); 

CREATE TABLE IF NOT EXISTS STAFF (
	national_id INT UNSIGNED NOT NULL PRIMARY KEY,
	birthdate DATE,
	residence_city VARCHAR(100),
	bank_number VARCHAR(100),
    franchise_name VARCHAR(100),
	is_contract_full BIT(1) DEFAULT 0,
    FOREIGN KEY (franchise_name) REFERENCES FRANCHISE(name)
);

CREATE TABLE IF NOT EXISTS MASCOT (
	id_mascot INT UNSIGNED NOT NULL,
	animal_preference VARCHAR(100),
    franchise_name VARCHAR(100),
	FOREIGN KEY (id_mascot) REFERENCES STAFF(national_id),
    FOREIGN KEY (franchise_name) REFERENCES FRANCHISE(name),
	PRIMARY KEY (id_mascot)
);

CREATE TABLE IF NOT EXISTS BARTENDER (
	id_bartender INT UNSIGNED NOT NULL,
	has_alcohol_record BIT(1) DEFAULT 0,
	FOREIGN KEY (id_bartender) REFERENCES STAFF(national_id),
	PRIMARY KEY (id_bartender)
);

CREATE TABLE IF NOT EXISTS CLEANING_STAFF (
	id_cleaning INT UNSIGNED NOT NULL,
	run_speed DECIMAL(4,2) UNSIGNED,
	FOREIGN KEY (id_cleaning) REFERENCES STAFF(national_id),
	PRIMARY KEY (id_cleaning)
);

CREATE TABLE IF NOT EXISTS STADIUM (
	name VARCHAR(100) NOT NULL PRIMARY KEY,
	city VARCHAR(100),
	capacity INT UNSIGNED
);

CREATE TABLE IF NOT EXISTS SECURITY_STAFF (
	id_security INT UNSIGNED NOT NULL,
	has_gun_licence BIT(1) DEFAULT 1,
    stadium_name VARCHAR(100),
	FOREIGN KEY (id_security) REFERENCES STAFF(national_id),
    FOREIGN KEY (stadium_name) REFERENCES STADIUM(name),
	PRIMARY KEY (id_security)
);

CREATE TABLE IF NOT EXISTS ZONE (
	code INT UNSIGNED NOT NULL,
	name_stadium VARCHAR(100) NOT NULL,
	is_vip BIT(1) DEFAULT 0,
	FOREIGN KEY (name_stadium) REFERENCES STADIUM(name),
	PRIMARY KEY (code, name_stadium)
);

CREATE TABLE IF NOT EXISTS SEATS (
	color VARCHAR(100) NOT NULL,
	number INT UNSIGNED NOT NULL,
	zone_code INT UNSIGNED NOT NULL,
	name_stadium VARCHAR(100) NOT NULL,
	FOREIGN KEY (zone_code) REFERENCES ZONE(code),
	FOREIGN KEY (name_stadium) REFERENCES ZONE(name_stadium),
	PRIMARY KEY (color, number, zone_code, name_stadium)
);

CREATE TABLE IF NOT EXISTS GAME (
	game_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    stadium_name VARCHAR(100),
    local_franchise_name VARCHAR(100),
    visitor_franchise_name VARCHAR(100),
    mvp_id INT UNSIGNED,
	match_date DATE,
	local_points SMALLINT UNSIGNED NOT NULL,
	visitor_points SMALLINT UNSIGNED NOT NULL,
	FOREIGN KEY (stadium_name) REFERENCES STADIUM(name),
    FOREIGN KEY (local_franchise_name) REFERENCES FRANCHISE(name),
	FOREIGN KEY (visitor_franchise_name) REFERENCES FRANCHISE(name),
    FOREIGN KEY (mvp_id) REFERENCES PLAYER(id_card)
);


CREATE TABLE IF NOT EXISTS TICKET (
	id_number INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	price DECIMAL(8,2) UNSIGNED,
	seat_color VARCHAR(100),
	seat_number INT UNSIGNED,
	seat_zone_code INT UNSIGNED,
	seat_name_stadium VARCHAR(100),
	is_vip BIT(1) DEFAULT 0,
	FOREIGN KEY (seat_color, seat_number) REFERENCES SEATS(color, number),
    FOREIGN KEY (seat_zone_code) REFERENCES ZONE(code),
    FOREIGN KEY(seat_name_stadium) REFERENCES STADIUM(name)
);

CREATE TABLE IF NOT EXISTS TICKET_SELLER (
	id_ticket_seller INT UNSIGNED NOT NULL,
	has_gambling_record BIT(1) DEFAULT 0,
	FOREIGN KEY (id_ticket_seller) REFERENCES STAFF(national_id),
	PRIMARY KEY (id_ticket_seller)
);

CREATE TABLE IF NOT EXISTS SALE (
	ticket_id_number INT UNSIGNED NOT NULL,
	id_ticket_seller INT UNSIGNED NOT NULL,
	game_id INT UNSIGNED NOT NULL,
	sale_date DATE,
	FOREIGN KEY (ticket_id_number) REFERENCES TICKET(id_number),
	FOREIGN KEY (id_ticket_seller) REFERENCES TICKET_SELLER(id_ticket_seller),
	FOREIGN KEY (game_id) REFERENCES GAME(game_id),
	PRIMARY KEY (ticket_id_number, id_ticket_seller, game_id)
);