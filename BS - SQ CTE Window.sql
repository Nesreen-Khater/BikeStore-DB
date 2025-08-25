-------------------------------- Subqueries - CTEs - Window --------------------


                                          USE BikeStores

-- (1) Which of our products are priced significantly higher than our average ? 
--    How much does our most expensive product deviate from our average ? 

SELECT P.PRODUCT_ID , 
       P.PRODUCT_NAME , 
       p.list_price ,  
	   ( SELECT AVG (P.LIST_PRICE) FROM PRODUCTION.products P ) AS AVG_PRICE ,
       p.list_price - ( SELECT AVG (P.LIST_PRICE) FROM PRODUCTION.products P ) AS PRICE_DIFF

FROM production.products P 
WHERE p.list_price >= ( SELECT AVG (P.LIST_PRICE) 
                        FROM PRODUCTION.products P ) 
ORDER BY P.list_price DESC 




--(2) Find all products from customers in New York city ?

SELECT P.PRODUCT_NAME , O.ORDER_ID ,  O.CUSTOMER_ID 
FROM PRODUCTION.PRODUCTS P JOIN SALES.order_items OI ON P.product_id = OI.product_id 
                           JOIN SALES.ORDERS O ON O.ORDER_ID = OI.ORDER_ID
WHERE O.CUSTOMER_ID IN (SELECT C.CUSTOMER_ID FROM SALES.customers C WHERE C.CITY = 'New York'  )




--(3)Finds all customers who placed orders in 2017 

SELECT  C.CUSTOMER_ID , (C.FIRST_NAME + ' ' + C.LAST_NAME ) AS CUSTOMER_NAME 
FROM SALES.CUSTOMERS C
WHERE  EXISTS ( SELECT O.CUSTOMER_ID FROM SALES.ORDERS O
						  WHERE O.CUSTOMER_ID = C.customer_id and  YEAR (O.ORDER_DATE ) = 2017  )





-- (4) Find products that haven't been ordered ? 

SELECT P.PRODUCT_NAME 
FROM PRODUCTION.PRODUCTS P
WHERE NOT EXISTS ( SELECT O.ORDER_ID FROM SALES.ORDER_ITEMS O WHERE O.product_id = P.product_id )





-- (5) How many customers who made 3 orders or more ? 

WITH CUSTOMERS AS 
(
SELECT C.CUSTOMER_ID , COUNT (ORDER_ID )AS '#ORDERS' 
FROM SALES.CUSTOMERS C JOIN SALES.ORDERS O 
ON C.CUSTOMER_ID = O.CUSTOMER_ID 
GROUP BY C.CUSTOMER_ID 
HAVING COUNT (ORDER_ID ) >= 3 
)
SELECT COUNT ( #ORDERS ) AS NO_OF_CUSTOMERS 
FROM CUSTOMERS 




-- (6) Show brands with average prices higher than the overall average ? 

SELECT  B.brand_name, AVG(P.list_price) AS BRAND_PRICE , avg ( AVG(P.list_price)) OVER () AS OVERALL_AVG 
FROM PRODUCTION.products P
JOIN PRODUCTION.brands B ON P.brand_id = B.brand_id 
GROUP BY B.brand_name
HAVING AVG(P.list_price)  > ( SELECT AVG (LIST_PRICE) FROM production.products ) 





--(7) compare staff sales to store average
with staff_sales AS (
SELECT SF.STORE_ID , CONCAT (SF.FIRST_NAME , ' ' , SF.LAST_NAME ) AS STAFF_NAME, SUM(OI.LIST_PRICE * OI.QUANTITY * (1-OI.DISCOUNT ))  AS T_STAFF_SALES
FROM SALES.staffs SF JOIN SALES.ORDERS O
ON SF.STAFF_ID = O.STAFF_ID 
JOIN SALES.ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID 
GROUP BY SF.STORE_ID , CONCAT (SF.FIRST_NAME , ' ' , SF.LAST_NAME )
)
,
STORE_AVG AS (
SELECT ST.STORE_ID ,ST.STORE_NAME ,  SUM(OI.list_price * OI.quantity * (1 - OI.discount)) / COUNT(DISTINCT O.staff_id) AS avg_st_sales
FROM SALES.STORES ST JOIN SALES.ORDERS O
ON ST.store_id = O.STORE_ID 
JOIN SALES.ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID 
GROUP BY ST.STORE_ID , ST.STORE_NAME 
)

SELECT SA.STORE_NAME , SS.STAFF_NAME, SS.T_STAFF_SALES , SA.AVG_ST_SALES
FROM staff_sales SS JOIN STORE_AVG SA ON SS.store_id = SA.store_id
                     JOIN SALES.STORES SST ON SS.store_id = SST.store_id
ORDER BY SA.store_name , T_STAFF_SALES DESC




-- (8) Which products perform above average in their category ?

WITH CAT_SALES AS (
SELECT C.CATEGORY_NAME , P.PRODUCT_NAME ,  
       SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS PRODUCT_SALES
FROM PRODUCTION.products P JOIN production.categories C
ON P.category_id = C.category_id 
JOIN SALES.order_items OI ON OI.product_id = P.product_id 
GROUP BY  C.CATEGORY_NAME , P.PRODUCT_NAME
)
,
CAT_AVG AS (
SELECT CS.CATEGORY_NAME , CS.PRODUCT_NAME , CS.PRODUCT_SALES, AVG (PRODUCT_SALES) OVER (PARTITION BY CS.CATEGORY_NAME ) AS AVG_CAT
FROM CAT_SALES CS
)
SELECT *
FROM CAT_AVG
WHERE PRODUCT_SALES > AVG_CAT
ORDER BY CATEGORY_NAME, PRODUCT_SALES DESC




-- (9) Which are the top 3 best-selling products in each category ? 

WITH TOP_RANK AS (
SELECT  C.category_name , P.PRODUCT_NAME , SUM (OI.quantity ) AS T_QUANTITY , 
	   DENSE_RANK ()  OVER ( PARTITION BY C.category_name ORDER BY SUM( OI.QUANTITY ) DESC ) AS Q_RANK
FROM production.products P JOIN production.categories C 
ON P.category_id = C.category_id 
JOIN SALES.order_items OI ON OI.product_id = P.product_id 
GROUP BY P.PRODUCT_NAME , C.category_name
)
SELECT *
FROM TOP_RANK
WHERE Q_RANK <= 3





--(10) For each order show how it compares to the pervious and next order from the same customers ?

SELECT ( C.first_name +' ' + C.last_name ) AS CUSTOMER_NAME,
        O.ORDER_ID ,  
		O.ORDER_DATE , 
		LAG (SUM(OI.list_price * OI.quantity * (1 - OI.discount))) OVER ( PARTITION BY ( C.first_name +' ' + C.last_name ) ORDER BY ORDER_DATE ) AS PERVIOUS_ORDER ,
		SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS CUSTOMER_SALES , 
		LEAD (SUM(OI.list_price * OI.quantity * (1 - OI.discount))) OVER ( PARTITION BY ( C.first_name +' ' + C.last_name ) ORDER BY ORDER_DATE ) AS NEXT_ORDER

FROM SALES.CUSTOMERS C JOIN SALES.ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID 
JOIN SALES.order_items OI ON OI.ORDER_id = O.ORDER_id 
GROUP BY ( C.first_name +' ' + C.last_name ) ,  O.ORDER_ID ,  O.ORDER_DATE
ORDER BY ( C.first_name +' ' + C.last_name )





--(11) Calculate a running total sales by month ?

SELECT YEAR (O.ORDER_DATE ) AS YEAR_NAME ,
       MONTH (O.ORDER_DATE ) AS MONTH_NAME , 
      SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS TOTAL_SALES_MONTH ,
	  SUM(SUM(OI.list_price * OI.quantity * (1 - OI.discount))) OVER ( ORDER BY YEAR (O.ORDER_DATE ) , MONTH (O.ORDER_DATE ) ) AS RUNNING_TOTAL 
FROM SALES.ORDERS O JOIN SALES.ORDER_ITEMS OI 
ON O.ORDER_ID = OI.ORDER_ID 
GROUP BY YEAR (O.ORDER_DATE ) , MONTH (O.ORDER_DATE ) 





-- (12) Calculate 3 month average on sales ? 

with month_sales as (
SELECT YEAR (O.ORDER_DATE ) AS YEAR_NAME ,
       MONTH (O.ORDER_DATE ) AS MONTH_NAME , 
      SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS TOTAL_SALES_MONTH 
FROM SALES.ORDERS O JOIN SALES.ORDER_ITEMS OI 
ON O.ORDER_ID = OI.ORDER_ID 
group by YEAR (O.ORDER_DATE ) , MONTH (O.ORDER_DATE )  
)
select YEAR_NAME , 
       MONTH_NAME , 
	   TOTAL_SALES_MONTH , 
	   avg( TOTAL_SALES_MONTH )over  ( order by  YEAR_NAME , MONTH_NAME 
	                          rows between 2 preceding and current row ) as THREE_MONTH_AVG
from month_sales 




















