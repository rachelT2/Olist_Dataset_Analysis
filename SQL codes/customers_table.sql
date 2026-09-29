SELECT * FROM Olist_db.customers_table;

SELECT distinct customer_city
FROM  customers_table
Where customer_city Like 'sao%';

SELECT count(distinct customer_city)
FROM customers_table;