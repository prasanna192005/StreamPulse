-- DML for StreamPulse Database (MySQL Specific)

-- Load Tracks data from data.csv
-- We map columns explicitly to match the table structure and handle data types.
-- The 'artists' column from data.csv is read into a dummy variable (@artists_dummy)
-- as we're not fully normalizing multiple artists per track in a SQL-only scenario.
LOAD DATA INFILE 'C:\Users\prasa\OneDrive\Desktop\StreamPulse\data\data.csv'
INTO TABLE Tracks
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS -- Skip the header row
(valence, @year, acousticness, @artists_dummy, danceability, duration_ms, energy, explicit, track_id, instrumentalness, key_code, liveness, loudness, mode_code, track_name, popularity, @release_date_str, speechiness, tempo)
SET
    release_year = @year,
    release_date = STR_TO_DATE(@release_date_str, '%Y-%m-%d'); -- Convert string date to DATE type

-- Load Artists data
-- This attempts to extract distinct artist names from the 'artists' column in data.csv.
-- It cleans up the list-like string format to get individual artist names.
-- It will insert each unique artist string encountered. If a track has multiple artists
-- like "['Artist A', 'Artist B']", this process aims to extract "Artist A" and "Artist B"
-- as separate entries, assuming comma-separation.
-- This approach is more complex for MySQL's string functions and might not perfectly handle
-- all edge cases of the list-string format (e.g., spaces after commas).
-- For perfect normalization, a pre-processing step (e.g., Python) is ideal.

-- Step 1: Create a temporary table to load the raw artists strings from data.csv
DROP TEMPORARY TABLE IF EXISTS Temp_Raw_Artists;
CREATE TEMPORARY TABLE Temp_Raw_Artists (
    raw_artists_string TEXT
);

LOAD DATA INFILE 'C:\Users\prasa\OneDrive\Desktop\StreamPulse\data\data.csv'
INTO TEMPORARY TABLE Temp_Raw_Artists
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @col1, @col2, @col3, raw_artists_string, @col5, @col6, @col7, @col8, @col9,
    @col10, @col11, @col12, @col13, @col14, @col15, @col16, @col17, @col18, @col19
);

-- Step 2: Insert distinct artist names into the Artists table by parsing the string.
-- This uses a numbers table to split the comma-separated artists.
-- It assumes a maximum of 5 artists per track for splitting. Adjust if more are expected.
INSERT IGNORE INTO Artists (artist_name)
SELECT DISTINCT TRIM(REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(T.raw_artists_string, ',', n.n), ',', -1), '[', ''), ']', ''), '''', '')) AS artist_name
FROM Temp_Raw_Artists T
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
) n
ON CHAR_LENGTH(T.raw_artists_string) - CHAR_LENGTH(REPLACE(T.raw_artists_string, ',', '')) >= n.n - 1
WHERE LENGTH(TRIM(REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(T.raw_artists_string, ',', n.n), ',', -1), '[', ''), ']', ''), '''', ''))) > 0;

-- Load Streaming Events data from spotify_history.csv
-- We map columns explicitly and handle boolean conversions from 'True'/'False' strings.
LOAD DATA INFILE 'C:\Users\prasa\OneDrive\Desktop\StreamPulse\data\spotify_history.csv'
INTO TABLE Streaming_Events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS -- Skip the header row
(track_id, @ts_str, platform, ms_played, track_name, artist_name, album_name, reason_start, reason_end, @shuffle_bool_str, @skipped_bool_str)
SET
    timestamp = STR_TO_DATE(@ts_str, '%Y-%m-%d %H:%i:%s'), -- Convert string datetime to DATETIME type
    shuffle = CASE WHEN @shuffle_bool_str = 'True' THEN TRUE ELSE FALSE END, -- Convert 'True'/'False' strings to BOOLEAN
    skipped = CASE WHEN @skipped_bool_str = 'True' THEN TRUE ELSE FALSE END; -- Convert 'True'/'False' strings to BOOLEAN