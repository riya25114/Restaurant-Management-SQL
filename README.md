# Restaurant-Management-SQL

## 📌 Overview
The **Restaurant Management System** is a SQL-based project designed to handle the core operations of a restaurant — from managing customers and menu items to processing orders, payments, staff, and reservations.  
It also includes **triggers**, **views**, and **stored procedures** for automation and reporting.

---

## 🚀 Features
- **Customer Management** – Store customer details with contact info.
- **Menu Management** – Categorize items (Starters, Main Course, Desserts, Beverages).
- **Order Handling** – Manage dine-in orders with table numbers.
- **Inventory-like Sales Tracking** – Order items linked with quantities and prices.
- **Payments** – Automatic payment calculation when order is served.
- **Staff Management** – Store details of chefs, waiters, managers, and cleaners.
- **Reservations** – Book tables for customers with date and guest count.
- **Reports & Analytics** – Daily sales report, top-selling dishes.

---

## 🗂 Database Structure

### **Tables**
1. **Customers** – Stores customer information.
2. **Menu_Categories** – Stores categories for menu items.
3. **Menu_Items** – Stores dish details, linked to categories.
4. **Orders** – Stores customer orders with table numbers and status.
5. **Order_Items** – Stores items in each order with quantity and price.
6. **Payments** – Stores payment details for orders.
7. **Staff** – Stores restaurant staff details and roles.
8. **Reservations** – Stores table reservations.

---

## ⚡ Automated Functionality
### **Trigger**
- `calculate_payment_after_served` – When an order status changes to "Served", the total payment is calculated and inserted into the `Payments` table.

### **View**
- `daily_sales_report` – Shows daily sales revenue and order count.

### **Stored Procedure**
- `get_top_dishes(top_n)` – Returns the top N best-selling dishes.

---

## 📊 Example Queries
```sql
-- Get top 3 dishes by sales
CALL get_top_dishes(3);

-- View daily sales report
SELECT * FROM daily_sales_report;

-- Get tomorrow's reservations
SELECT c.name, r.table_number, r.guests
FROM Reservations r
JOIN Customers c ON r.customer_id = c.customer_id
WHERE r.reservation_date = CURDATE() + INTERVAL 1 DAY;
