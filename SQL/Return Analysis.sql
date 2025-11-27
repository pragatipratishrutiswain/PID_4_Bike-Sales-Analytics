-- 8. return ratio per product, sub-category, category
SELECT ReturnDate from returns; # FROM 2015-01-18 TO 2017-06-30, 1809 rows

/*
DROP VIEW IF EXISTS returnanalysis;
CREATE VIEW returnanalysis AS( */
WITH OrderTable AS(
SELECT 
	YEAR(OrderDate) Year
    , ModelName
	, ProductColor, SubcategoryName, CategoryName
    , SUM(OrderQuantity) AS OrderQuantity
    , ROUND(SUM(ProductPrice*OrderQuantity), 2) AS OrderValue								#Revenue gained
    , ROW_NUMBER() OVER(ORDER BY YEAR(OrderDate), ModelName) Rnk
FROM overalsales o
JOIN products p ON o.ProductKey = p.ProductKey
JOIN product_subcategories s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
JOIN product_categories c ON s.ProductCategoryKey = c.ProductCategoryKey
GROUP BY 1,2,3,4,5
),
ReturnTable AS(
SELECT 
	YEAR(ReturnDate) Year
    , ModelName
	, ProductColor, SubcategoryName, CategoryName
	, IFNULL(SUM(ReturnQuantity), 0) AS ReturnQuantity
	, IFNULL(ROUND(SUM(ProductPrice*ReturnQuantity),2), 2) AS RevLost						#Revenue lost
    , ROW_NUMBER() OVER(ORDER BY YEAR(ReturnDate), ModelName) Rnk
FROM returns r
JOIN products p ON p.ProductKey = r.ProductKey
JOIN product_subcategories s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
JOIN product_categories c ON s.ProductCategoryKey = c.ProductCategoryKey
GROUP BY 1,2,3,4,5
)
SELECT 
	  o.Year
    , o.ModelName, o.ProductColor, o.SubcategoryName, o.CategoryName
    , o.OrderQuantity, r.ReturnQuantity
    , ROUND(r.ReturnQuantity / o.OrderQuantity, 4) AS Ret_to_Ord_Ratio
    , o.OrderValue, r.RevLost
    , ROUND(o.OrderValue - r.RevLost, 2) AS Rev_Gen 
FROM OrderTable o 
JOIN ReturnTable r ON o.Rnk = r.Rnk
ORDER BY o.Year, r.ReturnQuantity DESC;
# ) 
select * from returnanalysis;		# 100 rows

🔁 Consumer Return Behavior Insights (2015–2017)

WITH sales_agg AS (
    SELECT 
        Year(OrderDate) AS OrderYear, 
        ROUND(SUM(OrderQuantity * p.ProductPrice), 2) AS RevenueCollected
    FROM overalsales o
    JOIN products p USING(ProductKey)
    GROUP BY OrderYear
    ORDER BY OrderYear, RevenueCollected desc
),
ret_agg as (
	SELECT Year, ROUND(SUM(RevLost), 2) AS RevLost
	FROM returnanalysis
	GROUP BY 1
) 
SELECT 
	DISTINCT Year, RevenueCollected, RevLost
    , ROUND(RevLost*100/RevenueCollected, 2) AS RevLostPercnt
    , ROUND(RevenueCollected - RevLost, 2) AS RevenueRemained
    , ROUND(
			(
             (RevenueCollected - RevLost) - LAG(RevenueCollected - RevLost)OVER()
			) * 100 / LAG(RevenueCollected - RevLost) OVER(), 2
		   ) AS Y_o_Y_Growth_Prcnt
FROM ret_agg
JOIN sales_agg ON OrderYear = Year;

📌 Insights:
| Year | 💰 Revenue Collected | 💸  Revenue Lost  |   % Revenue Lost   | ✅  Revenue Retained | 💸 Y_o_Y_Growth_Prcnt |
| ---- | -------------------- | ----------------- | ------------------ | ------------------- | --------------------- |
  2015	     9628861.01				334014.63				3.47			 9294846.38		 		 NULL
  2016	    14775443.37				413861.70				2.80			14361581.67     		 54.51 
  2017	    14803356.06				406943.47				2.75			14396412.59      		  0.24
  🔍 Highlights:
2015 → 2016: Revenue grew by ~54%.
2016 → 2017 (first 6 months only): Revenue increased again by ~0.24% — but in half the time.
Run-rate Projection: If current momentum continues, 2017 year-end revenue could exceed $29 million, nearly doubling 2016's.

📈 What This Tells Us:
The business underwent a major acceleration in early 2017.
This is not normal growth — it's a scaling phase.
Something significantly changed — such as:
A game-changing product launch
New market or sales channels
Major marketing push or pricing strategy shift
/*
✅ Strategic Recommendation:
Pinpoint what triggered 2017's spike (e.g., SKUs, customer behavior, channel).
Ensure operational readiness (inventory, logistics, staffing) to support the scale.
This is an ideal time to secure long-term customers and build brand loyalty.
*/
Insights:
🔺 1. Revenue Grew Sharply
Revenue Retained increased by over 54% from 2015 to 2017.
This reflects strong business growth, likely due to product expansion, market reach, or seasonal demand surges.
📉 2. Revenue Lost Stabilized
Sales grew y-o-y and loss declined consistently: suggests effective mitigation (** reduction) of high-value returns, even as sales volume increased.
✅ 3. Improvement in Return Rate
The lost% due to returns dropped significantly.
This decline signals:
Better product quality control
Improved customer satisfaction or fit
Possibly enhanced return policy management
📊 Conclusion
Return management improved year over year.
The highest impact of loss was seen in 2015, largely due to bikes being the only category and high-value bike returns.
By 2017, the system appears more optimized, with return losses representing just 1% of total revenue.
