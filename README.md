# 📊 Yelp Data Analytics Pipeline with Snowflake & Python

This project showcases an end-to-end data analytics pipeline for processing and analyzing Yelp review and business data using Python, Amazon S3, Snowflake, and a Python-based sentiment analysis function.

---

## 🔁 Project Flow

1. **Initial Data**: A 5 GB JSON file containing Yelp reviews (`yelp_academic_dataset_review.json`).
2. **Python Processing**: The large file is split into **10 smaller JSON files** using a Python script to enable parallel processing and smoother ingestion.
3. **Upload to S3**:
   - All 10 review JSON files are uploaded to an **Amazon S3 bucket**.
   - A separate **100 MB Yelp Business file** (`yelp_academic_dataset_business.json`) is also uploaded to the same bucket.
4. **Ingest into Snowflake**:
   - Data is loaded from S3 into Snowflake using external stages and JSON file formats.
   - Review and business files are stored in separate Snowflake tables (`yelp_review`, `yelp_business`).
5. **Transform Data**:
   - Data is extracted from `VARIANT` columns into structured tables:
     - `tbl_yelp_reviews`
     - `tbl_yelp_businesses`
   - A **Python UDF** (`analyze_sentiment`) is used to analyze the sentiment of each review.
6. **Data Analysis**:
   - A set of **10 SQL queries** is run to derive business insights from the structured and enriched data.

![hqdefault](https://github.com/user-attachments/assets/78f780ef-d5e6-4c49-8479-98d0941f5ff9)

---

## 🧰 Technologies Used

- **Python 3.8** (File splitting & Snowflake Python UDF)
- **Amazon S3** (Cloud storage)
- **Snowflake** (Data warehouse)
- **TextBlob** (Sentiment analysis)
- **Snowflake Python UDFs** (Custom functions)

---

## 📂 Files Included

- `load_yelp_data.sql` – Loads JSON files into Snowflake from S3  
- `transform_yelp_data.sql` – Extracts structured data from JSON `VARIANT` columns  
- `questions.sql` – Set of 10 business analysis queries  
- `yelp_files_split.ipynb` – Splits the 5 GB JSON file for parallel processing  
- `README.md` – Project overview and usage guide  

---

## 🧠 Python UDF: Sentiment Analysis

```sql
CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('textblob') 
HANDLER = 'sentiment_analyzer'
AS $$
from textblob import TextBlob
def sentiment_analyzer(text):
    analysis = TextBlob(text)
    if analysis.sentiment.polarity > 0:
        return 'Positive'
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;
```

---

## 📊 SQL Analysis Performed

- **Top 10 businesses with highest average rating**  
- **Cities with the most reviews**  
- **Average review stars by state**  
- **Most common business categories**  
- **Users with the most reviews**  
- **Percentage of positive reviews by city**  
- **Business categories with most negative feedback**  
- **Monthly trends in review volume**  
- **Sentiment distribution across states**  
- **Correlation between review count and average stars**

---

## 📄 License

This project is intended for educational and demonstration purposes only.
Please refer to Yelp’s Dataset Usage Policy for legal usage guidelines.

---

## 🙌 Acknowledgements

- Yelp Open Dataset
- TextBlob Documentation
- Snowflake Documentation





