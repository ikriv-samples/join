USE brands_db;
SELECT b.name, p.description, p.start_date, p.end_date
FROM brands b
LEFT JOIN promotions p 
ON b.id = p.brand_id 
WHERE p.start_date BETWEEN DATE'2024-12-05' AND DATE'2024-12-31'
