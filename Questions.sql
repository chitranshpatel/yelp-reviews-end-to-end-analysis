-- 10 questions


-- Question 1-  Find number of businesses in each category

-- This query splits the 'categories' column (comma-delimited) into rows, 
-- then counts how many businesses fall into each distinct category.

WITH cte AS (
    SELECT 
        b.business_id,
        TRIM(cat.value) AS category
    FROM tbl_yelp_businesses b
         /* The LATERAL or CROSS APPLY depends on the SQL engine.
            For Postgres, you can do:
            FROM tbl_yelp_businesses b
                 CROSS JOIN LATERAL regexp_split_to_table(b.categories, ',') cat
         */
         LATERAL SPLIT_TO_TABLE(b.categories, ',') cat
)
SELECT 
    category,
    COUNT(*) AS no_of_businesses
FROM cte
GROUP BY category
ORDER BY no_of_businesses DESC;


# Question 2 - Find the top 10 users who reviewed the most distinct businesses in the "Restaurants" category

-- Counts how many DISTINCT businesses (limited to the "Restaurants" category) 
-- each user has reviewed, then returns the top 10 users.

SELECT 
    r.user_id, 
    COUNT(DISTINCT r.business_id) AS total_distinct_businesses_reviewed
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
    ON r.business_id = b.business_id
WHERE b.categories LIKE '%Restaurants%'      -- Ensure we only look at "Restaurants" category
GROUP BY r.user_id
ORDER BY total_distinct_businesses_reviewed DESC
LIMIT 10;


-- Question 3 - Find the most popular categories based on the total number of reviews

-- Similar to Query #1, we split the 'categories' field into rows.
-- We then join to reviews and count how many total reviews each category has.

WITH cte AS (
    SELECT 
        b.business_id,
        TRIM(cat.value) AS category
    FROM tbl_yelp_businesses b
         LATERAL SPLIT_TO_TABLE(b.categories, ',') cat
)
SELECT 
    cte.category,
    COUNT(*) AS no_of_reviews
FROM cte
INNER JOIN tbl_yelp_reviews r 
    ON cte.business_id = r.business_id
GROUP BY cte.category
ORDER BY no_of_reviews DESC;

-- Question 4 - Find the top 3 most recent reviews for each business

-- We use a window function (ROW_NUMBER) partitioned by business, ordered by 
-- the most recent review_date. Then we pick the top 3 rows per business.

WITH cte AS (
    SELECT
        r.*,
        b.name,
        ROW_NUMBER() OVER (
            PARTITION BY r.business_id
            ORDER BY r.review_date DESC
        ) AS rn
    FROM tbl_yelp_reviews r
    INNER JOIN tbl_yelp_businesses b 
        ON r.business_id = b.business_id
)
SELECT *
FROM cte
WHERE rn <= 3;

-- Question 5 - Find the month with the highest number of reviews

-- Groups the reviews by the month (extracted from review_date),
-- then returns the month with the largest count.

SELECT 
    MONTH(review_date) AS review_month,     -- Dialect-specific function
    COUNT(*) AS no_of_reviews
FROM tbl_yelp_reviews
GROUP BY MONTH(review_date)
ORDER BY no_of_reviews DESC;

-- Question 6 - Find the percentage of 5-star reviews for each business

-- We calculate the total reviews per business and the count of 5-star reviews. 
-- Then compute the percentage of 5-star = (count_of_5_star / total_reviews) * 100.

SELECT 
    b.business_id,
    b.name,
    COUNT(*) AS total_reviews,
    SUM(CASE WHEN r.review_stars = 5 THEN 1 ELSE 0 END) AS star5_reviews,
    (SUM(CASE WHEN r.review_stars = 5 THEN 1 ELSE 0 END) * 100.0 
       / COUNT(*)) AS percent_5_star
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
    ON r.business_id = b.business_id
GROUP BY 
    b.business_id, 
    b.name;


-- Question 7 - Find the top 5 most-reviewed businesses in each city

-- First compute how many reviews each business has in each city,
-- then use a window function to rank them and pick the top 5 by total reviews.

WITH cte AS (
    SELECT 
        b.city,
        b.business_id,
        b.name,
        COUNT(*) AS total_reviews,
        ROW_NUMBER() OVER (
            PARTITION BY b.city
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM tbl_yelp_reviews r
    INNER JOIN tbl_yelp_businesses b 
        ON r.business_id = b.business_id
    GROUP BY 
        b.city, 
        b.business_id, 
        b.name
)
SELECT *
FROM cte
WHERE rn <= 5;

-- Question 8 -  Find the average rating of businesses that have at least 100 reviews

-- Computes the total number of reviews per business, 
-- then returns only those with >= 100 reviews, including the average star rating.

SELECT 
    b.business_id,
    b.name,
    COUNT(*) AS total_reviews,
    AVG(r.review_stars) AS avg_rating
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
    ON r.business_id = b.business_id
GROUP BY 
    b.business_id, 
    b.name
HAVING COUNT(*) >= 100
ORDER BY avg_rating DESC;   -- optional sort to see highest-rated first


-- Question 9 -  List the top 10 users who have written the most reviews, along with the businesses they reviewed

-- First find the top 10 users by total number of reviews. Then list (user_id, business_id) pairs.

WITH top_users AS (
    SELECT 
        r.user_id,
        COUNT(*) AS total_reviews
    FROM tbl_yelp_reviews r
    INNER JOIN tbl_yelp_businesses b 
        ON r.business_id = b.business_id
    GROUP BY r.user_id
    ORDER BY total_reviews DESC
    LIMIT 10
)
SELECT 
    r.user_id,
    r.business_id
FROM tbl_yelp_reviews r
WHERE r.user_id IN (SELECT user_id FROM top_users)
GROUP BY 
    r.user_id,
    r.business_id
ORDER BY r.user_id;


-- Question 10 - Find the top 10 businesses with the highest number of positive sentiment reviews

-- Filters the reviews where 'sentiments' = 'Positive',
-- then counts how many such reviews each business has. 
-- Returns top 10 by that count.

SELECT 
    r.business_id,
    b.name,
    COUNT(*) AS total_positive_reviews
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
    ON r.business_id = b.business_id
WHERE r.sentiments = 'Positive'
GROUP BY 
    r.business_id, 
    b.name
ORDER BY total_positive_reviews DESC
LIMIT 10;
 


