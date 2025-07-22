
-- Query 1: Top 10 Most Popular Tracks by Popularity Score (from Tracks table)
-- Identifies universally appealing content based on Spotify's inherent popularity metric.
SELECT
    T.track_name,
    T.popularity,
    T.release_year
FROM
    Tracks T
ORDER BY
    T.popularity DESC
LIMIT 10;

-- Query 2: Top 10 Most Played Tracks from Streaming Events
-- Utilizes the actual streaming history to find the most listened-to tracks.
SELECT
    SE.track_name,
    SE.artist_name, -- Denormalized artist name from spotify_history.csv
    COUNT(SE.event_id) AS total_plays
FROM
    Streaming_Events SE
WHERE
    SE.ms_played > 30000 -- Consider a play if more than 30 seconds (adjust threshold as needed)
GROUP BY
    SE.track_name, SE.artist_name
ORDER BY
    total_plays DESC
LIMIT 10;

-- Query 3: Top 10 Most Played Artists from Streaming Events
-- Identifies the artists driving the most listening activity.
SELECT
    SE.artist_name,
    COUNT(SE.event_id) AS total_plays
FROM
    Streaming_Events SE
WHERE
    SE.ms_played > 30000
GROUP BY
    SE.artist_name
ORDER BY
    total_plays DESC
LIMIT 10;

-- Query 4: Trends in Audio Features Over Time (by release_year)
-- Shows how musical characteristics (e.g., danceability, energy) have changed through the years.
SELECT
    release_year,
    AVG(danceability) AS avg_danceability,
    AVG(energy) AS avg_energy,
    AVG(valence) AS avg_valence,
    AVG(acousticness) AS avg_acousticness,
    AVG(instrumentalness) AS avg_instrumentalness,
    AVG(loudness) AS avg_loudness
FROM
    Tracks
WHERE
    release_year IS NOT NULL AND release_year >= 1950 -- Filter to modern era for more relevant trends
GROUP BY
    release_year
ORDER BY
    release_year ASC;

-- Query 5: Yearly Growth in Play Counts per Track (Using JOIN and Window Function)
-- Joins Tracks and Streaming_Events to analyze yearly play counts and uses LAG to show year-over-year growth for each track.
SELECT
    t.track_name,
    t.release_year,
    EXTRACT(YEAR FROM se.timestamp) AS play_year,
    COUNT(se.event_id) AS play_count,
    LAG(COUNT(se.event_id)) OVER (PARTITION BY t.track_name ORDER BY EXTRACT(YEAR FROM se.timestamp)) AS previous_year_play_count,
    COUNT(se.event_id) - COALESCE(LAG(COUNT(se.event_id)) OVER (PARTITION BY t.track_name ORDER BY EXTRACT(YEAR FROM se.timestamp)), 0) AS yoy_play_count_diff
FROM
    Tracks t
    JOIN Streaming_Events se ON t.track_name = se.track_name
GROUP BY
    t.track_name, t.release_year, play_year
ORDER BY
    t.track_name, play_year ASC;