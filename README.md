# StreamPulse: Data-Driven Music Streaming Analysis (MySQL - SQL Only) 🎵📊

## Project Overview 🚀

**StreamPulse** is a data-driven project that simulates and analyzes music streaming behavior, akin to platforms like Spotify. This project focuses on designing and implementing a robust relational database in MySQL using only SQL, ingesting raw streaming and music metadata, and then performing advanced analytical queries to uncover monetizable trends and actionable business insights.

The core objective is to demonstrate proficiency in:
* 🏗️ **Database Design & Normalization:** Creating an efficient and scalable schema.
* 📥 **Data Ingestion (ETL with SQL):** Loading large datasets directly into MySQL tables using `LOAD DATA INFILE`.
* 🧠 **Advanced SQL Querying:** Deriving meaningful insights for business intelligence.
* 📈 **Data Analysis:** Identifying patterns related to music popularity, user engagement, and content stickiness.

This iteration of StreamPulse highlights an **SQL-only approach**, emphasizing direct database capabilities for data handling and analysis, even with challenging data formats.

## Table of Contents 📚

1.  [Database Schema](#1-database-schema-)
2.  [Data Sources](#2-data-sources-)
3.  [Setup & Data Ingestion (MySQL)](#3-setup--data-ingestion-mysql-)
4.  [Key Analytical Queries & Insights](#4-key-analytical-queries--insights-)
5.  [Challenges & Learnings](#5-challenges--learnings-)
6.  [Skills Demonstrated](#6-skills-demonstrated-)


## 1. Database Schema 🗄️

The StreamPulse database is designed with the following key tables in MySQL:

* 🎤 **`Artists`**: Stores unique artist names extracted from the `data.csv`.
    * `artist_name` (VARCHAR, PK)
* 🎵 **`Tracks`**: Contains comprehensive metadata and audio features for individual songs.
    * `track_id` (VARCHAR, PK)
    * `track_name` (VARCHAR)
    * `duration_ms` (INT)
    * `popularity` (INT)
    * `explicit` (BOOLEAN)
    * `release_date` (DATE)
    * `release_year` (INT)
    * `valence` (FLOAT)
    * `acousticness` (FLOAT)
    * `danceability` (FLOAT)
    * `energy` (FLOAT)
    * `instrumentalness` (FLOAT)
    * `liveness` (FLOAT)
    * `loudness` (FLOAT)
    * `speechiness` (FLOAT)
    * `tempo` (FLOAT)
    * `key_code` (INT)
    * `mode_code` (INT)
* 📅 **`Streaming_Events`**: Logs individual user listening sessions and interactions.
    * `event_id` (INT, PK, AUTO_INCREMENT)
    * `track_id` (VARCHAR, FK to `Tracks`)
    * `timestamp` (DATETIME)
    * `platform` (VARCHAR)
    * `ms_played` (INT)
    * `track_name` (VARCHAR - *Denormalized*)
    * `artist_name` (VARCHAR - *Denormalized*)
    * `album_name` (VARCHAR - *Denormalized*)
    * `reason_start` (VARCHAR)
    * `reason_end` (VARCHAR)
    * `shuffle` (BOOLEAN)
    * `skipped` (BOOLEAN)

*Note on Schema Design:*
Given the SQL-only constraint, the `artists` column in `data.csv` (which is a string representation of a list) presented a challenge for full normalization (e.g., creating a `Track_Artists` junction table). The current schema adopts a pragmatic approach: `Artists` table stores distinct raw artist strings, and `Streaming_Events` retains denormalized artist and track names for direct ingestion. For a fully normalized, enterprise-scale solution, a preprocessing step (e.g., using Python) would be employed to parse and normalize such complex fields.

## 2. Data Sources 📂

The project utilizes two primary datasets:

* 📄 **`data.csv`**: Contains Spotify track metadata and audio features for over 170,000 songs.
* 📄 **`spotify_history.csv`**: Contains over 149,000 simulated Spotify streaming events, including track URI, timestamp, platform, and interaction details.

*(Note: Additional `data_by_*.csv` files were provided but are considered pre-aggregated analytical outputs and are not directly used for building the transactional database in this SQL-only approach. They represent the type of insights that can be derived from the raw data.)*

## 3. Setup & Data Ingestion (MySQL) ⚙️

Follow these steps to set up the database and load the data in your MySQL environment:

1.  🛠️ **Install MySQL:** Ensure you have a MySQL server installed and running.
2.  🗃️ **Create Database:** Connect to your MySQL server and create a new database for the project:
    ```sql
    CREATE DATABASE streampulse_db;
    USE streampulse_db;
    ```
3.  📥 **Place CSV Files:** Download the `data.csv` and `spotify_history.csv` files and place them in a directory accessible by your MySQL server. Update the file paths in `sql/dml/load_data.sql` to match their location.
    * ⚠️ **Important:** For `LOAD DATA INFILE` to work, ensure:
        * 🔑 Your MySQL user has the `FILE` privilege.
        * 📝 `local_infile` is enabled in your MySQL server configuration (`my.cnf` or `my.ini`). You can set it globally: `SET GLOBAL local_infile = 1;`
        * 💻 If running from a client, your client connection also needs `LOCAL_INFILE=1` (e.g., in `mysql` client command: `mysql --local-infile -u your_user -p`).
4.  🏗️ **Create Tables:** Execute the `create_tables.sql` script (found in `sql/ddl/`).
5.  🚚 **Load Data:** Execute the `load_data.sql` script (found in `sql/dml/`).
    * 🧩 **Note on Artists Loading:** The `load_data.sql` includes a complex, MySQL-specific SQL query to parse artist names from the list-like string in `data.csv`. This demonstrates SQL string manipulation, but for very large or more complex formats, Python preprocessing would be more robust.

## 4. Key Analytical Queries & Insights 🔍

The `sql/analysis/` directory contains various SQL queries designed to extract valuable business insights.

### 4.1 Popularity & Growth Insights (`popularity_growth_queries.sql`) 🌟

* 🏆 **Top 10 Most Popular Tracks (by popularity score):** Identifies universally appealing content.
* 🎧 **Top 10 Most Played Tracks & Artists (from streaming events):** Reveals actual user engagement with content.
* 📊 **Trends in Audio Features Over Time:** Shows how music characteristics (e.g., danceability, energy) have evolved annually, informing content strategy.
* 🪜 **Yearly Growth in Play Counts per Track (Advanced):** Uses JOINs and window functions (LAG) to analyze year-over-year growth in play counts for each track, providing deeper insight into trends and momentum.

### 4.2 Engagement & Retention Insights (`engagement_retention_queries.sql`) 🔄

* 🔥 **Tracks with Highest Content Stickiness (Lowest Skip Rate):** Pinpoints highly engaging songs that keep listeners hooked, crucial for recommendations.
* ⏱️ **Average Listen Duration by Platform:** Provides insights into user behavior on different devices/platforms, useful for platform-specific optimization.
* ❓ **Most Common Reasons for Track Ending:** Helps understand user drop-off points, allowing for UX improvements.
* 🔀 **Impact of Shuffle Mode on Play Duration:** Investigates user listening habits based on shuffle preference.
* 📅 **User Retention Analysis (Advanced):** Uses JOINs and window functions (RANK) to analyze user retention by unique streaming days and rank users by engagement.

### 4.3 Monetization Insights (`monetization_queries.sql`) 💰

* 🚫 **Popular Explicit vs. Non-Explicit Tracks:** Helps identify demand for different content types, useful for targeted advertising and content segmentation.
* 💃 **Tracks with High Popularity and High Danceability:** Identifies upbeat, popular content ideal for curated playlists or marketing campaigns.
* 🕰️ **Average Popularity of Tracks by Release Decade:** Understands long-term appeal and evergreen content for catalog management.
* 📱 **Most Common Platforms for Streaming:** Guides strategic partnerships or ad placement based on platform usage.
* 🏅 **Track Ranking by Artist Play Time (Advanced):** Uses JOINs and window functions (RANK) to rank tracks by total play time within each artist, supporting monetization and promotional strategies.

## 5. Challenges & Learnings 🧩

This project, specifically designed with a **SQL-only constraint**, brought valuable learnings:

* 🧵 **String Parsing Complexity:** Normalizing multi-valued string fields (like the `artists` list in `data.csv`) directly within SQL is significantly more complex and less efficient than using a scripting language like Python. This highlighted the importance of ETL tools for complex data transformations.
* 🕵️‍♂️ **Data Granularity:** The `spotify_history.csv` lacks a unique user ID, which limited direct analysis of individual user retention, lifetime value, or personalized recommendations. This emphasizes the critical need for robust user tracking in real-world streaming data.
* 🏎️ **Denormalization vs. Performance:** For the `Streaming_Events` table, denormalizing `track_name`, `artist_name`, `album_name` from the original CSV facilitated direct loading but means joins are still needed for accurate, normalized data (e.g., linking `track_id` to `Tracks` table for detailed features).

## 6. Skills Demonstrated 🏅

* 🐬 **SQL (MySQL):** Advanced querying, DDL, DML, temporary tables, string functions, aggregate functions, subqueries.
* 🗃️ **Database Management:** Schema design, normalization principles, data integrity.
* 📊 **Data Analysis:** Identifying trends, calculating key metrics (e.g., skip rates, average listen times), deriving business insights.
* 🧩 **Data Modeling:** Designing a relational schema from raw data.
* 🧠 **Problem Solving:** Adapting to data limitations (e.g., unparsed strings, missing IDs) with SQL-only solutions.
* 💡 **Business Intelligence:** Translating data findings into actionable recommendations for growth, retention, and revenue.

