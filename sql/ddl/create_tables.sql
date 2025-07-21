-- DDL for StreamPulse Database (MySQL Specific)

-- Drop tables if they exist to allow for clean re-creation
DROP TABLE IF EXISTS Streaming_Events;
DROP TABLE IF EXISTS Tracks;
DROP TABLE IF EXISTS Artists;


-- Create Artists Table
-- This table stores information about unique artists.
-- The 'artists' column in data.csv is a string of a list (e.g., "['Artist A', 'Artist B']").
-- For a pure SQL-only approach, we will extract distinct raw artist string representations
-- into this table. This means "['Artist A', 'Artist B']" will be treated as a single artist name
-- for simplicity, and individual artists from multi-artist tracks will not be normalized
-- into separate entries unless advanced, verbose MySQL string parsing is applied (which is complex).
CREATE TABLE Artists (
    artist_name VARCHAR(255) PRIMARY KEY -- Using the artist name string directly as PK
);

-- Create Tracks Table
-- This table stores detailed information about each music track from data.csv.
CREATE TABLE Tracks (
    track_id VARCHAR(255) PRIMARY KEY, -- Corresponds to 'id' in data.csv (Spotify track URI/ID)
    track_name VARCHAR(255) NOT NULL, -- Corresponds to 'name'
    duration_ms INT,                  -- Corresponds to 'duration_ms'
    popularity INT,                   -- Corresponds to 'popularity' (0-100)
    explicit BOOLEAN,                 -- Corresponds to 'explicit' (0 or 1, MySQL understands this)
    release_date DATE,                -- Corresponds to 'release_date'
    release_year INT,                 -- Corresponds to 'year'
    valence FLOAT,                    -- Corresponds to 'valence'
    acousticness FLOAT,               -- Corresponds to 'acousticness'
    danceability FLOAT,               -- Corresponds to 'danceability'
    energy FLOAT,                     -- Corresponds to 'energy'
    instrumentalness FLOAT,           -- Corresponds to 'instrumentalness'
    liveness FLOAT,                   -- Corresponds to 'liveness'
    loudness FLOAT,                   -- Corresponds to 'loudness'
    speechiness FLOAT,                -- Corresponds to 'speechiness'
    tempo FLOAT,                      -- Corresponds to 'tempo'
    key_code INT,                     -- Corresponds to 'key' (0-11, -1 for no key detected)
    mode_code INT                     -- Corresponds to 'mode' (0=minor, 1=major)
    -- We are not directly linking to the Artists table here because the 'artists' column
    -- in data.csv is a string list, making a clean FK relationship complex in pure SQL for this dataset.
);

-- Create Streaming_Events Table
-- This table stores individual streaming interactions from spotify_history.csv.
-- It links to the Tracks table via track_id.
-- Note: 'spotify_history.csv' does not contain a unique user_id. We'll use track_id to link to Tracks.
-- 'track_name', 'artist_name', 'album_name' are denormalized from the original spotify_history.csv
-- for ease of import.
CREATE TABLE Streaming_Events (
    event_id INT PRIMARY KEY AUTO_INCREMENT, -- Auto-incrementing primary key for each event
    track_id VARCHAR(255) NOT NULL,          -- Corresponds to 'spotify_track_uri'
    timestamp DATETIME NOT NULL,             -- Corresponds to 'ts'
    platform VARCHAR(100),                   -- Corresponds to 'platform'
    ms_played INT,                           -- Corresponds to 'ms_played'
    track_name VARCHAR(255),                 -- Corresponds to 'track_name'
    artist_name VARCHAR(255),                -- Corresponds to 'artist_name'
    album_name VARCHAR(255),                 -- Corresponds to 'album_name'
    reason_start VARCHAR(100),               -- Corresponds to 'reason_start'
    reason_end VARCHAR(100),                 -- Corresponds to 'reason_end'
    shuffle BOOLEAN,                         -- Corresponds to 'shuffle' (MySQL understands 'True'/'False' or 0/1)
    skipped BOOLEAN,                         -- Corresponds to 'skipped' (MySQL understands 'True'/'False' or 0/1)
    FOREIGN KEY (track_id) REFERENCES Tracks(track_id) -- Link to Tracks table
);