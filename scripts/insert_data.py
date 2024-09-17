import pandas as pd
import psycopg2
from psycopg2 import sql, errors
import numpy as np
import logging

logging.basicConfig(filename='debug.log', level=logging.ERROR, 
                    format='%(asctime)s - %(levelname)s - %(message)s')

def create_connection():
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="postgres",
            user="admin",
            password="admin"
        )
        return conn
    except Exception as e:
        logging.error(f"Error connecting to database: {e}")
        return None

def insert_data(conn, df, table_name, columns):
    if 'is_win' in df.columns:
        df['is_win'] = df['is_win'].apply(lambda x: True if x == 1 else (False if x == 0 else None))
        
    if 'team_captain' in df.columns:
        df['team_captain'] = df['team_captain'].apply(lambda x: True if x == 1 else (False if x == 0 else None))

    cursor = conn.cursor()
    insert_query = sql.SQL("""
        INSERT INTO {} ({}) VALUES ({})
    """).format(
        sql.Identifier(table_name),
        sql.SQL(', ').join(map(sql.Identifier, columns)),
        sql.SQL(', ').join(sql.Placeholder() * len(columns))
    )
    
    df = df.where(pd.notnull(df), None)
    df = df.replace({np.nan: None})
    df = df.where(pd.notna(df), None)

    successful_inserts = 0
    failed_inserts = 0
    
    for _, row in df.iterrows():
        try:
            cursor.execute(insert_query, tuple(row[col] for col in columns))
        except errors.ForeignKeyViolation as fk_error:
            logging.error(f"Foreign key violation in table {table_name}: {fk_error}. Skipping row: {row.to_dict()}")
            conn.rollback()
            failed_inserts += 1
        except Exception as e:
            logging.error(f"Error inserting row in table {table_name}: {e}. Skipping row: {row.to_dict()}")
            conn.rollback()
            failed_inserts += 1
        else:
            conn.commit()
            successful_inserts += 1

    cursor.close()
    
    return successful_inserts, failed_inserts

def main():
    csv_files = [
        # ('../data/competitions.csv', 'competitions', ['competition_id', 'competition_code', 'name', 'sub_type', 'type', 'country_id', 'country_name', 'domestic_league_code', 'confederation', 'url']),
        # ('../data/clubs.csv', 'clubs', ['club_id', 'club_code', 'name', 'domestic_competition_id', 'total_market_value', 'squad_size', 'average_age', 'foreigners_number', 'foreigners_percentage', 'national_team_players', 'stadium_name', 'stadium_seats', 'net_transfer_record', 'coach_name', 'last_season', 'filename', 'url']),
        # ('../data/players.csv', 'player_info', ['player_id', 'first_name', 'last_name', 'name', 'last_season', 'current_club_id', 'player_code', 'country_of_birth', 'city_of_birth', 'country_of_citizenship', 'date_of_birth', 'sub_position', 'position', 'foot', 'height_in_cm', 'contract_expiration_date', 'agent_name', 'image_url', 'url', 'current_club_domestic_competition_id', 'current_club_name', 'market_value_in_eur', 'highest_market_value_in_eur']),
        # ('../data/games.csv', 'games', ['game_id', 'competition_id', 'season', 'round', 'date', 'home_club_id', 'away_club_id', 'home_club_goals', 'away_club_goals', 'home_club_position', 'away_club_position', 'home_club_manager_name', 'away_club_manager_name', 'stadium', 'attendance', 'referee', 'url', 'home_club_formation', 'away_club_formation', 'home_club_name', 'away_club_name', 'aggregate', 'competition_type']),
        # ('../data/club_games.csv', 'game_stats', ['game_id', 'club_id', 'own_goals', 'own_position', 'own_manager_name', 'opponent_id', 'opponent_goals', 'opponent_position', 'opponent_manager_name', 'hosting', 'is_win']),
        # ('../data/game_lineups.csv', 'game_lineups', ['game_lineups_id', 'game_id', 'club_id', 'type', 'number', 'player_id', 'player_name', 'team_captain', 'position']),
        # ('../data/appearances.csv', 'player_appearances', ['appearance_id', 'game_id', 'player_id', 'player_club_id', 'player_current_club_id', 'date', 'player_name', 'competition_id', 'yellow_cards', 'red_cards', 'goals', 'assists', 'minutes_played']),
        # ('../data/game_events.csv', 'game_events', ['game_event_id', 'date', 'game_id', 'minute', 'type', 'club_id', 'player_id', 'description', 'player_in_id', 'player_assist_id']),
        ('../data/player_valuations.csv', 'player_market_values', ['player_id', 'date', 'market_value_in_eur', 'current_club_id', 'player_club_domestic_competition_id'])
    ]
    conn = create_connection()
    if conn:
        try:
            summary = {}
            
            for csv_file, table_name, columns in csv_files:
                df = pd.read_csv(csv_file)
                print(f"Inserting data into {table_name}...")
                
                success, failure = insert_data(conn, df, table_name, columns)
                summary[table_name] = {'success': success, 'failure': failure}
            
            print("Summary of insertions:")
            for table, stats in summary.items():
                print(f"Table {table} - Successful Inserts: {stats['success']}, Failed Inserts: {stats['failure']}")
        except Exception as e:
            logging.error(f"Error inserting data: {e}")
        finally:
            conn.close()

if __name__ == "__main__":
    main()
