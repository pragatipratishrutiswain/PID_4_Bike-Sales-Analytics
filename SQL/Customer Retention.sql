	## CUSTOMER RETENTION RATE ##
-- ------------------------
-- Calculate the customer retention, churn, (Total customer, New customer, Repeat Customer)

select distinct customerkey from sales_2015; 	#2630
select distinct customerkey from sales_2016;	#9133
select distinct customerkey from sales_2017;	#10502
-- ----------------------------------------------------------

## COMPARISION BWTWEEN 2015 WITH 2016 AND 2017 ##

select distinct customerkey from sales_2015
where customerkey in (select distinct customerkey from sales_2016);				   # 1204
# INSIGHT: There were 1204/2630 customers i.e., 45.8% repurchased in 2016. 

select distinct customerkey from sales_2015
where CustomerKey in (select distinct customerkey from sales_2017); 			   # 1546
# INSIGHT: 1546/2630 customers i.e., 58.8% from 2015 repurchased in 2017.
-- 																					-----
																		# Sum = 	 2750
-- ----------------------------
-- No of bikes purchased in 2015 by the common customers from 2015 and 2016: 		# 1795 bike purchased by 1204 common customers
SELECT 
	'2015' as Year, 
    CategoryName, 
    SUM(OrderQuantity) AS CntOrderQuantity 
FROM sales_2015 s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
JOIN product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
WHERE customerkey IN (SELECT DISTINCT customerkey FROM sales_2016)
GROUP BY 1, 2 ORDER BY 3 DESC;

-- No of bikes purchased in 2015 by the common customers of 2015 1nd 2017: 			# 2352 bike purchased by 1546 common customers
SELECT '2015' as Year, CategoryName, SUM(OrderQuantity) AS CntOrderQuantity FROM sales_2015 s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
JOIN product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
WHERE customerkey IN (SELECT DISTINCT customerkey FROM sales_2017)
GROUP BY 1, 2 ORDER BY 3 DESC;				
-- --------------------------

-- No of customers common to all three sales tables
SELECT DISTINCT customerkey FROM sales_2015
    WHERE customerkey IN (SELECT customerkey FROM sales_2016)
      AND customerkey IN (SELECT customerkey FROM sales_2017); #298
#INSIGHT: Only 298/2630 customers from 2015 repurchased in both 2016 and 2017. That is retention rate = 3.7%

WITH cte AS(
	SELECT DISTINCT customerkey FROM sales_2015
    WHERE customerkey IN (SELECT customerkey FROM sales_2016)
      AND customerkey IN (SELECT customerkey FROM sales_2017)	#298 CUSTOMERS
),
cte2 AS (
    SELECT DISTINCT '2016' AS Year, customerkey, CategoryName, OrderQuantity FROM sales_2016 s
    
	JOIN products p ON s.ProductKey = p.ProductKey
	JOIN product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	JOIN product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
    WHERE customerkey IN (SELECT * FROM CTE)
    
    UNION ALL
    
    SELECT DISTINCT '2017' AS Year, customerkey, CategoryName, OrderQuantity FROM sales_2017 s
    
	JOIN products p ON s.ProductKey = p.ProductKey
	JOIN product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	JOIN product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
    WHERE customerkey IN (SELECT customerkey FROM CTE)
)
SELECT  Year, CategoryName, sum(OrderQuantity) AS CntOrderQuantity FROM cte2
GROUP BY 1, 2 ORDER BY 1, 3 DESC;

-- SELECT '2015' as Year, CategoryName, SUM(OrderQuantity) AS CntOrderQuantity FROM sales_2015 s
-- JOIN products p ON s.ProductKey = p.ProductKey
-- JOIN product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
-- JOIN product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
-- WHERE customerkey IN (SELECT DISTINCT customerkey FROM cte2)
-- GROUP BY 1, 2 ORDER BY 3 DESC;

Year	CategoryName	Cnt
2015	Bikes			449			# FROM 298 COMMON CUSTOMERS IN 2015, 2016 AND 2017
2016	Accessories		1850		
2017	Accessories		1604
2016	Clothing		458
2017	Clothing		575	
2016	Bikes			477			# Growth = 6.24% from 2015
2017	Bikes			461			# Growth = -3.34% from 2016

-- ---------------------------------- ------ 
WITH cte AS (
    SELECT DISTINCT customerkey FROM sales_2016
    UNION
    SELECT DISTINCT customerkey FROM sales_2017
)
SELECT DISTINCT customerkey FROM sales_2015
WHERE customerkey IN (SELECT * FROM CTE);		 # 2452 CUSTOMERS, CHURN RATE = 100*(2630-2452)/2630 = 6.77 %

# 93.23% customers from 2015 (i.e., 2452/2630) repurchased either in 2016 or in 2017.
# Insight: Retention Rate = 93.23%, CHURN RATE IS 6.77 %.
# This shows a surge in consumer demand for bikes and its related categories such as accessories and clothing.
# Bundle sell is a good stategy to increase sells.

WITH cte AS (
    SELECT DISTINCT '2016' AS Year, customerkey, CategoryName, OrderQuantity FROM sales_2016 s
    
	JOIN products p ON s.ProductKey = p.ProductKey
	JOIN product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	JOIN product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
    
    UNION ALL
    
    SELECT DISTINCT '2017' AS Year, customerkey, CategoryName, OrderQuantity FROM sales_2017 s
    
	JOIN products p ON s.ProductKey = p.ProductKey
	JOIN product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	JOIN product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
),
cte2 AS(
	SELECT DISTINCT customerkey FROM sales_2015
	WHERE customerkey IN (SELECT DISTINCT customerkey FROM cte)		 # 2452 COMMON CUSTOMERS, CHURN RATE 6.77 % FROM 2015
)
SELECT Year, CategoryName, SUM(OrderQuantity) AS CntOrderQuantity
FROM cte 
WHERE customerkey IN (SELECT customerkey FROM cte2)
GROUP BY 1, 2 ORDER BY 3 DESC;

Year	CategoryName	Cnt
2016	Accessories		7121		# from 1204 customers
2017	Accessories		8589		# from 1546 customers
2016	Clothing		1922
2017	Clothing		3037
2016	Bikes			1887		# compared to 1795 in 2015, growth = 5.13% from 2015
2017	Bikes			2442		# compared to 2352 in 2015, growth = 3.8% from 2015 
-- ---------------------------------------------
## COMPARISION BWTWEEN 2016 AND 2017 ##
-- -----------------------------------
WITH cte AS (
    SELECT DISTINCT '2017' AS Year, customerkey, CategoryName, OrderQuantity FROM sales_2017 s
    
	JOIN products p ON s.ProductKey = p.ProductKey
	JOIN product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	JOIN product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
),
cte2 AS(
	SELECT DISTINCT '2016' AS Year, customerkey, CategoryName, OrderQuantity FROM sales_2016 s
    
	JOIN products p ON s.ProductKey = p.ProductKey
	JOIN product_subcategories ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	JOIN product_categories pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
	WHERE customerkey IN (SELECT DISTINCT customerkey FROM cte)	
)
# SELECT DISTINCT customerkey FROM cte2;	# 2397 FROM 9133 Customers common between 2016 and 2017
# Insight: Retention rate = 26.25%, Churn rate = 73.75%
SELECT Year, CategoryName, SUM(OrderQuantity) AS CntOrderQuantity
FROM cte2
GROUP BY 1, 2
UNION ALL
SELECT Year, CategoryName, SUM(OrderQuantity) AS CntOrderQuantity
FROM cte
WHERE customerkey IN (SELECT customerkey FROM cte2)
GROUP BY 1, 2 
ORDER BY CntOrderQuantity DESC;

Year	CategoryName	CntOrderQuantity
2016	Accessories		8871			# FROM 2397 CUSTOMERS COMMON TO BOTH 2016 AND 2017
2017	Accessories		13888			# ~1.6X growth, growth = 56.6%
2016	Clothing		2494			
2017	Clothing		4588			# ~1.9X growth, growth = 83.96%
2016	Bikes			2418
2017	Bikes			2432			# Almost same, growth = 0.58%
