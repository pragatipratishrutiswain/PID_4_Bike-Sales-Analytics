	## Sales Trend Analysis ##
    -- ------------------------
/*
create table overalsales as
	select * from sales_2015
	union all 
	select * from sales_2016
	union all
	select * from sales_2017;
*/
-- m-o-m sales trend
use ppsdb;
WITH ordertbl AS(
	SELECT 
		date_format(OrderDate, '%Y') AS Year,
        quarter(OrderDate) AS Quarter,
		date_format(OrderDate, '%m') Month,
        SUM(OrderQuantity) AS OrderQuantity,
		ROUND(SUM(ProductPrice * OrderQuantity), 2) AS TotalRevenue,
        ROUND(SUM(ProductCost * OrderQuantity), 2) AS TotalCost,
        row_number() OVER() AS Rnk
	FROM overalsales
	JOIN products USING(ProductKey)
	GROUP BY Year, Quarter, Month
	ORDER BY Year,Quarter, Month
),
retrn AS(
	SELECT 
		date_format(ReturnDate, '%Y') AS Year,
        quarter(ReturnDate) AS Quarter,
		date_format(ReturnDate, '%m') Month,
        SUM(ReturnQuantity) AS ReturnQuantity,
		ROUND(SUM(ProductPrice * ReturnQuantity), 2) AS RevenueLost,
        row_number() OVER() AS Rnk
	FROM returns
	JOIN products USING(ProductKey)
	GROUP BY Year, Quarter, Month
	ORDER BY Year,Quarter, Month
),
net AS(
	SELECT 
		o.Year, o.Quarter, o.Month, o.TotalRevenue, r.RevenueLost
        , ROUND(IFNULL(o.TotalRevenue - r.RevenueLost, o.TotalRevenue), 2) AS NetRev, TotalCost
        , ROUND(IFNULL((o.TotalRevenue - r.RevenueLost) - TotalCost, (o.TotalRevenue-TotalCost)), 2) AS Profit
        , OrderQuantity, ReturnQuantity
        , IFNULL(OrderQuantity - ReturnQuantity, OrderQuantity) AS FinalQuantity
	FROM ordertbl o
    LEFT JOIN retrn r ON o.Rnk = R.Rnk
	ORDER BY o.Rnk
),
cte as (
	SELECT *, COALESCE(LAG(NetRev) OVER(ORDER BY Year, Month), 0) AS PrvMonthNetRev
	FROM net
),
final as(
	SELECT *, (NetRev - PrvMonthNetRev)*100/PrvMonthNetRev AS GrowthPrcntg
	FROM cte)
select 
	Year, Quarter, Month, TotalCost
    , Profit, NetRev, PrvMonthNetRev, GrowthPrcntg, FinalQuantity
from final;

Insights:
📈 1. Monthly Seasonality
There is no consistent seasonal pattern across all years.
2015 peaks in Q2, dips in Q4.
2016 shows clear growth from mid-year to Q4.
2017 has a consistent upward trend, not seasonal.
🔄 Therefore, seasonality may not be a driving factor — instead, revenue trends are likely driven
by year-specific factors such as product launches, promotions, or expanded market presence.

📌 3. Q4 2016 Was a Revenue Breakout
Oct–Dec 2016 had the highest sustained revenue in the dataset:
Oct: ~1.7M
Nov: ~1.83M
Dec: ~2.65M (largest single-month revenue overall for 2016)
Likely driven by year-end campaigns, holiday sales, or new product launches.

🆙 4. 2017 Continues the Surge
Jan–Jun 2017 revenue is consistently higher than the same months in 2016.
Example: June revenue:
2015: ~1.02M
2016: ~770K
2017: ~2.9M (nearly 3× higher than in 2015)
Suggests strong brand momentum, market expansion, or pricing impact.

❗ 5. 2015 Was a Flat Year
Revenue hovered around ~800K–1M with a dip in Q4, especially Nov (~495K).
Possibly due to limited product offering or weaker marketing.

🔍 6. Growth Acceleration Started Mid-2016
A clear jump in July 2016: revenue spiked to ~1.27M, then kept growing.

This could indicate a turning point — e.g.,:
Launch of new bike models?
Better inventory management?
Entry into new sales channels?

✅ Summary Table of Key Revenue Milestones
Month	2015	2016	2017
Jan		889K	662K	2.1M
Jun		1.02M	770K	2.9M
Dec		846K	2.65M	—

-- Sales Trend for Different Territories
with orders as(
	select 
		year(OrderDate) as Year
        , Continent, Country, Region
        , sum(OrderQuantity) as OrderQuantity
        , round(sum(OrderQuantity*ProductCost), 2) Cost
        , round(sum(OrderQuantity*ProductPrice), 2) OrderValue
	from territories
    join overalsales o on TerritoryKey = SalesTerritoryKey
    join products p on o.ProductKey = p.ProductKey
    group by 1,2,3,4
),
retrns as(
	select 
		year(ReturnDate) as Year
        , Continent, Country, Region
        , sum(ReturnQuantity) as ReturnQuantity
        , round(sum(ReturnQuantity*ProductPrice), 2) ReturnValue
	from territories
    join returns r on TerritoryKey = SalesTerritoryKey
    join products p on r.ProductKey = p.ProductKey
    group by 1,2,3,4
)
select 
	o.Year, o.Continent, o.Country, o.Region
    , OrderQuantity, ifnull(ReturnQuantity, 0) as ReturnQuantity
    , ifnull(OrderQuantity - ReturnQuantity, OrderQuantity) as FinalQuantity
    , OrderValue, ifnull(ReturnValue, 0) as ReturnValue, Cost
    , round(ifnull(OrderValue - ReturnValue, OrderValue), 2) as Rev_Gen
    , round(ifnull(OrderValue - ReturnValue, OrderValue) - cost, 2) as Profit
from orders o
left join retrns r
	on o.Year = r.Year and o.Continent = r.Continent 
    and o.Country = r.Country and o.Region = r.Region
ORDER BY o.Year, Rev_Gen DESC;
