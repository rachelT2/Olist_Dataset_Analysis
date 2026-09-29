-- Created view version of clean_geolocation_table

Use Olist_db;
SELECT * FROM Olist_db.geolocation_table;

-- Checking Geolocation table
SELECT count(distinct zip_code) FROM Olist_db.geolocation_table;

SELECT distinct(city)
From geolocation_table;

-- Fixed Text inconsistency in city Using View
Create Table city_correction(
	city varchar(50),
    clean_city varchar(50)
);

Insert Into city_correction Values
('saopaulo','sao paulo'),
('sp','sao paulo');


Create View clean_geolocation_table As
Select 
	g.zip_code,
    g.geolocation_lat,
    g.geolocation_lng,
    g.state,
    Coalesce(cc.clean_city, Lower(Trim(g.city))) As geolocation_city
From geolocation_table g
Left Join city_correction cc
	On (Lower(Trim(g.city))) = cc.city;
    
    
    



