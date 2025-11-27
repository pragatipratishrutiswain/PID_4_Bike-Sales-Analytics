-- Do a sales analysis for FY 2015-17.
with orders as (
select 
    Year, 
    c.CategoryName
    , round(sum(productcost*OrderQuantity), 1) as Cost
    , sum(OrderQuantity) as TotalOrders
	, round(sum(ProductPrice*OrderQuantity), 1) as OrderRev
    , row_number() over(order by year,c.CategoryName) Rnk
from all_sales s
join products p on s.ProductKey = p.ProductKey
join product_subcategories sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
join product_categories c on sub.ProductCategoryKey = c.ProductCategoryKey
group by Year, c.CategoryName
),
retrns as(
select 
    Year(ReturnDate) as Year, 
    c.CategoryName
    , sum(ReturnQuantity) as TotalRetrns
    , round(sum(ProductPrice*ReturnQuantity), 1) as ReturnRev
    , row_number() over(order by Year(ReturnDate),c.CategoryName) Rnk
from returns r
join products p on  r.ProductKey = p.ProductKey
join product_subcategories sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
join product_categories c on sub.ProductCategoryKey = c.ProductCategoryKey
group by Year, c.CategoryName
)
select 
	o.Year, o.CategoryName, TotalOrders, TotalRetrns
    , TotalOrders - TotalRetrns as NetOrders
    , Cost, OrderRev, ReturnRev
    , round(OrderRev - ReturnRev, 1) as NetRevenue
    , round((OrderRev - ReturnRev) - Cost, 1) as NetProfit
from orders o 
join retrns r on o.Rnk = r.Rnk 
order by Year;

-- calculate the market share by category and sub-category level interms of quantity and revenue
with orders as (
select 
    Year, 
    c.CategoryName
    , round(sum(productcost*OrderQuantity), 1) as Cost
    , sum(OrderQuantity) as TotalOrders
	, round(sum(ProductPrice*OrderQuantity), 1) as OrderRev
    , row_number() over(order by year,c.CategoryName) Rnk
from all_sales s
join products p on s.ProductKey = p.ProductKey
join product_subcategories sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
join product_categories c on sub.ProductCategoryKey = c.ProductCategoryKey
group by Year, c.CategoryName
),
retrns as(
select 
    Year(ReturnDate) as Year, 
    c.CategoryName
    , sum(ReturnQuantity) as TotalRetrns
    , round(sum(ProductPrice*ReturnQuantity), 1) as ReturnRev
    , row_number() over(order by Year(ReturnDate),c.CategoryName) Rnk
from returns r
join products p on  r.ProductKey = p.ProductKey
join product_subcategories sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
join product_categories c on sub.ProductCategoryKey = c.ProductCategoryKey
group by Year, c.CategoryName
),
sales as (
	select 
		o.Year, o.CategoryName, TotalOrders, TotalRetrns
		, TotalOrders - TotalRetrns as NetOrders
		, Cost, OrderRev, ReturnRev
		, round(OrderRev - ReturnRev, 1) as NetRevenue
		, round((OrderRev - ReturnRev) - Cost, 1) as NetProfit
	from orders o 
	join retrns r on o.Rnk = r.Rnk 
	order by Year
)
select 
	Year
    , CategoryName
	, round(100*NetOrders/sum(NetOrders) over(partition by Year), 2) as Perc_NetOrderQuantity
	, round(100*Cost/sum(Cost) over(partition by Year), 2) as Perc_Cost
	, round(100*NetRevenue/sum(NetRevenue) over(partition by Year), 2) as Perc_NetRevenue
	, round(100*NetProfit/sum(NetProfit) over(partition by Year), 2) as Perc_NetProfit
from sales;

-- a. By quantity sold
-- Insights:
-- 1. Bikes is the only category being sold in 2015 so the entire 100% quantity sold is from bikes category.
-- 2. In 2016 Accessories(68%) > Clothing(20%) > Bikes(12%)
-- 3. In 2017 also Accessories(69%) > Clothing(21%) > Bikes(10%)

-- b. By revenue share
-- Revenue Insights:
-- 1. Bikes is the only category being sold in 2015 so the entire 100% revenue generated is from bikes category.
-- 2. In 2016 Bikes(71.23%) > Accessories(25.23%) > Clothing(3.53%)
-- 3. In 2017 also Bikes(63.22%) > Accessories(32.15%) > Clothing(4.63%)
-- Profit Insights:
-- 1. Bikes is the only category being sold in 2015 contributing to the entire 100% profit.
-- 2. In 2016 Bikes(63.93%) > Accessories(33.12%) > Clothing(2.95%)
-- 3. In 2017 also Bikes(54.93%) > Accessories(41.26%) > Clothing(3.81%)

🧩 Overview of Category Trends (2015 – June 2017)
Market Share in terms of Quantity:
| Category        | 2015          | 2016           | 2017 (Jan–Jun)|
| --------------- | ------------- | -------------- | ------------- |
| **Bikes**       | 100% – 3973   | 12% - 8541     | 10% - 8652    |
| **Accessories** | 0% – 0    	  | 68% – 48368    | 69% – 62820   |
| **Clothing**    | 0% – 0        | 20% – 13964    | 21% – 19038   |
🔢 1. Order Volume Analysis
Key Insight: There’s a clear shift from Bikes in 2015 to Accessories & Clothing dominating in 2016 and 2017.
Bike orders dropped significantly, from 3973 in 2015 to ~8600 in 2016–2017, but percentage-wise declined due to rising 
orders of Accessories and Clothing.
💰 2. Revenue Contribution (%)
Bikes remain the highest revenue generator, although its share declines over time.
Accessories and Clothing have growing revenue shares, aligned with rising order volumes.
💹 3. Profit Contribution (%)
Bikes maintain highest absolute profit, but profit share is declining.
Accessories show the strongest profit growth, from 25.23% to 33.12%, despite a modest revenue share — 
suggesting higher margins or better cost control.
📊 4. Cost of Goods Sold (COGS) and Efficiency
Category	Revenue-to-COGS Ratio (2017)
Bikes		1.73 
Accessories	2.71
Clothing	1.68
Accessories lead in cost efficiency, generating more revenue per unit cost, followed by Clothing, then Bikes.
This shows Accessories are increasingly lucrative, supporting their rise in profit contribution.
📌 Strategic Insights
🟢 Opportunities
Expand Accessories and Clothing lines due to their:
Rising order volume
Improving profit margins
Better cost-to-revenue efficiency
Target marketing and bundling offers around Accessories, which are clearly gaining traction. 
Why: The bike drives the bulk of revenue, and strong positioning helps upsell accessories.
🔴 Risks
Over-dependence on Bikes for revenue poses a long-term risk if demand continues declining.
Bikes are high in cost and although still profitable, margins are compressing.

🟡 Recommendations
| Focus Area        | Product(s)      | Action                                      |
| ----------------- | --------------- | ------------------------------------------- |
| Revenue driver    | Bike            | Position as premium, sell on value          |
| Profit booster    | Helmet, T-shirt | Upsell, bundle, discount slightly           |
| Volume maximizer  | Accessories     | Promote via loyalty, cross-sell             |
| Conversion funnel | All             | Use bundled deals, digital ads, retargeting |

Rebalance Product Strategy: Increase focus on Accessories & Clothing.
Cost Optimization for Bikes: Explore supply chain or production efficiency improvements.
Targeted Promotions: Use data-driven marketing to convert accessory buyers into bike up-sells and vice versa.
Monitor Trends Quarterly: Ensure real-time responsiveness to shifts in category performance.

-- 2. which top 5 product/ModelName are generetating maximum revenue for FY 15-17?
with ordrs as (
select 
    Year, CategoryName, SubcategoryName, ModelName
    , count(*) as CountVariants
    , round(sum(productcost*OrderQuantity), 1) as Cost
    , sum(OrderQuantity) as TotalOrders
	, round(sum(ProductPrice*OrderQuantity), 1) as OrderRev
    , row_number() over(order by year,c.CategoryName,ModelName) Rnk
from all_sales s
join products p on s.ProductKey = p.ProductKey
join product_subcategories sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
join product_categories c on sub.ProductCategoryKey = c.ProductCategoryKey
group by Year, c.CategoryName, SubcategoryName, ModelName
),
retrns as(
select 
    Year(ReturnDate) as Year, c.CategoryName, ModelName
    , sum(ReturnQuantity) as TotalRetrns
    , round(sum(ProductPrice*ReturnQuantity), 1) as ReturnRev
    , row_number() over(order by Year(ReturnDate),c.CategoryName,ModelName) Rnk
from returns r
join products p on  r.ProductKey = p.ProductKey
join product_subcategories sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
join product_categories c on sub.ProductCategoryKey = c.ProductCategoryKey
group by Year, c.CategoryName, ModelName
),
final as(
	select 
		o.Year, o.CategoryName, o.SubcategoryName, o.ModelName, CountVariants
		, TotalOrders, TotalRetrns
		, TotalOrders - TotalRetrns as NetOrders
		, Cost
		, round(OrderRev - ReturnRev, 1) as NetRevenue
		, round((OrderRev - ReturnRev) - Cost, 1) as NetProfit
		, row_number() over(partition by o.Year order by round(OrderRev - ReturnRev, 1) desc) as Rnk
	from ordrs o 
	join retrns r on o.Rnk = r.Rnk 
	order by Year
)
select * from (
	select 
		Year, CategoryName, SubcategoryName, ModelName, NetOrders
		, concat(round(Cost/pow(10,6), 1),"M") as Cost -- round(Cost/pow(10,6), 1)
		, round(100*Cost/sum(Cost) over(partition by Year),1) as Perc_Cost
		, concat(round(NetRevenue/pow(10,6),1),"M") as NetRevenue -- round(NetRevenue/pow(10,6),1)
		, round(100*NetRevenue/sum(NetRevenue) over(partition by Year),1) as Perc_Rev
		, concat(round(NetProfit/pow(10,6),1),"M") as NetProfit -- round(NetProfit/pow(10,6),1)
		, round(100*NetProfit/sum(NetProfit) over(partition by Year),1) as Perc_Profit, Rnk
	from final
) tbl
where Rnk < 6;
-- ---------------------------------------------------------

Insights: 
📊 1. Revenue and Profit Trends (Year-over-Year)
Total revenue from bikes grew significantly from 2015 to 2016, indicating strong market demand.
2016 saw a surge in bike sales, especially in Mountain and Touring models, while 2017 (H1) shows a more diversified product contribution.
Net Profit followed revenue trends, growing each year, with higher profitability for certain high-ticket items 
(e.g., Touring and Road models).
🚴‍♂️ 2. Best-Performing Bike Models
2015
Dominated by Road-150 (38.13% revenue) and Mountain-200 (30.37%), together forming nearly 70% of the year’s bike revenue. 
Road-250 also holds a fare share of 25.47%.
These models also contributed heavily to net profit and order quantities.
2016
Shift from road to mountain bikes: Mountain-200 became the top performer with 43.56% of total revenue. Sport-100 Helmet also shares 12.19% rev.
Road-250 remained important but lost relative share.
Introduction of Touring models (1000–3000) also shows diversification.
2017 (H1)
Mountain-200 maintained dominance (36.85% of revenue), indicating ongoing consumer preference.  Sport-100 Helmet shares rose to 15.64% from 12.19% rev.
Touring-1000 and Road-350-W performed well.
Clear evidence of expansion into women segment and mid-tier models like Road-550-W and Mountain-400-W.
🧾 3. Order Quantity vs. Revenue
Accessories and Clothing generate high order volumes but low revenue share, suggesting:
High-volume, low-value transactions.
Potential for bundle deals or cross-sell strategies.
Sport-100 stands out in 2016–2017, with 15k+ orders, indicating its popularity.
In contrast, bikes have high revenue but fewer units sold, which is typical of high-ticket items.
🛍️ 4. Accessory & Clothing Category Growth
2016–2017 saw expansion in accessories (Hydration Pack, Tire products, etc.), indicating:
Customers are enhancing their riding experience.
Opportunity to grow average order value (AOV) through upselling.
Clothing products such as Jerseys and Gloves have stable demand, especially Short-Sleeve Classic Jersey and Half-Finger Gloves.
💰 5. Product Profitability Insights
High-profit models include:
Mountain-200, Road-150, and Touring-1000.
Accessories like Sport-100, Hydration Pack, and Bike Stand offer excellent profit margins despite lower revenue.
Focus on high-margin products can help drive better net income growth.
📈 6. Strategic Opportunities
Shift in consumer preference from Road to Mountain and Touring bikes over the three years.
Strong case for product line diversification — offering a balanced mix of high-revenue, high-volume, and high-margin items.
Potential to optimize inventory and marketing around:
Best-sellers (Mountain-200, Sport-100)
High-profit accessories (Hydration Packs, Bike Stands)
Emerging trends (Touring and Womens models)
📉 7. Declining or Flat Performers
Road-650 and Road-550-W dropped in relative importance post-2015.
Accessories like Road Tire Tube and Patch Kit have marginal growth and may require inventory re-evaluation.
🧠 8. Overall Category Insights
Bikes dominate in revenue and profit.
Accessories lead in unit sales — ideal for bundling or loyalty programs.
Clothing remains stable — suggestive of a core but niche segment.

SELECT DISTINCT ProductName, ModelName, CategoryName 
FROM sales_2015 s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN product_subcategories ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN product_categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
WHERE s.ProductKey NOT IN (SELECT ProductKey FROM sales_2016);
ModelName
Road-150		Bikes	(45% of revenue in 2015)
Mountain-100	Bikes	(11.6% of revenue in 2015)
Reason: Road-150 and Mountain-100 models stopped launching 2016 onwards even after creating 45% and 11.6% revenue in 2015.

SELECT DISTINCT ProductName, ModelName, CategoryName 
FROM sales_2015 s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN product_subcategories ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN product_categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
WHERE s.ProductKey IN (SELECT ProductKey FROM sales_2016)
and s.ProductKey NOT IN (SELECT ProductKey FROM sales_2017);
ModelName
Road-650	Bikes (4.25% in 2015, 2.53% in 2016)
Road-250	Bikes (24.2.5% in 2015, 21.8% in 2016, 7.2% in 2017)
Reason: Re-launched in 2016 but stopped launching 2017 onwards.

SELECT DISTINCT ProductName, ModelName, CategoryName 
FROM sales_2016 s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN product_subcategories ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN product_categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
WHERE s.ProductKey NOT IN (SELECT ProductKey FROM sales_2017);
Road-650	Bikes
Road-250	Bikes
Reason: Same as above

SELECT DISTINCT ProductName, ModelName, CategoryName 
FROM sales_2016 s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN product_subcategories ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN product_categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
WHERE s.ProductKey NOT IN (SELECT ProductKey FROM sales_2015);
34 models (Clothing, Accessories, Bikes)
Reason: 34 new variants launched in 2016 in Clothing, Accessories, Bikes category, preferably to cater the needs of the customer
after introducing them to bikes in 2015

SELECT DISTINCT ModelName, CategoryName 
FROM sales_2017 s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN product_subcategories ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN product_categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
WHERE s.ProductKey NOT IN (SELECT ProductKey FROM sales_2016);
No models
Reason: No new launches after 2016 by viewing the market trend and customer demand

SELECT DISTINCT ModelName, CategoryName 
FROM sales_2017 s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN product_subcategories ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN product_categories pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
WHERE s.ProductKey IN (SELECT ProductKey FROM sales_2015)
and s.ProductKey NOT IN (SELECT ProductKey FROM sales_2016);
No models
Reason: No re-launches in 2017 after being stopped launching in 2016

Strategic Product Lifecycle & Marketing Analysis (2015–2017):
📈 1. Product Lifecycle Stages
Mountain-100 (2015 only):
Likely at its maturity or decline stage in 2015.
High revenue/profit could result from brand equity built over prior years.
Discontinuation in 2016–17 suggests a strategic phase-out or replacement.

Touring-1000 (2016–2017):
Shows strong growth → likely in growth stage.
High marketing investment and favorable market response (e.g., long-distance riders, higher-margin touring segment).

🎯 2. Target Market Segmentation
Introduction of "W" models (Road-550-W, Road-350-W, etc.) reflects:
A shift toward gender-specific segmentation (women-specific design/marketing).
Possibly supported by campaigns tailored to women cyclists, expanding market reach.

Touring and Mountain categories:
Indicate focus on outdoor adventure and fitness-conscious segments.
Higher margins are common in these niche, experience-driven categories.

💰 3. Value-Based Pricing Strategy
Models like Touring-1000 and Mountain-200 consistently contribute higher % profits than % revenue.
Indicates a premium pricing strategy supported by:
Superior components
Strong brand association
Focused marketing messaging (e.g., performance, endurance)

🧩 4. Product Differentiation & Variant Strategy
High-variant models (e.g., Road-650 with 12 variants):
Suggest a strategy to cover multiple price points or customer needs.
But too many variants may confuse buyers or cannibalize sales, leading to lower profitability.
Low-variant models with high profit (e.g., Touring-1000):
Reflect a focused, differentiated product with strong brand messaging and loyal customer base.

📊 5. Channel & Promotion Mix
Shift from core models (Mountain-100, Road-150) to newer lines (Touring series):
Implies reallocation of advertising budgets, dealer incentives, and channel focus.
May have included online campaigns, influencer outreach, or event sponsorships (e.g., cycling tours).

💡 Strategic Takeaways
Invest in Touring segment: Proven growth and profitability.
Streamline variants: Focus on profitable models with high brand recall.
Expand W-series: Tapping into a growing women’s cycling segment.
Phase out underperformers: Use lifecycle analysis to make room for innovation.
------------------------------------------------------------

-- 3. Count total number of categories, subcategories, models, and products 

-- i. from the sales table
select 
	CategoryName,
    count(distinct SubcategoryName) as Cnt_Subcategory,
    count(distinct ModelName) as Cnt_ModelName,
    count(distinct a.ProductKey) as Cnt_Products
from all_sales a
join products p on a.productkey = p.productkey
join product_subcategories sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
join product_categories c on sub.ProductCategoryKey = c.ProductCategoryKey
group by 1
order by 3 desc, 2 desc;

-- ii. from the products table
select 
	CategoryName,
    count(distinct SubcategoryName) as Cnt_Subcategory,
    count(distinct ModelName) as Cnt_ModelName,
    count(ProductKey) as Cnt_Products
from products p
join product_subcategories sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
join product_categories c on sub.ProductCategoryKey = c.ProductCategoryKey
group by 1
order by 3 desc, 2 desc;

Insights: 
i. 	There are 4 categories, 37 sub-categories, 119 ModelNames and 293 products.
ii.  No of products in Components > Bikes > Clothing > Accessories. 'Components' offers most choices to the customer.
iii. CategoryName	Cnt_Subcategory		Cnt_ModelName	Cnt_Products
		Components			14				65				132
		Accessories			12				27				29
		Bikes				3				15				97
		Clothing			8				12				35
        
-- iv.	Findout products and categories from the products table that are not in inventory table that contains only the products from the 
-- 		sales 15/16/17 table
select productkey, ProductName, CategoryName 
from products p
join product_subcategories sub on p.ProductSubcategoryKey = sub.ProductSubcategoryKey
join product_categories c on sub.ProductCategoryKey = c.ProductCategoryKey
where productkey not in 
	(select distinct productkey from inventory)		 # 163 product
    
    Insights:
1. All three Sales tables do not contain any data of the products from the Components category.
2. There are 15 - Clothing, 7 - Accessories, 9 - Bikes and the entire 132 - Components products exists in the products table but are 
   mising from the Sales table.
3. This indicates that the Products table contains extra information about the products which are out of the scope of the Sales table.
   This could be because they were newly added, discontinued, or simply did not sell. (The Stock Dates in the sales table
   span from '2001-09-11' to '2004-06-15' ~ 3 years which implies that the products table may have been generated much later than the 
   stocks created. I noticed the 'Components' category exists in the products table but has no representation in the sales data 
   from 2015–2017.) This could mean those products weren not sold during that time, or it could indicate a data modeling or pipeline issue. 
   In a real-world scenario, I would confirm with the business if those products were discontinued, and check the ETL logic to ensure no 
   sales were missed.
   
   In the bicycle business, bikes typically remain in dealership inventory for 1 to 4 months before being sold. 
   This is considered normal. If inventory sits longer—especially over a year — it’s usually for less popular models and is seen 
   as inefficient. Longer gaps often prompt discounts or promotions to move the stock. A 15-year gap would be highly unusual and 
   generally indicates either a data error, a unique collector’s item (vintage), or a vehicle that was never intended for regular sale. 
   No standard industry records or news sources report such an extreme gap as a normal occurrence.

select CategoryName, count(SubcategoryName) CntSubcategory
from product_subcategories s
join product_categories c 
on s.ProductCategoryKey = c.ProductCategoryKey
group by 1; # Accessories, Bikes, Clothing

