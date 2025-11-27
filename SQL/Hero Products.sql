		## HERO PRODUCTS ##
-- Create a view that contains the information of Year, ProductKey and OrderQuantity of all three sales tables from 2015 to 2017
/*
Create View all_sales as 
    select '2015' as Year, ProductKey, sum(OrderQuantity) as OrderQuantity from sales_2015 group by  1, 2
    union all
    select '2016' as Year, ProductKey, sum(OrderQuantity) as OrderQuantity from sales_2016 group by  1, 2
    union all
    select '2017' as Year, ProductKey, sum(OrderQuantity) as OrderQuantity from sales_2017 group by  1, 2;
#*/
select * from all_sales;

-- 1. Which are top 5 products sold in highest quantity for each year?
select *, 
	dense_rank() over (partition by ProductKey order by Year) as Cnt_In_Top5
from
	(select Year, a.ProductKey, OrderQuantity,
		ProductName,
		SubcategoryName,
		CategoryName,
		ProductPrice, 
        row_number() over(partition by Year order by OrderQuantity desc) as rnk
	from all_sales a
	join products p on a.ProductKey = p.ProductKey
	join product_subcategories s on p.ProductSubcategoryKey = s.ProductSubcategoryKey
	join product_categories c on c.ProductCategoryKey = s.ProductCategoryKey
	) as t
where t.rnk < 6
order by Year, OrderQuantity desc;

-- Insights: 
-- i.  Low-ticket items such as Productkey 214 (Helmets), 220 (Helmets), 477 (Bottles and Cages), 480 (Tires and Tubes) 
--     appear twice within top 5 quantity sold products subsequently for 2016/17 making them hot sellers.
-- ii. Non of the top 5 products of 2015 (Road Bikes) has appeared in the top 5 sold of 2016/17 indicating a shift 
-- 	   in consumer preference from only bikes to accesories and clothings; due to new category creation.
-- iii.The top sellers of 2015 are Bikes while those of 2016/17 are bike-accessories.
-- iv. Bikes are ~110 time more expensive than accessories which makes them long-term purchase and are not going to be 
-- 	   frequently replaced.
-- v.  The demand for bike related accessories like helmet (topseller) in 2016, 'Tires and Tubes', 'Caps' and 'Bottles and Cages' 
-- 	   (topsellers) in 2017 is an anticipated change that has risen with the consumer preference for safety and comfort.
-- vi. The shift in demand trend indicates the change in the consumer necessity and a market place to adapt this.
