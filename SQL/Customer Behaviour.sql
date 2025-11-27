-- CUSTOMER BEHAVIOR
-- -----------------
select count(distinct o.CustomerKey) from overalsales o
left join customers c on c.CustomerKey = o.CustomerKey
where o.CustomerKey in (select CustomerKey from customers);			
# 2032 unique customers are common to both sales and customers table (whose demography data is available in the customers table).

select count(distinct c.CustomerKey) from customers c
left join overalsales o on c.CustomerKey = o.CustomerKey
where c.CustomerKey not in (select CustomerKey from overalsales);	
# 30 unique customers are present in the customers table whose information is absent in the sales table.

select count(distinct o.CustomerKey) from overalsales o
left join customers c on c.CustomerKey = o.CustomerKey
where o.CustomerKey not in (select CustomerKey from customers);		
# 15348 unique customers are present in sales table whose database is not found in the customers table
---------------------------------------------------------------------------------------------------------

/*
DROP VIEW custval;
CREATE VIEW CustVal AS
SELECT 
    o.CustomerKey
    , TerritoryKey
    , CONCAT(FirstName, ' ', LastName) AS CustomerName
    , SUM(CASE WHEN c.CategoryName = 'Bikes' THEN OrderQuantity ELSE 0 END) AS CntBikes
    , SUM(CASE WHEN c.CategoryName = 'Accessories' THEN OrderQuantity ELSE 0 END) AS CntAccessories
    , SUM(CASE WHEN c.CategoryName = 'Clothing' THEN OrderQuantity ELSE 0 END) AS CntClothings
    , SUM(OrderQuantity) AS OrderQuantity
    , ROUND(SUM(OrderQuantity * p.ProductPrice),2) AS Revenue
    , ROUND(SUM(OrderQuantity * p.ProductPrice)*100/ SUM(SUM(OrderQuantity * p.ProductPrice)) over(), 2) AS PercntgRevenue
    , row_number() over(order by SUM(OrderQuantity * p.ProductPrice) DESC) as rnk
FROM overalsales o
JOIN products p USING(ProductKey)
JOIN product_subcategories s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
JOIN product_categories c ON s.ProductCategoryKey = c.ProductCategoryKey
LEFT JOIN customers USING(CustomerKey)
GROUP BY o.CustomerKey, CustomerName, TerritoryKey
ORDER BY Revenue DESC;
*/
Select * from custval;			#17416 unique customers

-- 1. top 5 customers
select * from territories
join custval on SalesTerritoryKey = TerritoryKey
where rnk < 6
order by rnk;


Insights:
Null, BONNIE NATH, ARIANA GRAY, CINDY PATEL, and MAURICE SHAN are the top 5 customers contributing to the 
0.26% (100,640.06 dollars ~ 1M dollar) of the 39.207M dollar revenue across all three years.
They all belong to the continent Europe, 4 ot 5 belong to France and one belongs to Germany.

-- 2. top 30% customers contributing 80% of revenue: segmentation by territory
select max(rnk) as Max_rnk, Max(cum_sum_PrcntgRevenue) as PercntgRevenue from 
	(select 
		rnk
		, sum(PercntgRevenue) over(order by rnk rows between unbounded preceding and current row) as cum_sum_PrcntgRevenue 
	 from custval) as tbl
where cum_sum_PrcntgRevenue <= 80.000; # Max_rnk = '5152'

-- Find how much % is 5152 of 17416 customers
select 100*5142/17416 as prct; # 29.5%

Insight:
The top 5152 out of 17416 i.e. ~30% customers contribute to 80% of the revenue.
Therefore its worth reviewing their demography and purchasing behavior.

with demg as(
	select 
		Continent, Country, Region, CustomerKey, 
        count(CustomerKey) over() TotalCustomers, PercntgRevenue, rnk
	from custval
	join territories on SalesTerritoryKey = TerritoryKey
	order by rnk
)
select 
	Country, Region, count(CustomerKey) as CustomerCnt,
    round(count(CustomerKey)*100/TotalCustomers, 2) as PercntCustomerCnt, 
    round(sum(PercntgRevenue), 2) as PercntgRevenue
from demg
where rnk <= 5152
group by Country, Region, TotalCustomers
order by CustomerCnt desc;

📌 Key Takeaways from the Customer’s Demography
Country			Region			Customers	% CustomerCnt	% Revenue Contribution
Australia		Australia			1530	8.79			26.19
United States	Southwest			1001	5.75			13.79
United States	Northwest			661		3.80			9.19
United Kingdom	United Kingdom		594		3.41			9.45
Germany			Germany				511		2.93			8.42
France			France				484		2.78			7.76
Canada			Canada				365		2.10			5.12
United States	Southeast			4		0.02			0.05
United States	Central				1		0.01			0.01
United States	Northeast			1		0.01			0.01

🔍 Key Insights
Australia Dominates Revenue: Despite having only 8.5% of the customer base, Australia contributes over 25% of 
total revenue — indicating a high-value customer base.
U.S. Has Broad Presence but Lower Yield:
Combined U.S. regions (Southwest, Northwest, Southeast, Central, Northeast) contribute 9.33% of customers and 23.36% of revenue.
The Southwest and Northwest regions are the strongest in terms of both customers and revenue.
Europe Shows Balanced Value:
UK, Germany, and France each show similar revenue-to-customer ratios, indicating stable markets with moderate returns.
Canada: Represents a smaller but consistent market — a candidate for targeted growth strategies.
Long-Tail Regions (Southeast, Central, Northeast USA): Extremely low contributions — possibly due to underpenetration 
or market misalignment.

Country			Region		% Revenue 	Return Rate%	Efficiency	Revenue% per Customer
Australia		Australia		25.88		3.22			8.04		3.045
United States	Southwest		14.07		3.09			4.55		2.522
United Kingdom	United Kingdom	9.44		3.18			2.97		2.819
United States	Northwest		9.22		3.25			2.84		2.486
Germany			Germany			8.35		3.04			2.75		2.973
France			France			7.72		3.55			2.18		2.87
Canada			Canada			5.25		3.4				1.54		2.553
United States	Southeast		0.05		2.94			0.017		2.5
United States	Central			0.01		0				N/A			1
United States	Northeast		0.01		0				N/A			1

➡️ France and Australia show the highest revenue per customer, highlighting premium customer segments.
✅ Top Performer: Australia
•	Highest efficiency (0.0385): Strong balance of high revenue per customer and relatively low return rate.
•	Ideal for growth and customer retention efforts.
🔄 Moderate Performers
•	U.K. and France also demonstrate strong value.
o	France has the highest revenue per customer, but slightly higher return rate dampens efficiency.
•	U.S. regions and Germany fall just behind, still offering solid revenue with manageable return rates.
⚠️ Underperformer: Canada
•	Lowest revenue per customer and high return rate lead to lowest efficiency (0.0297).
•	Indicates need for:
o	Improved product-market fit
o	Customer education
o	Return policy optimization
________________________________________
📍 Strategic Recommendations
1.	Strengthen focus on Australia: These markets offer high ROI (Return on Investment) per customer.
	Consider loyalty programs or upselling opportunities here.
2.	Develop U.S. Further: The Southwest and Northwest U.S. regions are performing well.
	May benefit from targeted marketing to increase customer base.
3.	Investigate Canadian Market: High return orders and low revenue suggest issues with customer expectations or satisfaction
	Investigate barriers—pricing, product relevance, or awareness
	Conduct NPS surveys or feedback session
4.	Keep an Eye on Germany, U.K., and France: Steady contributors with balanced revenue, ROI and customer base.
	Maintain support and consider tailored offerings.
    
-- Product preference of the top 29.5% customers
WITH toppers as (
	SELECT 
		CustomerKey, Continent, Country, Region,
		CntBikes, CntAccessories, CntClothings, Revenue, PercntgRevenue, rnk
	FROM custval 
	JOIN territories ON SalesTerritoryKey = TerritoryKey
	WHERE rnk <= 5152
	ORDER BY rnk
)
SELECT 
	Continent, Country, Region,
    SUM(CntBikes) AS TotalBikes, SUM(CntAccessories) AS TotalAccessories, 
    SUM(CntClothings) AS TotalClothings, ROUND(SUM(Revenue), 2) AS TotalRevenue,
    COUNT(CustomerKey) AS CntCustomers, ROUND(SUM(Revenue)/COUNT(CustomerKey), 2) AS AvgRevenue,
    ROUND(AVG(rnk)) AS AvgRankByRevenue
FROM toppers
GROUP BY Continent, Country, Region
ORDER BY AvgRankByRevenue;