-- Step 1: Create a JSON file format for reuse
CREATE OR REPLACE FILE FORMAT json_format
  TYPE = JSON;

-- Step 2: Create a secure external stage (replace `my_s3_integration` with your actual integration)
CREATE OR REPLACE STAGE yelp_stage
  URL = 's3://chits-portfolio-projects/yelpbusinessreview/'
  STORAGE_INTEGRATION = my_s3_integration
  FILE_FORMAT = json_format;

-- Step 3: Create table for Yelp Review data
CREATE OR REPLACE TABLE yelp_review (
  review_text VARIANT
);

-- Step 4: Load Yelp Review data (match any JSON file in the folder)
COPY INTO yelp_review
FROM @yelp_stage
PATTERN = '.*review.*\.json'
FILE_FORMAT = json_format;

-- Step 5: Preview Yelp Review data
SELECT * FROM yelp_review LIMIT 20;

-- Step 6: Create table for Yelp Business data
CREATE OR REPLACE TABLE yelp_business (
  business_text VARIANT
);

-- Step 7: Load Yelp Business data (single known file)
COPY INTO yelp_business
FROM @yelp_stage/yelp_academic_dataset_business.json
FILE_FORMAT = json_format;

-- Step 8: Preview Yelp Business data
SELECT * FROM yelp_business LIMIT 20;
