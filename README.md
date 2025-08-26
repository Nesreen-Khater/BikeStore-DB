# 🚲 SQL BikeStores Analysis



## 📌 Project Overview

This project contains a collection of SQL queries applied on the BikeStores database.
The aim is to demonstrate proficiency in SQL by covering different topics such as joins, aggregations, subqueries, common table expressions (CTEs), and window functions.

## 🗄️ Database

The project is based on the BikeStores sample database.
It contains:

Sales data → customers, orders, stores, staffs

Production data → products, brands, categories 


## ✅ Topics Covered

Basic SQL Queries → SELECT, WHERE, ORDER BY

JOINs → INNER JOIN, LEFT JOIN, multi-table joins

Aggregate Functions → SUM, COUNT, AVG, MIN, MAX

Grouping → GROUP BY + HAVING

Subqueries → WHERE, EXISTS, IN

CTEs → simplify complex queries

Window Functions:

Ranking → RANK(), DENSE_RANK(), ROW_NUMBER()

Aggregates → Running totals, moving averages

Navigation → LAG(), LEAD()

## 🗺️ Database Physical Diagram
<img width="616" height="566" alt="BikeStore DB Diagram" src="https://github.com/user-attachments/assets/c3dbe82c-15b7-4cfc-8fd4-712478033b20" />


## 📌 Example Queries

🔹 Products priced above average
SELECT P.product_id, 
       P.product_name, 
       P.list_price,  
       (SELECT AVG(list_price) FROM production.products) AS avg_price,
       P.list_price - (SELECT AVG(list_price) FROM production.products) AS price_diff
FROM production.products P
WHERE P.list_price >= (SELECT AVG(list_price) FROM production.products)
ORDER BY P.list_price DESC;

🔹 Top 3 best-selling products in each category
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



## 🚀 How to Use


Restore the BikeStores.bak database in SQL Server.

Open the BikeStores Queries.sql file in SSMS.

Run the queries one by one to explore the analysis.


## 📈 Key Insights


Products priced higher than the global average

Customers with more than 3 orders

Staff sales compared to store averages

Running totals and moving averages of sales

Top 3 products per category

Orders vs. previous/next order for each customer


## 🛠️ Skills Demonstrated

SQL, Joins, Aggregations, Subqueries, CTEs, Window Functions, Data Analysis with SQL
