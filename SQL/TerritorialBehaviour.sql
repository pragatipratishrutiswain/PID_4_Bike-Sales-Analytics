-- 7. Sales and Returns per Territory
WITH rtrn AS(
	SELECT Region
    , COUNT(*) AS TotalReturns
    , SUM(ReturnQuantity) AS ReturnQuantity
    , ROUND(SUM(ReturnQuantity*ProductPrice), 2) as ReturnValue
	FROM returns r
	JOIN territories ON  TerritoryKey = SalesTerritoryKey
    JOIN products p ON r.ProductKey = p.ProductKey
    GROUP BY 1
),
ordr AS(
SELECT 
	Continent, 
    Country, 
    Region 
    , COUNT(*) AS TotalOrders
    , SUM(OrderQuantity) AS OrderQuantity
    , ROUND(SUM(OrderQuantity*ProductPrice), 2)as OrderValue
FROM overalsales o
JOIN territories t ON SalesTerritoryKey = TerritoryKey
JOIN products p ON o.ProductKey = p.ProductKey
GROUP BY 1,2,3
)
SELECT 
	Continent, Country, o.Region 
    , TotalOrders, IFNULL(TotalReturns, 0) AS TotalReturns 
    , OrderQuantity, IFNULL(ReturnQuantity, 0)AS ReturnQuantity
    , OrderValue, IFNULL(ReturnValue, 0) AS ReturnValue
    , IFNULL(ROUND(OrderValue - ReturnValue, 2), OrderValue) AS Rev_Gen			# ROI = **Revenue On Investment
    , ROUND(IFNULL(TotalReturns, 0) / TotalOrders, 3) AS Return_To_Order_Ratio
FROM ordr o
LEFT JOIN rtrn r on o.Region = r.Region
ORDER BY Rev_Gen DESC;
/*
INSIGHTS:
1. Generally the return rates are proportionate with the order rate (execpt for Germany having higher 
   orders and lower returns than France, which is a good sign.)
2. The avg Return_To_Order_Ratio ranges ~ 0.032, which may be assumed as a safe score.
3. Australia, Western parts of US and the United Kingdom have max ROI with Australia at the top. 
   These regions should be targetted for heavy investments, expand inventory and focus on seamless delivery and customer service.
4. Germany has decent ROI with less Return_To_Order_Ratio 0.030,
   should be aimed for brand expansion according to customer preference.
5. Southeast US is an emerging market, should be be aimed for strategeic investments with A/B testing.
6. France and Canada create high Revenue but also have high Return_To_Order_Ratio i.e., 0.36 and 0.34 respectively. 
   Need strong scrutinity on quality check, targetted marketing, customer preference and feedback on products. 
   Understand return behaviuor. Learn from Germany's supply chain management. Improve customer support.
7. Stick to only low-ticket items at the Northeast and the Central US given their low purchasing power. Strengthen marketing.
   But, regularly monitor the demand for future growth.
*/

-- Product Category wise sales per territory
WITH rtrn AS(
	SELECT 
		Region
        , YEAR(ReturnDate) AS Year
		, CategoryName
		, SUM(ReturnQuantity) AS ReturnQuantity
		, ROUND(SUM(ReturnQuantity*ProductPrice), 2) as ReturnValue
	FROM returns r
	JOIN territories ON  TerritoryKey = SalesTerritoryKey
    JOIN products p ON r.ProductKey = p.ProductKey
    JOIN product_subcategories s ON s.ProductSubcategoryKey = P.ProductSubcategoryKey
    JOIN product_categories c ON s.ProductCategoryKey = c.ProductCategoryKey
    GROUP BY 1, 2, 3
),
ordr AS(
	SELECT 
		Continent, 
		Country, 
		Region 
        , YEAR(OrderDate) as Year
		, CategoryName
		, SUM(OrderQuantity) AS OrderQuantity
		, ROUND(SUM(OrderQuantity*ProductPrice), 2)as OrderValue
	FROM overalsales o
	JOIN territories t ON SalesTerritoryKey = TerritoryKey
	JOIN products p ON o.ProductKey = p.ProductKey
    JOIN product_subcategories s ON s.ProductSubcategoryKey = P.ProductSubcategoryKey
    JOIN product_categories c ON s.ProductCategoryKey = c.ProductCategoryKey
	GROUP BY 1,2,3,4,5
)
SELECT 
	o.Year, Continent, Country, o.Region, o.CategoryName
    , OrderQuantity, IFNULL(ReturnQuantity, 0) AS ReturnQuantity
    , IFNULL(OrderQuantity - ReturnQuantity, OrderQuantity) AS FinalQuantity
    , OrderValue, IFNULL(ReturnValue, 0) AS ReturnValue
    , IFNULL(ROUND(OrderValue - ReturnValue, 2), OrderValue) AS Rev_Gen	 
FROM ordr o
LEFT JOIN rtrn r 
	on o.Region = r.Region and o.Year = r.Year and o.CategoryName = r.categoryName
ORDER BY Year, Rev_Gen DESC;

