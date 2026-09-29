SELECT * FROM Olist_db.product_table;

-- olist_products_dataset with the "product_category_name_english"
Create view product_new_table As
Select 
	p.product_id,
    p.product_category_name,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    
	pt.product_category_name_english
    
From product_table p
Left Join product_category_name_translation pt
	On p.product_category_name = pt.product_category_name;
    

Select * from product_new_table;