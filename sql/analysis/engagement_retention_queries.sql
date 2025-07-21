-- Query 1: Tracks with Highest Content Stickiness (Lowest Skip Rate)
-- Measures engagement based on actual user skips in Streaming_Events.
-- A lower skip rate indicates higher content stickiness.
SELECT
    SE.track_name,
    SE.artist_name,
    COUNT(SE.event_id) AS total_events,
    SUM(CASE WHEN SE.skipped = TRUE THEN 1 ELSE 0 END) AS total_skips,
    (CAST(SUM(CASE WHEN SE.skipped = TRUE THEN 1 ELSE 0 END) AS DECIMAL(10,2)) * 100.0 / NULLIF(COUNT(SE.event_id), 0)) AS skip_rate_percentage
FROM
    Streaming_Events SE
GROUP BY
    SE.track_name, SE.artist_name
HAVING
    COUNT(SE.event_id) > 100 -- Only consider tracks with sufficient events for meaningful statistics
ORDER BY
    skip_rate_percentage ASC
LIMIT 10;

-- Query 2: Average Listen Duration by Platform
-- Provides insights into user engagement patterns across different streaming platforms or devices.
SELECT
    platform,
    AVG(ms_played) AS average_ms_played,
    AVG(ms_played) / 60000.0 AS average_minutes_played
FROM
    Streaming_Events
WHERE
    ms_played > 0 -- Exclude events with 0 ms played (e.g., quick interactions, errors)
GROUP BY
    platform
ORDER BY
    average_minutes_played DESC;

-- Query 3: Most Common Reasons for Track Ending
-- Helps understand user behavior like why tracks are skipped or ended.
SELECT
    reason_end,
    COUNT(event_id) AS total_occurrences
FROM
    Streaming_Events
WHERE
    reason_end IS NOT NULL AND reason_end != ''
GROUP BY
    reason_end
ORDER BY
    total_occurrences DESC
LIMIT 5;

-- Query 4: Impact of Shuffle Mode on Play Duration (Hypothetical)
-- Investigates if users listen longer when shuffle is off/on.
SELECT
    shuffle,
    AVG(ms_played) AS average_ms_played,
    AVG(ms_played) / 60000.0 AS average_minutes_played,
    COUNT(event_id) AS total_events
FROM
    Streaming_Events
WHERE
    ms_played > 0
GROUP BY
    shuffle;