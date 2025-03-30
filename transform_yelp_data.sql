-- Create or replace a user-defined function (UDF) called analyze_sentiment
-- This function takes a STRING input (text), analyzes its sentiment using TextBlob, and returns a STRING label: 'Positive', 'Neutral', or 'Negative'

CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING  -- Output will be one of: Positive, Neutral, or Negative
LANGUAGE PYTHON  -- The function is written in Python
RUNTIME_VERSION = '3.8'  -- Specifies the Python runtime version in Snowflake
PACKAGES = ('textblob')  -- External package used for sentiment analysis
HANDLER = 'sentiment_analyzer'  -- Entry point to the function
AS $$

from textblob import TextBlob  -- Import the TextBlob library

def sentiment_analyzer(text):
    analysis = TextBlob(text)  -- Perform sentiment analysis on the input text
    if analysis.sentiment.polarity > 0:
        return 'Positive'      -- If polarity > 0, return Positive
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'       -- If polarity == 0, return Neutral
    else:
        return 'Negative'      -- If polarity < 0, return Negative

$$;



CREATE OR REPLACE TABLE tbl_yelp_reviews AS 
SELECT  
  review_text:business_id::STRING       AS business_id,
  review_text:date::DATE                AS review_date,
  review_text:user_id::STRING           AS user_id,
  review_text:stars::NUMBER             AS review_stars,
  review_text:text::STRING              AS review_text,
  ANALYZE_SENTIMENT(review_text)        AS sentiments
FROM yelp_review;


CREATE OR REPLACE TABLE tbl_yelp_businesses AS 
SELECT  
  business_text:business_id::STRING     AS business_id,
  business_text:name::STRING            AS name,
  business_text:city::STRING            AS city,
  business_text:state::STRING           AS state,
  business_text:review_count::STRING    AS review_count,
  business_text:stars::NUMBER           AS stars,
  business_text:categories::STRING      AS categories
FROM yelp_business;


SELECT * FROM tbl_yelp_reviews LIMIT 50;
