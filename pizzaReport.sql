SELECT *
FROM dbo.pizza_sales;

-- Now, we start to calculate the KPIs required by the business manager.

--
-- 1. TOTAL REVENUE: The sum of the total price of all pizza orders.

SELECT SUM(total_price) AS [Total Revenue]
FROM dbo.pizza_sales;

-- We obtain the total revenue: 817860.05083847


--
-- 2. AVERAGE ORDER VALUE: The total price / Number of orders
-- We use the DISTINCT because there are repeated order_ids
-- because for example, for order 2, there were different pizzas
-- made for that order, so 2 repeats for all entries of that same order
-- So, as we only want to know the value of each different order, is that
-- why we use DISTINCT

SELECT (SUM(total_price)/COUNT(DISTINCT order_id)) AS [Average Order Value]
FROM dbo.pizza_sales;

-- 38.3072623343546 Is the average order value.

--
-- 3. TOTAL PIZZAS SOLD
SELECT SUM(quantity) AS [Pizza sales]
FROM dbo.pizza_sales;

-- There were sold 49574 pizzas in total


--
--4. TOTAL ORDERS
SELECT COUNT(DISTINCT order_id) AS [Total orders]
FROM dbo.pizza_sales;

-- There were 21350 orders

--
-- 5. AVERAGE PIZZAS PER ORDER
-- Calculated by dividing the total number of pizzas sold by the total number
-- of orders

-- We use CAST AS DECIMAL for obtaining 2 decimal digits.
-- Note: Dividing two float values with 2 decimal values doesn't
-- result in 2 decimal digit number, so that's why we need to use CAST
-- a third time again.

SELECT CAST(CAST(COUNT(pizza_id) AS DECIMAL(10,2))/
		CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2))
		AS [Average Pizzas per Order]
FROM dbo.pizza_sales;

-- We obtain the result: 2.2772833723653

--
-- CHARTS REQUIREMENT

--
-- 1. Daily Trends for Total Orders:

SELECT order_date, COUNT(DISTINCT order_id) AS [Total Orders by Date]
FROM dbo.pizza_sales
GROUP BY order_date
ORDER BY order_date ASC;

--
-- 2. Daily Trends by Day of The Week:

SELECT DATENAME(DW, order_date) AS [Order Day], COUNT(DISTINCT order_id) AS [Total Orders]
FROM dbo.pizza_sales
GROUP BY DATENAME(DW, order_date)
ORDER BY DATENAME(DW, order_date) ASC;

--
-- Monthly Trends for Total Orders:

SELECT DATENAME(MONTH, order_date) AS [Order Month], COUNT(DISTINCT order_id) AS [Total Orders]
FROM dbo.pizza_sales
GROUP BY DATENAME(MONTH, order_date)
-- Sorting from most to least order count:
ORDER BY COUNT(DISTINCT order_id) DESC;

--
-- 3. Pizza Sales BY CATEGORY:

-- We want to know what percentage of total revenue
-- each pizza category represents

SELECT pizza_category, SUM(total_price) AS [Total Sales], (SUM(total_price) * 100 / 
	(SELECT SUM(total_price) FROM pizza_sales WHERE MONTH(order_date) = 1)) AS [Percentage of Sales]
FROM pizza_sales
-- Filtering by date:
WHERE MONTH(order_date) = 1
-- Filtering for considering just January
-- Remember that the filter also must be applied inside the subqueries.
GROUP BY pizza_category;

--
-- 4. Percentage of Sales by Pizza Size
-- Using CAST function for showing only two decimal digits
SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10, 2)) AS [Total Sales], CAST(SUM(total_price) * 100 / 
	(SELECT SUM(total_price) FROM pizza_sales WHERE DATEPART(QUARTER, order_date) = 1) AS DECIMAL(10, 2)) AS PCT
FROM pizza_sales
-- FILTERING TO CONSIDER ONLY FIRST QUARTER OF YEAR ORDERS:
WHERE DATEPART(QUARTER, order_date) = 1
GROUP BY pizza_size
ORDER BY PCT DESC;

--
-- 5. TOP PIZZAS SOLD BY CATEGORY (THERE ARE JUST 4 CATEGORIES)
SELECT pizza_category, SUM(quantity) AS Pizzas_Sold_by_Category
FROM pizza_sales
GROUP BY pizza_category
ORDER BY Pizzas_Sold_by_Category DESC;


--
-- 6/7. TOP 5 BEST/WORST SELLERS BY REVENUE, TOTAL QUANTITY AND TOTAL ORDERS

-- TOP 5 BY REVENUE:
SELECT TOP(5) pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue DESC;

-- BOTTOM 5 BY REVENUE:
SELECT TOP(5) pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue ASC;

-- TOP 5 BY QUANTITY:
SELECT TOP(5) pizza_name, SUM(quantity) AS Pizzas_sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Pizzas_sold DESC;

-- BOTTOM 5 BY QUANTITY:
SELECT TOP(5) pizza_name, COUNT(quantity) AS Pizzas_sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Pizzas_sold ASC;

-- TOP 5 BY TOTAL ORDERS:
SELECT TOP(5) pizza_name, COUNT(order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders DESC;

-- BOTTOM 5 BY TOTAL ORDERS:
SELECT TOP(5) pizza_name, COUNT(order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders ASC;