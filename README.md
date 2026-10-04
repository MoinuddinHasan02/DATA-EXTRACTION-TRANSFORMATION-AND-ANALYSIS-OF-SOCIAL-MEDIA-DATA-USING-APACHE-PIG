# Data Extraction, Transformation, and Analysis of Social Media Data Using Apache Pig

An end-to-end Big Data ETL (Extract, Transform, Load) and analytics pipeline leveraging **Hadoop HDFS** and **Apache Pig** to process, transform, and analyze multi-platform social media interaction data.

---

## 📌 Project Overview

This project analyzes social media interaction datasets (across platforms such as Twitter, Instagram, and Facebook) using Apache Pig Latin and Hadoop Distributed File System (HDFS). The pipeline automates data ingestion, cleaning, feature engineering (deriving engagement metrics), aggregations across dimensions (platform, sentiment), and Top-N ranking.

---

## 🏗 Architecture & Pipeline Flow

```
[ Raw CSV Data ]
       │
       ▼ (hdfs dfs -put)
[ HDFS Distributed Storage: /social_media_pig/input/ ]
       │
       ▼ (Apache Pig Latin: LOAD & Schema Definition)
[ Schema Binding: post_id, platform, sentiment, likes, comments, shares... ]
       │
       ▼ (Transform: FILTER & Feature Engineering)
[ Derive total_engagement = likes + comments + shares ]
       │
       ├─────────────────────────┬─────────────────────────┐
       ▼                         ▼                         ▼
 [ GROUP BY platform ]    [ GROUP BY sentiment ]    [ ORDER BY total_engagement ]
 [ Aggregations:       ]   [ Aggregations:        ]   [ LIMIT 5: Top Viral Posts ]
 [ SUM, AVG, COUNT     ]   [ COUNT total_posts    ]
       │                         │                         │
       ▼ (STORE)                 ▼ (STORE)                 ▼ (STORE)
[ HDFS: platform_output ] [ HDFS: sentiment_output ] [ HDFS: top_5_output ]
```

---

## 📂 Project Structure

```
├── data/
│   ├── social_media.csv                 # Sample dataset
│   ├── social_media_internet.csv        # Cleaned dataset (732 records)
│   └── social_media_raw_internet.csv    # Raw social media records
├── scripts/
│   ├── social_media_analysis_internet.pig  # Production Pig Latin ETL script
│   └── social_media_analysis_final.pig     # Pig Latin analysis script
├── output/
│   ├── internet_platform_analysis/         # Platform engagement statistics
│   ├── internet_sentiment_analysis/        # Sentiment frequency distribution
│   └── internet_top_5/                     # Top 5 most engaging posts
├── .gitignore
└── README.md
```

---

## ⚙️ Processing Stages

1. **Distributed Storage (HDFS):** Datasets are loaded into Hadoop's Distributed File System (`/social_media_pig/input/`).
2. **Schema Binding (`LOAD`):** Maps CSV columns into typed primitives (`int`, `chararray`).
3. **Data Cleaning & Filtering (`FILTER`):** Filters invalid rows and headers using `FILTER ... BY post_id IS NOT NULL`.
4. **Feature Engineering (`FOREACH ... GENERATE`):** Computes total engagement:
   $$\text{total\_engagement} = \text{likes} + \text{comments} + \text{shares}$$
5. **Group & Aggregate (`GROUP BY`, `COUNT`, `SUM`, `AVG`):**
   - Platform Performance: Total posts, total likes, average likes, total engagement per platform.
   - Sentiment Breakdown: Post count grouped by sentiment (`Positive`, `Negative`, `Neutral`).
6. **Top-N Ranking (`ORDER BY ... DESC`, `LIMIT 5`):** Ranks and retrieves the top 5 most engaging social media posts.
7. **Storage (`STORE`):** Emits partitioned CSV results back to HDFS storage.

---

## 🚀 Execution Guide

### Step 1: Start HDFS Services
```bash
start-dfs.sh
```

### Step 2: Upload Dataset to HDFS
```bash
hdfs dfs -mkdir -p /social_media_pig/input
hdfs dfs -put -f data/social_media_internet.csv /social_media_pig/input/
hdfs dfs -ls /social_media_pig/input/
```

### Step 3: Execute the Pig Latin Script
Run in local mode:
```bash
pig -x local scripts/social_media_analysis_internet.pig
```
*Or execute on a distributed Hadoop MapReduce cluster:*
```bash
pig scripts/social_media_analysis_internet.pig
```

### Step 4: Inspect Analytics Results

#### 1. Platform Performance Metrics:
```bash
hdfs dfs -cat /social_media_pig/output/internet_platform_analysis/part-*
```
**Schema:** `Platform, Total Posts, Total Likes, Average Likes, Total Engagement`
```csv
Twitter,243,10099,41.56,16590
Instagram,258,11633,45.09,19116
Facebook,231,9672,41.87,15871
```

#### 2. Sentiment Breakdown:
```bash
hdfs dfs -cat /social_media_pig/output/internet_sentiment_analysis/part-*
```
**Schema:** `Sentiment, Total Post Count`
```csv
Positive,258
Negative,105
Neutral,369
```

#### 3. Top 5 Most Engaging Posts:
```bash
hdfs dfs -cat /social_media_pig/output/internet_top_5/part-*
```
**Schema:** `post_id, user_id, platform, sentiment, hashtags, likes, comments, shares, country, total_engagement`
```csv
1335,808,Instagram,Neutral,#Thrill #CulturalCelebration,80,12,40,India,132
1345,816,Facebook,Neutral,#Motivation #FitnessGoals,80,12,40,Australia,132
1355,824,Twitter,Neutral,#Anticipation #AdventureAwaits,80,12,40,India,132
1368,521,Instagram,Neutral,#Elation #RareBookDiscovery,80,12,40,USA,132
1382,848,Instagram,Positive,#Wonder #StargazingAdventure,80,12,40,South Africa,132
```

---

## 🛠 Prerequisites

- **Hadoop**: 3.x+
- **Apache Pig**: 0.17+
- **Java**: OpenJDK 8 / 11
- **OS**: Linux / macOS
