-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;
drop table salesdata;

-- Create table
CREATE TABLE IF NOT EXISTS Salesdata(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL(12, 4),
    rating FLOAT
);

select * from walmartsales.Salesdata;
-- -----------------------------------------------------------------------------------------------------------------------
-- -------------------------------------Feature Engineering--------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------
-- Add the time_of_day column
SELECT time,
	   CASE
		  WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
          WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
	     ELSE "Evening"
       END AS time_of_day
FROM salesdata;

ALTER TABLE salesdata ADD COLUMN time_of_day VARCHAR(20);

UPDATE salesdata
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- Add day_name column
SELECT date, DAYNAME(date) 
FROM salesdata;

ALTER TABLE salesdata 
ADD COLUMN day_name VARCHAR(10);

UPDATE salesdata
SET day_name = DAYNAME(date);


-- Add month_name column
SELECT date, MONTHNAME(date) 
FROM salesdata;

ALTER TABLE salesdata 
ADD COLUMN month_name VARCHAR(10);

UPDATE salesdata
SET month_name = MONTHNAME(date);


-- ----------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------General Question------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------
-- 1. How many unique cities does the data have?
SELECT DISTINCT city 
FROM salesdata;

-- 2. In which city is each branch?
SELECT DISTINCT City, Branch 
FROM salesdata;

-- --------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------Product----------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------
-- 1. How many unique product lines does the data have?
SELECT DISTINCT Product_line 
FROM salesdata;

-- 2. What is the most common payment method?
SELECT payment,count(payment) as payment_count 
FROM salesdata
GROUP BY payment
ORDER BY payment_count desc
LIMIT 1;

-- 3. What is the most selling product line?
SELECT product_line,sum(quantity) as qty  
FROM salesdata
GROUP BY product_line
ORDER BY qty desc
LIMIT 1;

-- 4. What is the total revenue by month?
SELECT month_name as Month, sum(total) as total_revenue 
FROM salesdata
GROUP BY month_name
ORDER BY total_revenue;

-- 5. What month had the largest COGS?
SELECT month_name as Month,sum(cogs) as COGS 
FROM salesdata
GROUP BY month_name
ORDER BY COGS;

-- 6. What product line had the largest revenue?
select product_line,sum(total) as total_revenue 
FROM salesdata
GROUP BY product_line
ORDER BY total_revenue;

-- 7. What is the city with the largest revenue?
SELECT branch, city, sum(total) as total_revenue 
FROM salesdata
GROUP BY city,branch
ORDER BY total_revenue desc;

-- 8. What product line had the largest VAT?

SELECT product_line, avg(tax_pct) as total_VAT 
FROM salesdata
GROUP BY product_line
ORDER BY total_VAT desc;

-- 9. Fetch each product line and add a column to those product lines showing "Good", "Bad". 
-- Good if it’s greater than average sales
SELECT avg(quantity) 
FROM salesdata; 
 
-- avg(quantity)=5.5 so we need >6 in case

SELECT product_line,
       CASE
           WHEN avg(quantity) > 6 THEN 'GOOD'
           ELSE 'BAD'
		END AS remark
FROM salesdata
GROUP BY product_line;

-- 10. Which branch sold more products than average product sold?
SELECT branch, sum(quantity) as qty 
FROM salesdata
GROUP BY branch 
HAVING sum(quantity) > (SELECT AVG(quantity) FROM salesdata);

-- 11. What is the most common product line by gender?
SELECT gender,product_line, count(gender)as total_count 
FROM salesdata
GROUP BY gender,product_line
ORDER BY total_count DESC ;

-- 12. What is the average rating of each product line?
SELECT product_line, round(avg(rating),2) as avg_rating 
FROM salesdata
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ----------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------Sales-----------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------
-- 1. Number of sales made in each time of the day per weekday

SELECT time_of_day, COUNT(*) AS total_sales
FROM salesdata
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Evenings experience most sales, the stores are 
-- filled during the evening hours


-- 2. Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS total_revenue
FROM salesdata
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM salesdata
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- 4. Which customer type pays the most in VAT?
SELECT customer_type, AVG(tax_pct) AS total_tax
FROM salesdata
GROUP BY customer_type
ORDER BY total_tax;

-- -----------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------Customer------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------
-- 1. How many unique customer types does the data have?
SeLECT DISTINCT customer_type 
FROM salesdata;


-- 2. How many unique payment methods does the data have?
SELECT DISTINCT payment 
FROM salesdata;


-- 3. What is the most common customer type?
SELECT customer_type,count(*) as count 
FROM salesdata
GROUP BY customer_type
ORDER BY count DESC;


-- 4. Which customer type buys the most?
SELECT customer_type, count(*) 
FROM salesdata
GROUP BY customer_type;


-- 5. What is the gender of most of the customers?
SELECT gender, count(gender) as gender_cnt 
FROM salesdata
GROUP BY gender
ORDER BY gender_cnt DESC;


-- 6. What is the gender distribution per branch?
SELECT gender,COUNT(*) as gender_cnt
FROM salesdata
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- 7. Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) as avg_rating
FROM salesdata
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.

-- 8. Which time of the day do customers give most ratings per branch?
SELECT time_of_day, AVG(rating) as avg_rating
FROM salesdata
WHERE branch='C'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

-- 9. Which day of the week has the best avg ratings?

SELECT day_name, AVG(rating) AS avg_rating
FROM salesdata
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Mon, Tue and Friday are the top best days for good ratings


-- conclusion: In summary, while gender distribution and time of day may not significantly impact sales and ratings 
-- across branches, it's clear that certain branches outperform others in terms of ratings. Branches A and C are 
-- currently excelling, while Branch B could benefit from improvement efforts to enhance its ratings. 
-- Interestingly, Mondays, Tuesdays, and Fridays emerge as the top-performing days for achieving higher ratings. 
-- Moving forward, focusing on areas of improvement for Branch B and leveraging peak rating days across all 
-- branches could be key strategies for maximizing overall performance and customer satisfaction.

