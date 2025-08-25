🚲 SQL BikeStores Analysis
📌 Project Overview

This project contains a collection of SQL queries applied on the BikeStores database.
The aim is to demonstrate proficiency in SQL by covering different topics such as joins, aggregations, subqueries, common table expressions (CTEs), and window functions.

🗄️ Database

The project is based on the BikeStores sample database
.
It contains sales data (customers, orders, stores, staffs), and production data (products, brands, categories).

✅ Topics Covered

The queries in this project demonstrate:

Basic SQL Queries: SELECT, filtering with WHERE, and sorting with ORDER BY.

JOINs: Inner Join, Left Join, combining multiple tables.

Aggregate Functions: SUM, COUNT, AVG, MIN, MAX.

Grouping: GROUP BY and filtering with HAVING.

Subqueries: Used in WHERE, EXISTS, and IN clauses.

Common Table Expressions (CTEs): Simplifying complex queries.

Window Functions:

Ranking: RANK(), DENSE_RANK(), ROW_NUMBER().

Aggregates: Running totals, moving averages.

Navigation: LAG(), LEAD().

🗺️ Database Physical Diagram
<img width="616" height="566" alt="BikeStore DB Diagram" src="https://github.com/user-attachments/assets/c3dbe82c-15b7-4cfc-8fd4-712478033b20" />


📌 Example Queries
1. Products priced above average
SELECT P.product_id, 
       P.product_name, 
       P.list_price,  
       (SELECT AVG(list_price) FROM production.products) AS avg_price,
       P.list_price - (SELECT AVG(list_price) FROM production.products) AS price_diff
FROM production.products P
WHERE P.list_price >= (SELECT AVG(list_price) FROM production.products)
ORDER BY P.list_price DESC;

2. Top 3 best-selling products in each category
WITH TopRank AS (
    SELECT  C.category_name, 
            P.product_name, 
            SUM(OI.quantity) AS total_quantity, 
            DENSE_RANK() OVER (PARTITION BY C.category_name ORDER BY SUM(OI.quantity) DESC) AS q_rank
    FROM production.products P 
    JOIN production.categories C ON P.category_id = C.category_id
    JOIN sales.order_items OI ON OI.product_id = P.product_id
    GROUP BY P.product_name, C.category_name
)
SELECT *
FROM TopRank
WHERE q_rank <= 3;

📂 Repository Structure
📁 SQL-BikeStores-Analysis
 ┣ 📄 BikeStores Queries.sql     → All SQL queries
 ┣ 📄 BikeStores.bak             → Database backup (optional if you include it)
 ┣ 📄 README.md                  → Project documentation

🚀 How to Use

Restore the BikeStores.bak database in SQL Server.

Open the BikeStores Queries.sql file in SQL Server Management Studio (SSMS).

Run the queries one by one to explore the analysis.

📈 Key Insights from Queries

Products that are priced higher than the global average.

Customers who placed more than 3 orders.

Staff performance compared to store averages.

Running totals and moving averages of sales.

Top 3 products per category.

Orders compared to previous/next orders for each customer.

🛠️ Skills Demonstrated

SQL, Joins, Aggregations, Subqueries, CTEs, Window Functions, Data Analysis with SQL.
