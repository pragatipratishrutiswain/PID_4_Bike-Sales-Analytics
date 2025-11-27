select * from customers;				#2062 rows
select * from calendar;					#912 rows
select * from products;					#293 rows
select * from product_categories; 		#4 rows
select * from product_subcategories; 	#37 rows
select * from territories;				#10 rows
select * from returns; 					#1809 rows
select * from sales_2015; 				#2630 rows
select * from sales_2016; 				#23935 rows
select * from sales_2017; 				#29481 rows
select * from inventory; 				#25377 rows

# The current inventory table contains only the data of the stock dates and products which have been present in the sales 2015/16/17 table
# in order to get a better picture of trend and seasonality analysis.

-- select 2225+11271+11881; # = 25377 

/* Each order line (or order line item) in the sales table represents a unique product or service, including details like product 
name, quantity, and price. The order line number is used to identify and organize these entries within the order, making it 
easier to track, fulfill, or reference individual items. The order quantity can never be lesser than the order line item 
because each order line item indicates a unique product details. So if the order line item = 8 that means that particular order
contains 8 different products in a queue. */

/*
-- 1. Regenate OrderQuantity column so that they are >= OrderLineItem in the sales 2015, 2016 and 2017 tables.
update sales_2015
set OrderQuantity = 
	case when OrderLineItem > 1 then CEILING(1 + RAND() * 2 * OrderLineItem)
	else ROUND(1 + RAND() * OrderLineItem)
end;
update sales_2016
set OrderQuantity = 
	case when OrderLineItem > 1 then CEILING(1 + RAND() * 2 * OrderLineItem)
	else ROUND(1 + RAND() * OrderLineItem)
end;
update sales_2017
set OrderQuantity = 
	case when OrderLineItem > 1 then CEILING(1 + RAND() * 2 * OrderLineItem)
	else ROUND(1 + RAND() * OrderLineItem)
end;

-- 2. Clean the dates column in each table from string to date format
ALTER TABLE sales_2015 MODIFY StockDate DATE, MODIFY OrderDate DATE;
ALTER TABLE sales_2016 MODIFY StockDate DATE, MODIFY OrderDate DATE;
ALTER TABLE sales_2017 MODIFY StockDate DATE, MODIFY OrderDate DATE;

UPDATE returns
SET ReturnDate = STR_TO_DATE(ReturnDate, '%m/%d/%Y');
ALTER TABLE returns MODIFY ReturnDate DATE;

UPDATE calendar
SET Date = STR_TO_DATE(Date, '%d-%m-%Y');
ALTER TABLE calendar MODIFY Date DATE;

UPDATE customers
SET BirthDate = STR_TO_DATE(Date, '%d/%m/%Y');
ALTER TABLE customers MODIFY Date DATE;

-- 3. Drop Unknown Column and duplicate column (AnnualIncome) from the Customers table
alter table customers
drop column MyUnknownColumn,
drop column AnnualIncome,
rename column Annual_Income to Annual_Income$;

-- 4. Regenerate ReturnQuantity to match according to new sales qauntity 
update returns
set ReturnQuantity = ReturnQuantity + round(rand());

-- 5. Update Calendar table
alter table calendar
rename column Year to Order_Year,
rename column Date to Order_Date,
add column Stock_Date date;

alter table calendar
drop column Stock_Date;

DELETE FROM calendar
WHERE order_year is null and order_date is null;

-- 6. Create an Inventory table using the stock dates from the sales 2015, 2016 and 2017 dataset where the stock quantity may be 
-- same as or twice the number of quantity ordered in the sales table.
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
StockDate date,
ProductKey int,
StockQuantity int);

INSERT INTO inventory (StockDate, ProductKey, StockQuantity)
SELECT StockDate, ProductKey, StockQuantity FROM (
    ((SELECT StockDate, ProductKey, SUM(OrderQuantity) * CEILING(RAND() * 2) AS Quantity FROM sales_2015 GROUP BY 1,2)
     UNION ALL 
     (SELECT StockDate, ProductKey, SUM(OrderQuantity) * CEILING(RAND() * 2) AS Quantity FROM sales_2016 GROUP BY 1,2)
     UNION ALL
     (SELECT StockDate, ProductKey, SUM(OrderQuantity) * CEILING(RAND() * 2) AS Quantity FROM sales_2017 GROUP BY 1,2))
    ORDER BY 1
) AS AllDates;

select * from inventory; # 25377 rows

SELECT StockDate, ProductKey, SUM(OrderQuantity) AS Quantity FROM sales_2015 GROUP BY 1,2
UNION ALL 
SELECT StockDate, ProductKey, SUM(OrderQuantity) AS Quantity FROM sales_2016 GROUP BY 1,2
UNION ALL
SELECT StockDate, ProductKey, SUM(OrderQuantity) AS Quantity FROM sales_2017 GROUP BY 1,2
ORDER BY 1; # 25377 rows

-- 7. Add a new column to the customers tables named as "Shopping_Source" that takes only string values from the following options:
-- Twitter, Affiliate, Facebook, Google, Organic 
-- ("Organic" in this context means non-paid or unpaid traffic. It's traffic that comes to a website without the use of paid advertising.)
 
alter table sales_2015
add column Shopping_Source text;
UPDATE sales_2015
SET Shopping_Source = (
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'Twitter'
        WHEN 1 THEN 'Affiliate'
        WHEN 2 THEN 'Facebook'
        WHEN 3 THEN 'Google'
        WHEN 4 THEN 'Organic'
    END
);

alter table sales_2016
add column Shopping_Source text;
UPDATE sales_2016
SET Shopping_Source = (
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'Twitter'
        WHEN 1 THEN 'Affiliate'
        WHEN 2 THEN 'Facebook'
        WHEN 3 THEN 'Google'
        WHEN 4 THEN 'Organic'
    END
);

alter table sales_2017
add column Shopping_Source text;
UPDATE sales_2017
SET Shopping_Source = (
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'Twitter'
        WHEN 1 THEN 'Affiliate'
        WHEN 2 THEN 'Facebook'
        WHEN 3 THEN 'Google'
        WHEN 4 THEN 'Organic'
    END
);
*/

/*
select distinct productkey from inventory; # 130 rows
select productkey from products
where productkey not in (select distinct productkey from inventory); # 163 rows

-- Add these products to the inventory table also in order to make the data more realistic.
select distinct productkey from sales_2015
union
select distinct productkey from sales_2016
union
select distinct productkey from sales_2017;  # 130 rows

WITH RECURSIVE
date_series AS (
  SELECT DATE('2001-09-11') AS stock_date
  UNION ALL
  SELECT DATE_ADD(stock_date, INTERVAL 1 DAY)
  FROM date_series
  WHERE stock_date < '2004-06-15'
),
one_per_product AS (
  SELECT
    p.product_key,
    (SELECT stock_date FROM date_series ORDER BY RAND() LIMIT 1) AS stock_date,
    FLOOR(1 + (RAND() * 3)) AS stock_quantity
  FROM products p
),
extra_rows AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM extra_rows WHERE n < 137
),
extra_assignments AS (
  SELECT
    (SELECT product_key FROM products ORDER BY RAND() LIMIT 1) AS product_key,
    (SELECT stock_date FROM date_series ORDER BY RAND() LIMIT 1) AS stock_date,
    FLOOR(1 + (RAND() * 3)) AS stock_quantity
  FROM extra_rows
),
all_assignments AS (
  SELECT * FROM one_per_product
  UNION
  SELECT * FROM extra_assignments
)
SELECT stock_date, product_key, stock_quantity
FROM all_assignments
ORDER BY product_key, stock_date;
*/
