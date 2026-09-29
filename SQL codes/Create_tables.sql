SELECT DATABASE();

USE Olist_db;

-- Creating tables 

CREATE TABLE customer_db(
	customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code INT,
    customer_city VARCHAR(50),
    customer_state VARCHAR(20)
);

-- 99441 rows
SELECT COUNT(*) FROM customer_db;

-- Creating geolocation table

CREATE TABLE geolocation_table(
	zip_code INT,
    geolocation_lat DECIMAL(9,6),
    geolocation_lng DECIMAL(9,6),
    city VARCHAR(50),
    state VARCHAR(20)
);

-- 106019 rows
SELECT COUNT(*) FROM geolocation_table;

CREATE TABLE order_items_table(
	order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATE,
    price DECIMAL(10,3),
    freight_value DECIMAL(10,3),
    
    PRIMARY KEY(order_id,order_item_id)
);

-- 112650 rows
SELECT COUNT(*) FROM order_items_table;

CREATE TABLE order_payment_table(
	order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,3),
    
    PRIMARY KEY(order_id, payment_sequential)
);

-- 103886 rows
SELECT COUNT(*) FROM order_payment_table;

CREATE TABLE orders_dataset(
	order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_date DATETIME NULL,
    order_approve_date DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NULL,
    
    PRIMARY KEY (order_id,customer_id)
);

-- 96461 rows
SELECT COUNT(*) FROM orders_dataset;


CREATE TABLE product_table(
	product_id VARCHAR(50), 
    product_category_name VARCHAR(100),
    product_name_length INT,
	product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
	product_length_cm INT,
    product_height_cm INT,
    product_width_cm int,
    
    CONSTRAINT product_key PRIMARY KEY (product_id)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/rachelthaw/Downloads/archive-3/olist_products_dataset.csv'
INTO TABLE product_table
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_category_name, @product_name_length, @product_description_length, 
 @product_photos_qty, @product_weight_g, @product_length_cm, @product_height_cm, @product_width_cm)
SET
  product_name_length = NULLIF(@product_name_length, ''),
  product_description_length = NULLIF(@product_description_length, ''),
  product_photos_qty = NULLIF(@product_photos_qty, ''),
  product_weight_g = NULLIF(@product_weight_g, ''),
  product_length_cm = NULLIF(@product_length_cm, ''),
  product_height_cm = NULLIF(@product_height_cm, ''),
  product_width_cm = NULLIF(@product_width_cm, '');
  

CREATE TABLE order_reviews_table(
	review_id VARCHAR(50),
    order_id VARCHAR(50) REFERENCES orders_dataset (order_id),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message VARCHAR(500),
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP 
);


LOAD DATA LOCAL INFILE '/Users/rachelthaw/Downloads/archive-3/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews_table
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(review_id, order_id, @review_score, @review_comment_title, 
 @review_comment_message, @review_creation_date, @review_answer_timestamp)
SET
  review_score = NULLIF(@review_score, ''),
  review_comment_title = NULLIF(@review_comment_title, ''),
  review_comment_message = NULLIF(@review_comment_message, ''),
  review_creation_date = NULLIF(@review_creation_date, ''),
  review_answer_timestamp = NULLIF(@review_answer_timestamp, '');

-- 99222 rows were imported
SELECT COUNT(*) FROM order_reviews_table;


CREATE TABLE sellers_table(
	seller_id VARCHAR(50),
    seller_zip_code CHAR(10),
    seller_city VARCHAR(50),
    seller_state VARCHAR(10),
    
    CONSTRAINT seller_key PRIMARY KEY (seller_id)
);

LOAD DATA LOCAL INFILE '/Users/rachelthaw/Downloads/archive-3/olist_sellers_dataset.csv'
INTO TABLE sellers_table
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(seller_id, @seller_zip_code, @seller_city, @seller_state)
SET
  seller_zip_code = NULLIF(@seller_zip_code, ''),
  seller_city = NULLIF(@seller_city, ''),
  seller_state = NULLIF(@seller_state, '');


--  3095 rows are imported
SELECT COUNT(*) FROM sellers_table;

CREATE TABLE product_category_name_translation(
	product_category_name VARCHAR(50),
    product_category_name_english VARCHAR(50)
);

















