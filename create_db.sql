-- Create the database
CREATE DATABASE IF NOT EXISTS brands_db;
USE brands_db;

-- Create the brands table
CREATE TABLE brands (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create the promotions table
CREATE TABLE promotions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    brand_id INT NOT NULL,
    description TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE
);

-- Insert sample data into brands
INSERT INTO brands (name) VALUES 
('ACME'), 
('Road Runner Auto Repair'),
('Bugs Bunny Foods'),
('Daffy Duck Outfitters');

-- Insert sample data into promotions
INSERT INTO promotions (brand_id, description, start_date, end_date) 
VALUES 
(1, '50% off all items', '2024-12-01', '2024-12-31'),
(1, 'Buy one bomb get one free', '2024-12-05', '2024-12-25'),
(3, '50 carrots for $3', '2024-10-05', '2024-10-07'),
(3, '100 carrots for $5', '2024-12-10', '2024-12-15');

-- Query to verify the data
SELECT b.name, p.description, p.start_date, p.end_date
FROM brands b
LEFT JOIN promotions p on b.id = p.brand_id

