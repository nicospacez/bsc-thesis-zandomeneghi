DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

GRANT ALL ON SCHEMA public TO admin;
GRANT ALL ON SCHEMA public TO public;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: Competitions
CREATE TABLE Competitions (
    competition_id VARCHAR(50) PRIMARY KEY,  -- VARCHAR for primary key
    competition_code VARCHAR(50),
    name VARCHAR(255),
    sub_type VARCHAR(100),
    type VARCHAR(100),
    country_id INT,
    country_name VARCHAR(255),
    domestic_league_code VARCHAR(50),
    confederation VARCHAR(100),
    url VARCHAR(255),
    start_at DATE,
    end_at DATE
);

-- Table: Clubs
CREATE TABLE Clubs (
    club_id VARCHAR(50) PRIMARY KEY,  -- VARCHAR for primary key
    club_code VARCHAR(50),
    name VARCHAR(255),
    domestic_competition_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    total_market_value NUMERIC(15,2),
    squad_size INT,
    average_age NUMERIC(5,2),
    foreigners_number INT,
    foreigners_percentage NUMERIC(5,2),
    national_team_players INT,
    stadium_name VARCHAR(255),
    stadium_seats INT,
    net_transfer_record VARCHAR(50),
    coach_name VARCHAR(255),
    last_season INT,
    filename VARCHAR(255),
    url VARCHAR(255),
    FOREIGN KEY (domestic_competition_id) REFERENCES Competitions(competition_id)
);

-- Table: Player Info
CREATE TABLE Player_Info (
    player_id VARCHAR(50) PRIMARY KEY,  -- VARCHAR for primary key
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    name VARCHAR(255),
    last_season INT,
    current_club_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    player_code VARCHAR(50),
    country_of_birth VARCHAR(255),
    city_of_birth VARCHAR(255),
    country_of_citizenship VARCHAR(255),
    date_of_birth DATE,
    sub_position VARCHAR(100),
    position VARCHAR(100),
    foot VARCHAR(50),
    height_in_cm INT,
    weight INT,
    contract_expiration_date DATE,
    agent_name VARCHAR(255),
    image_url VARCHAR(255),
    url VARCHAR(255),
    current_club_domestic_competition_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    current_club_name VARCHAR(255),
    market_value_in_eur NUMERIC(15,2),
    highest_market_value_in_eur NUMERIC(15,2),
    overall_rating NUMERIC(5,2),
    potential NUMERIC(5,2),
    FOREIGN KEY (current_club_id) REFERENCES Clubs(club_id),
    FOREIGN KEY (current_club_domestic_competition_id) REFERENCES Competitions(competition_id)
);

-- Table: Games
CREATE TABLE Games (
    game_id VARCHAR(50) PRIMARY KEY,  -- VARCHAR for primary key
    competition_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    season VARCHAR(50),
    round VARCHAR(50),
    date DATE,
    home_club_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    away_club_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    home_club_goals INT,
    away_club_goals INT,
    home_club_position INT,
    away_club_position INT,
    home_club_manager_name VARCHAR(255),
    away_club_manager_name VARCHAR(255),
    stadium VARCHAR(255),
    attendance INT,
    referee VARCHAR(255),
    url VARCHAR(255),
    home_club_formation VARCHAR(50),
    away_club_formation VARCHAR(50),
    home_club_name VARCHAR(255),
    away_club_name VARCHAR(255),
    aggregate VARCHAR(255),
    competition_type VARCHAR(50),
    FOREIGN KEY (competition_id) REFERENCES Competitions(competition_id),
    FOREIGN KEY (home_club_id) REFERENCES Clubs(club_id),
    FOREIGN KEY (away_club_id) REFERENCES Clubs(club_id)
);

-- Table: Player Market Values
CREATE TABLE Player_Market_Values (
    player_market_value_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,  -- VARCHAR for primary key
    player_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    date DATE,
    market_value_in_eur NUMERIC(15,2),
    current_club_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    player_club_domestic_competition_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    FOREIGN KEY (player_id) REFERENCES Player_Info(player_id),
    FOREIGN KEY (current_club_id) REFERENCES Clubs(club_id),
    FOREIGN KEY (player_club_domestic_competition_id) REFERENCES Competitions(competition_id)
);

-- Table: Club Attributes
CREATE TABLE Club_Attributes (
    club_attributes_id VARCHAR(50) PRIMARY KEY,  -- VARCHAR for primary key
    club_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    buildUpPlaySpeed INT,
    buildUpPlaySpeedClass VARCHAR(50),
    buildUpPlayDribbling INT,
    buildUpPlayDribblingClass VARCHAR(50),
    buildUpPlayPassing INT,
    buildUpPlayPassingClass VARCHAR(50),
    buildUpPlayPositioningClass VARCHAR(50),
    chanceCreationPassing INT,
    chanceCreationPassingClass VARCHAR(50),
    chanceCreationCrossing INT,
    chanceCreationCrossingClass VARCHAR(50),
    chanceCreationShooting INT,
    chanceCreationShootingClass VARCHAR(50),
    chanceCreationPositioningClass VARCHAR(50),
    defencePressure INT,
    defencePressureClass VARCHAR(50),
    defenceAggression INT,
    defenceAggressionClass VARCHAR(50),
    defenceTeamWidth INT,
    defenceTeamWidthClass VARCHAR(50),
    defenceDefenderLineClass VARCHAR(50),
    FOREIGN KEY (club_id) REFERENCES Clubs(club_id)
);

-- Table: Player Appearances
CREATE TABLE Player_Appearances (
    appearance_id VARCHAR(50) PRIMARY KEY,  -- VARCHAR for primary key
    game_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    player_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    player_club_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    player_current_club_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    date DATE,
    player_name VARCHAR(255),
    competition_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    yellow_cards INT DEFAULT 0,
    red_cards INT DEFAULT 0,
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    minutes_played INT DEFAULT 0,
    FOREIGN KEY (game_id) REFERENCES Games(game_id),
    FOREIGN KEY (player_id) REFERENCES Player_Info(player_id),
    FOREIGN KEY (player_club_id) REFERENCES Clubs(club_id),
    FOREIGN KEY (player_current_club_id) REFERENCES Clubs(club_id),
    FOREIGN KEY (competition_id) REFERENCES Competitions(competition_id)
);

-- Table: Game Stats
CREATE TABLE Game_Stats (
    game_stats_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,  -- Automatically generate UUID
    game_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    club_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    own_goals INT DEFAULT 0,
    own_position INT,
    own_manager_name VARCHAR(255),
    opponent_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    opponent_goals INT DEFAULT 0,
    opponent_position INT,
    opponent_manager_name VARCHAR(255),
    hosting VARCHAR(50),
    is_win BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (game_id) REFERENCES Games(game_id),
    FOREIGN KEY (club_id) REFERENCES Clubs(club_id),
    FOREIGN KEY (opponent_id) REFERENCES Clubs(club_id)
);

-- Table: Game Events
CREATE TABLE Game_Events (
    game_event_id VARCHAR(50) PRIMARY KEY,  -- VARCHAR for primary key
    date DATE,
    game_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    minute INT,
    type VARCHAR(100),
    club_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    player_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    description TEXT,
    player_in_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    player_assist_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    FOREIGN KEY (game_id) REFERENCES Games(game_id),
    FOREIGN KEY (club_id) REFERENCES Clubs(club_id),
    FOREIGN KEY (player_id) REFERENCES Player_Info(player_id),
    FOREIGN KEY (player_in_id) REFERENCES Player_Info(player_id),
    FOREIGN KEY (player_assist_id) REFERENCES Player_Info(player_id)
);

-- Table: Game Lineups
CREATE TABLE Game_Lineups (
    game_lineups_id VARCHAR(50) PRIMARY KEY,  -- VARCHAR for primary key
    game_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    club_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    type VARCHAR(100),
    number INT,
    player_id VARCHAR(50) NOT NULL,  -- Changed to VARCHAR for foreign key consistency
    player_name VARCHAR(255),
    team_captain BOOLEAN DEFAULT FALSE,
    position VARCHAR(100),
    FOREIGN KEY (game_id) REFERENCES Games(game_id),
    FOREIGN KEY (club_id) REFERENCES Clubs(club_id),
    FOREIGN KEY (player_id) REFERENCES Player_Info(player_id)
);

-- Table: Betting
CREATE TABLE Betting (
    betting_id VARCHAR(50) PRIMARY KEY,  -- VARCHAR for primary key
    game_id VARCHAR(50),  -- Changed to VARCHAR for foreign key consistency
    B365H NUMERIC(5,2),
    B365D NUMERIC(5,2),
    B365A NUMERIC(5,2),
    BWH NUMERIC(5,2),
    BWD NUMERIC(5,2),
    BWA NUMERIC(5,2),
    IWH NUMERIC(5,2),
    IWD NUMERIC(5,2),
    IWA NUMERIC(5,2),
    LBH NUMERIC(5,2),
    LBD NUMERIC(5,2),
    LBA NUMERIC(5,2),
    PSH NUMERIC(5,2),
    PSD NUMERIC(5,2),
    PSA NUMERIC(5,2),
    WHH NUMERIC(5,2),
    WHD NUMERIC(5,2),
    WHA NUMERIC(5,2),
    SJH NUMERIC(5,2),
    SJD NUMERIC(5,2),
    SJA NUMERIC(5,2),
    VCH NUMERIC(5,2),
    VCD NUMERIC(5,2),
    VCA NUMERIC(5,2),
    GBH NUMERIC(5,2),
    GBD NUMERIC(5,2),
    GBA NUMERIC(5,2),
    BSH NUMERIC(5,2),
    BSD NUMERIC(5,2),
    BSA NUMERIC(5,2),
    FOREIGN KEY (game_id) REFERENCES Games(game_id)
);
