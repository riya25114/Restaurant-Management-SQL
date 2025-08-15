-- RESTAURANT MANAGEMENT SYSTEM

-- 1. Drop and create database
DROP DATABASE IF EXISTS RestaurantDB;
CREATE DATABASE RestaurantDB;
USE RestaurantDB;

-- 2. Tables

-- Customers table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Menu Categories
CREATE TABLE Menu_Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

-- Menu Items
CREATE TABLE Menu_Items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    availability BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES Menu_Categories(category_id)
);

-- Orders
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    table_number INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending','Served','Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order Items
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    item_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (item_id) REFERENCES Menu_Items(item_id)
);

-- Payments
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Cash','Card','UPI','Bank Transfer'),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Staff
CREATE TABLE Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role ENUM('Chef','Waiter','Manager','Cleaner'),
    phone VARCHAR(15)
);

-- Reservations
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    reservation_date DATE NOT NULL,
    table_number INT,
    guests INT CHECK (guests > 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- 3. Sample Data

INSERT INTO Customers (name, email, phone) VALUES
('Ravi Kumar', 'ravi@example.com', '9876543210'),
('Anjali Sharma', 'anjali@example.com', '9123456780'),
('Vikram Singh', 'vikram@example.com', '9988776655');

INSERT INTO Menu_Categories (category_name) VALUES
('Starters'),
('Main Course'),
('Desserts'),
('Beverages');

INSERT INTO Menu_Items (name, category_id, price) VALUES
('Paneer Tikka', 1, 250.00),
('Chicken Biryani', 2, 350.00),
('Chocolate Cake', 3, 150.00),
('Mango Shake', 4, 120.00);

INSERT INTO Orders (customer_id, table_number, status) VALUES
(1, 5, 'Served'),
(2, 3, 'Pending'),
(3, 1, 'Served');

INSERT INTO Order_Items (order_id, item_id, quantity, unit_price) VALUES
(1, 1, 2, 250.00),
(1, 4, 1, 120.00),
(2, 2, 1, 350.00),
(3, 3, 3, 150.00);

INSERT INTO Payments (order_id, amount, payment_method) VALUES
(1, 620.00, 'UPI'),
(3, 450.00, 'Cash');

INSERT INTO Staff (name, role, phone) VALUES
('Suresh', 'Chef', '9812345678'),
('Meena', 'Waiter', '9823456781'),
('Raj', 'Manager', '9834567890');

INSERT INTO Reservations (customer_id, reservation_date, table_number, guests) VALUES
(1, '2025-08-16', 5, 4),
(2, '2025-08-17', 3, 2);

-- 4. Trigger: Auto-calculate payment when order is marked Served

DELIMITER //
CREATE TRIGGER calculate_payment_after_served
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'Served' THEN
        INSERT INTO Payments (order_id, amount, payment_method)
        SELECT 
            NEW.order_id, 
            SUM(oi.quantity * oi.unit_price), 
            'Cash'
        FROM Order_Items oi
        WHERE oi.order_id = NEW.order_id;
    END IF;
END;
//
DELIMITER ;

-- 5. View: Daily Sales Report
CREATE VIEW daily_sales_report AS
SELECT 
    DATE(o.order_date) AS date,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
WHERE o.status = 'Served'
GROUP BY date
ORDER BY date DESC;

-- 6. Stored Procedure: Get Top N Selling Dishes
DELIMITER //
CREATE PROCEDURE get_top_dishes(IN top_n INT)
BEGIN
    SELECT 
        mi.name, 
        SUM(oi.quantity) AS total_sold
    FROM Order_Items oi
    JOIN Menu_Items mi ON oi.item_id = mi.item_id
    GROUP BY mi.name
    ORDER BY total_sold DESC
    LIMIT top_n;
END;
//
DELIMITER ;

-- 7. Example Queries

-- Top 3 dishes
CALL get_top_dishes(3);

-- Daily sales report
SELECT * FROM daily_sales_report;

-- Reservations for tomorrow
SELECT c.name, r.table_number, r.guests
FROM Reservations r
JOIN Customers c ON r.customer_id = c.customer_id
WHERE r.reservation_date = CURDATE() + INTERVAL 1 DAY;
