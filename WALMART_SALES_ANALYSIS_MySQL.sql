CREATE DATABASE IF NOT EXISTS SalesDataWalmart;

CREATE TABLE IF NOT EXISTS Sales(
    invoice_id varchar(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL DEFAULT 'Cash',
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT NOT NULL,
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT NOT NULL
);

-- ----------------------------------------------------------
-- ------------------ Feature Engineering -------------------

-- time_of_day

SELECT
     time,
     (CASE 
		WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING"
        WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "AFTERNOON"
        ELSE "EVENING"
	 END
     ) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
     CASE 
		WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING"
        WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "AFTERNOON"
        ELSE "EVENING"
	 END
);

-- day_name
SELECT 
	date,
    DAYNAME(date) AS day_name
FROM sales; 

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);   

UPDATE  sales
SET day_name = DAYNAME(date);

-- month_name

SELECT
     date,
     MONTHNAME(date)
FROM sales; 

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);
-- ----------------------------------------------------------

-- ----------------------------------------------------------
-- ----------------------- Generic --------------------------

-- How many unique cities and branches does walmart have?
SELECT 
    DISTINCT city,
    branch
FROM SALES;    

-- ----------------------------------------------------------
-- ------------------------- Product ------------------------

-- How many unique product lines does the data have?
SELECT 
    COUNT(DISTINCT product_line)
FROM sales;

-- What is the most common payment method?
SELECT payment_method, COUNT(payment_method) AS cnt 
FROM sales 
GROUP BY payment_method 
ORDER BY cnt DESC 
LIMIT 0, 1000;

-- What is the most selling product line?
SELECT product_line, COUNT(product_line) AS cnt  
FROM sales  
GROUP BY product_line 
ORDER BY cnt DESC  
LIMIT 0, 1000;

-- What is the total revenue by month?
SELECT 
     month_name AS month,
     SUM(total) AS total_revenue
FROM sales
GROUP BY month_name 
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT 
     month_name AS month,
     SUM(cogs) AS cogs 
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;  

-- What product line had the largest revenue?  
SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;
     
-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales


-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
