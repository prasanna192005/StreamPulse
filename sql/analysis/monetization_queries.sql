-- Query 1: Identification of Popular Explicit vs. Non-Explicit Tracks
-- Helps understand demand for different content types and can inform targeted advertising or content filtering strategies.

-- Top 10 Popular Explicit Tracks
SELECT
    track_name,
    (SELECT GROUP_CONCAT(artist_name SEPARATOR ', ') FROM Temp_Raw_Artists WHERE raw_artists_string LIKE CONCAT('%', REPLACE(REPLACE(REPLACE(track_name, '[', ''), ']', ''), '''', ''), '%')) AS artists, -- Attempt to link back to raw artist names for display
    popularity,
    release_year
FROM
    Tracks
WHERE
    explicit = TRUE
ORDER BY
    popularity DESC
LIMIT 10;

-- Top 10 Popular Non-Explicit Tracks
SELECT
    track_name,
    (SELECT GROUP_CONCAT(artist_name SEPARATOR ', ') FROM Temp_Raw_Artists WHERE raw_artists_string LIKE CONCAT('%', REPLACE(REPLACE(REPLACE(track_name, '[', ''), ']', ''), '''', ''), '%')) AS artists, -- Attempt to link back to raw artist names for display
    popularity,
    release_year
FROM
    Tracks
WHERE
    explicit = FALSE
ORDER BY
    popularity DESC
LIMIT 10;

-- Query 2: Tracks with High Popularity and High Danceability (Potential for Playlists/Events)
-- Identifies upbeat, popular tracks that could be leveraged for specific thematic playlists or events,
-- potentially driving engagement and premium feature usage.
SELECT
    track_name,
    (SELECT GROUP_CONCAT(artist_name SEPARATOR ', ') FROM Temp_Raw_Artists WHERE raw_artists_string LIKE CONCAT('%', REPLACE(REPLACE(REPLACE(track_name, '[', ''), ']', ''), '''', ''), '%')) AS artists,
    popularity,
    danceability,
    energy
FROM
    Tracks
WHERE
    popularity > 70 -- High popularity threshold (adjust as needed)
ORDER BY
    danceability DESC
LIMIT 10;

-- Query 3: Average Popularity of Tracks by Release Decade
-- Understand long-term appeal and evergreen content.
SELECT
    FLOOR(release_year / 10) * 10 AS release_decade,
    AVG(popularity) AS average_popularity,
    COUNT(track_id) AS total_tracks_in_decade
FROM
    Tracks
WHERE
    release_year IS NOT NULL AND release_year >= 1920
GROUP BY
    release_decade
ORDER BY
    release_decade ASC;

-- Query 4: Most Common Platforms for Streaming (Potential for Platform-Specific Ads/Partnerships)
-- Identifies dominant platforms where users engage, guiding marketing efforts.
SELECT
    platform,
    COUNT(event_id) AS total_events,
    SUM(ms_played) AS total_ms_played,
    SUM(ms_played) / 3600000.0 AS total_hours_played
FROM
    Streaming_Events
WHERE
    platform IS NOT NULL AND platform != ''
GROUP BY
    platform
ORDER BY
    total_events DESC
LIMIT 5;