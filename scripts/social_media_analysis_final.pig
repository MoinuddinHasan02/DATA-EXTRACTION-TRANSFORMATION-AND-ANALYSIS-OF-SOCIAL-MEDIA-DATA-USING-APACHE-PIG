-- 1. Extract: Load CSV data skipping header line
data = LOAD '/social_media_pig/input/social_media.csv' USING PigStorage(',') AS (
    post_id:int, user_id:int, platform:chararray, text:chararray,
    sentiment:chararray, hashtags:chararray, likes:int, comments:int,
    shares:int, country:chararray
);

-- Filter header and null rows
clean_data = FILTER data BY post_id IS NOT NULL;

-- 2. Transform: Derive Total Engagement metric
engagement = FOREACH clean_data GENERATE
    post_id, user_id, platform, sentiment, hashtags,
    likes, comments, shares, country,
    (likes + comments + shares) AS total_engagement;

-- 3. Analysis A: Platform Metrics
platform_group = GROUP engagement BY platform;
platform_analysis = FOREACH platform_group GENERATE
    group AS platform,
    COUNT(engagement) AS total_posts,
    SUM(engagement.likes) AS total_likes,
    AVG(engagement.likes) AS average_likes,
    SUM(engagement.total_engagement) AS total_engagement;

-- 4. Analysis B: Sentiment Breakdown
sentiment_group = GROUP engagement BY sentiment;
sentiment_analysis = FOREACH sentiment_group GENERATE
    group AS sentiment,
    COUNT(engagement) AS total_posts;

-- 5. Analysis C: Top 5 Posts by Engagement
ordered_posts = ORDER engagement BY total_engagement DESC;
top_5_posts = LIMIT ordered_posts 5;

-- 6. Store Output back to HDFS
STORE platform_analysis INTO '/social_media_pig/output/final_platform_analysis' USING PigStorage(',');
STORE sentiment_analysis INTO '/social_media_pig/output/final_sentiment_analysis' USING PigStorage(',');
STORE top_5_posts INTO '/social_media_pig/output/final_top_5' USING PigStorage(',');
