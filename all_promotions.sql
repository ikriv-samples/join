USE brands_db;
SELECT b.name, p.description, p.start_date, p.end_date
FROM brands b
LEFT JOIN promotions p 
ON b.id = p.brand_id 
