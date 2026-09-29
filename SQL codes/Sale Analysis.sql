Use Olist_db;

-- 1. Find customers whose orders had a total value above average

CREATE VIEW high_value_orders AS
Select customer_id,order_id
From orders_table
Where order_id In(
	Select order_id
    From order_items_table
    Group By order_id
    Having Sum(price) > (
		Select Avg(price) from order_items_table
    )
);

-- Checking duplicate customer_id
Select 
	Count(*) As Total,
	Count(Distinct customer_id) As unique_customer
From high_value_orders;

Select customer_id, Count(customer_id) as order_count
From high_value_orders 
Group By customer_id
Having customer_id >1
Order By order_count Desc;


-- Find products that were never ordered

Select product_id
From order_items_table
Where product_id Not In(
	Select distinct(product_id)
    From product_table
);


-- Find Top 10 best seller products by Quantity Sold

Select * from order_items_table;

Select 
	oi.product_id,
    product_category_name, 
    count(order_item_id) As units_sold
From order_items_table oi
Join product_table p On oi.product_id = p.product_id
Group By oi.product_id, p.product_category_name
Order by units_sold Desc;


-- Find Top 10 best selling product category by price
Select category,total_sales
From(
	Select 
		p.product_category_name_english As category, 
		sum(oi.price) As total_sales
	From order_items_table oi
	Join product_new_table p 
		On p.product_id = oi.product_id
	Group By p.product_category_name_english) As category_sales
Where total_sales >10000
Order By total_sales DESC;
    

-- Overall average item price per each order
Select 
	order_id,
    sum(price) As order_total,
    (Select avg(price) From order_items_table) As avg_order_price
From order_items_table
Group By order_id;


-- Which cities and states have the most total sales 
Select 
	c.customer_city As city,
    c.customer_state As State,
	sum(oi.price) As total_sales_per_city
From order_items_table oi
Join orders_table o 
	On o.order_id = oi.order_id
Join customers_table c 
	On o.customer_id = c.customer_id
Where o.order_status = 'delivered'
Group By c.customer_city, c.customer_state
Order By total_sales_per_city DESC;

-- Best seller products per cities and states
Select 
	oi.product_id,
    count(oi.order_item_id) As order_count,
    p.product_category_name_english As category_name
From order_items_table oi
Join product_new_table p
	On oi.product_id = p.product_id
Join orders_table o
	On oi.order_id = o.order_id
Where o.order_status = 'delivered'
Group By p.product_category_name_english, oi.product_id
Order By order_count DESC;

    
-- Which sellers have the most sales:

Select 
	oi.seller_id,
    sum(oi.price) As total_sales_per_seller
From order_items_table oi
Join orders_table o
	On oi.order_id = o.order_id
Where o.order_status = 'delivered'
Group By seller_id
Order By total_sales_per_seller DESC;

    






















