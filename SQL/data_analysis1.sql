select * from customers;				#2062 rows
select * from calendar;					#912 rows
select * from products;					#293 rows
select * from product_categories; 		#4 rows
select * from product_subcategories; 	#37 rows
select * from territories;				#10 rows
select * from returns; 					#1809 rows
select * from sales_2015; 				#2630 rows
select * from sales_2016; 				#23935 rows
select * from sales_2017;				#29481 rows
select * from inventory; 				#25377 rows

-- Plots
-- -----
-- stacked column, ribbon, bar, line, heatmap, map, pie, card, slicer (region, product, year, quarter)

-- Hypotheis
-- ----------
-- SALES KPI - CARDS (net profit, net revenue, shrinkage, customer retention rate)


/* ________________________________________**** NOT TO BE REFERRED: DATASET IS INCOMPLETE FOR CUSTOMER DEMOGRAPHY
-- 3. segmentation by annual income, age, gender, marital status, total children, educational level
with cte as (
	select c.CustomerKey, Revenue, PercntgRevenue, 2015-year(BirthDate) as Age_on_2015
	from custval cu
    join customers c on cu.CustomerKey = c.CustomerKey
	where rnk <= 690
)
select 
-- 	MaritalStatus,
-- 	Gender,
-- 	TotalChildren,
-- 	EducationLevel,
	Occupation,
    Avg(Age_on_2015) Avg_Age, Avg(Annual_Income$) Avg_Annual_Income$, count(*) CntCustomers, 
    SUM(Revenue) Revenue, SUM(PercntgRevenue) PercntgRevenue
from customers c
join cte on cte.CustomerKey = c.CustomerKey
group by 1
order by 5 desc;

MaritalStatus	Avg_Annual_Income$	Avg_Age		CntCustomers		Revenue				PercntgRevenue
M				69734.5133			54.5870			339				3353790.065800001	39.86016213882725
S				59281.6092			50.6866			351				3336564.043700001	39.655428980089994

Gender			Avg_Annual_Income$	Avg_Age		CntCustomers		Revenue				PercntgRevenue
F					62873.2394		52.3118			356			3442012.8280000007		40.90869932709292
M					66341.4634		52.9030			330			3204434.6997000016		38.08505725979551
NA					47500.0000		53.7500			4			43906.5818				0.5218345320288298

TotalChildren	Avg_Annual_Income$	Avg_Age		CntCustomers		Revenue				PercntgRevenue
0				64404.1451			44.3866			194			1931494.2480000006		22.956020616969457
1				54117.6471			52.5294			153			1384235.8751999997		16.451794936870023
2				61521.7391			56.5827			139			1317099.584				15.653872765199099
4				82278.4810			59.1266			79			822011.2119999999		9.769693256706018
3				66056.3380			55.3472			72			654607.6135999997		7.7800831606860585
5				73207.5472			59.0000			53			580905.5766999999		6.904126382486508

Occupation		Avg_Annual_Income$	Avg_Age		CntCustomers		Revenue				PercntgRevenue
Professional	81790.3930			51.6710			231			2446827.2176000015		29.080809384521473
Management		104140.6250			60.0781			128			1331557.016				15.825700927464702
Skilled Manual	54393.9394			50.1591			132			1190532.7369000001		14.149611929599434
Clerical		32500.0000			51.8142			113			997638.7509000001		11.857045786008504
Manual			16162.7907			48.7674			86			723798.3881000001		8.602423091323063

EducationLevel		Avg_Annual_Income$	Avg_Age		CntCustomers		Revenue				PercntgRevenue
Bachelors				71076.2332		51.8036			224			2221912.2949000006		26.40767090227563
Partial College			58870.0565		54.4749			179			1699362.1329			20.197105012838538
Graduate Degree			69727.8912		52.2925			147			1390232.1160999988		16.523060916495506
High School				58333.3333		54.0729			96			953382.8223				11.331059229011666
Partial High School		48863.6364		46.8864			44			425464.74330000003		5.056695058295832
*/

-- STRATEGY - SALES, MARKETTING and INVENTORY
-- ------------------------------------------
-- 1. sales actual vs forecasted value (excel forecast function, moving avg)
-- 2. sales by ProductSKU
-- 3. marketting call to action