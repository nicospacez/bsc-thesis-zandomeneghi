SELECT pi.player_id, pi.first_name, pi.last_name, pi.current_club_name, c.name AS club_name
FROM Player_Info pi
JOIN Clubs c ON pi.current_club_id = c.club_id;


SELECT g.game_id, g.date, hc.name AS home_club_name, ac.name AS away_club_name, g.home_club_goals, g.away_club_goals
FROM Games g
JOIN Clubs hc ON g.home_club_id = hc.club_id
JOIN Clubs ac ON g.away_club_id = ac.club_id;


SELECT pa.appearance_id, pa.player_name, pa.goals, pa.assists, c.name AS club_name, g.date
FROM Player_Appearances pa
JOIN Clubs c ON pa.player_club_id = c.club_id
JOIN Games g ON pa.game_id = g.game_id
WHERE g.game_id = '2211607';


SELECT pmv.player_market_value_id, pi.first_name, pi.last_name, pmv.market_value_in_eur, c.name AS club_name, co.name AS competition_name
FROM Player_Market_Values pmv
JOIN Player_Info pi ON pmv.player_id = pi.player_id
JOIN Clubs c ON pmv.current_club_id = c.club_id
JOIN Competitions co ON pmv.player_club_domestic_competition_id = co.competition_id;


SELECT gs.club_id, c.name AS club_name, COUNT(gs.is_win) AS total_wins
FROM Game_Stats gs
JOIN Clubs c ON gs.club_id = c.club_id
WHERE gs.is_win = TRUE
GROUP BY gs.club_id, c.name
ORDER BY total_wins DESC;


SELECT 
    c.name AS club_name,
    g.season,
    COUNT(gs.is_win) AS wins
FROM 
    Games g
JOIN 
    Game_Stats gs ON g.game_id = gs.game_id
JOIN 
    Clubs c ON gs.club_id = c.club_id
JOIN 
    Competitions comp ON g.competition_id = comp.competition_id
WHERE 
    gs.is_win = TRUE
    AND g.season = '2023'
    AND comp.competition_code = 'laliga'
GROUP BY 
    c.name, g.season
ORDER BY 
    wins DESC;
	
	
SELECT 
    gs.club_id,
    c.name AS club_name,
    COUNT(gs.game_id) AS total_games_played,
    SUM(CASE WHEN gs.is_win = TRUE THEN 1 ELSE 0 END) AS total_wins,
    SUM(CASE WHEN gs.is_win = FALSE AND gs.opponent_goals >= gs.own_goals THEN 1 ELSE 0 END) AS total_losses,
    SUM(CASE WHEN gs.own_goals = gs.opponent_goals THEN 1 ELSE 0 END) AS total_draws,
    SUM(gs.own_goals) AS total_goals_scored,
    SUM(gs.opponent_goals) AS total_goals_conceded
FROM Game_Stats gs
JOIN Clubs c ON gs.club_id = c.club_id
GROUP BY gs.club_id, c.name
ORDER BY total_wins DESC;


SELECT 
    pa.player_id, 
    pi.first_name, 
    pi.last_name, 
    COUNT(pa.game_id) AS total_appearances
FROM Player_Appearances pa
JOIN Player_Info pi ON pa.player_id = pi.player_id
GROUP BY pa.player_id, pi.first_name, pi.last_name
ORDER BY total_appearances DESC;


WITH PlayerAppearancesPerClub AS (
    SELECT 
        pa.player_id, 
        pi.first_name, 
        pi.last_name, 
        pa.player_club_id AS club_id, 
        c.name AS club_name, 
        COUNT(pa.game_id) AS total_appearances
    FROM Player_Appearances pa
    JOIN Player_Info pi ON pa.player_id = pi.player_id
    JOIN Clubs c ON pa.player_club_id = c.club_id
    GROUP BY pa.player_id, pi.first_name, pi.last_name, pa.player_club_id, c.name
)
SELECT club_id, club_name, player_id, first_name, last_name, total_appearances
FROM (
    SELECT 
        club_id, 
        club_name, 
        player_id, 
        first_name, 
        last_name, 
        total_appearances, 
        ROW_NUMBER() OVER (PARTITION BY club_id ORDER BY total_appearances DESC) AS rank
    FROM PlayerAppearancesPerClub
) ranked
WHERE rank = 1;

WITH TeamWinsBySeason AS (
    SELECT 
        g.competition_id, 
        co.name AS competition_name, 
        g.season, 
        gs.club_id, 
        c.name AS club_name, 
        COUNT(gs.is_win) AS total_wins
    FROM Game_Stats gs
    JOIN Games g ON gs.game_id = g.game_id
    JOIN Clubs c ON gs.club_id = c.club_id
    JOIN Competitions co ON g.competition_id = co.competition_id
    WHERE gs.is_win = TRUE
    GROUP BY g.competition_id, co.name, g.season, gs.club_id, c.name
)
SELECT competition_id, competition_name, season, club_id, club_name, total_wins
FROM (
    SELECT 
        competition_id, 
        competition_name, 
        season, 
        club_id, 
        club_name, 
        total_wins, 
        ROW_NUMBER() OVER (PARTITION BY competition_id, season ORDER BY total_wins DESC) AS rank
    FROM TeamWinsBySeason
) ranked
WHERE rank = 1;


WITH TeamWinsBySeason AS (
    SELECT 
        g.season, 
        gs.club_id, 
        c.name AS club_name, 
        COUNT(gs.is_win) AS total_wins
    FROM Game_Stats gs
    JOIN Games g ON gs.game_id = g.game_id
    JOIN Clubs c ON gs.club_id = c.club_id
    WHERE gs.is_win = TRUE
    GROUP BY g.season, gs.club_id, c.name
)
SELECT season, club_id, club_name, total_wins
FROM (
    SELECT 
        season, 
        club_id, 
        club_name, 
        total_wins, 
        ROW_NUMBER() OVER (PARTITION BY season ORDER BY total_wins DESC) AS rank
    FROM TeamWinsBySeason
) ranked
WHERE rank = 1;

