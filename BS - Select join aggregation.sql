---------------------------------------- Select & Aggregation & Join  -----------------------------------

                                          USE BikeStores

-- 1-get customers names and the order data and the required date --
select distinct o.order_id, (c.first_name + ' ' + c.last_name) as full_name , 
                o.order_date , 
				o.required_date 
from sales.customers as c
inner join sales.orders as o
on c.customer_id = o.customer_id
group by o.order_id , 
         (c.first_name + ' ' + c.last_name) , 
		 o.order_date , 
		 o.required_date   
order by o.order_id



-- 2- display customers names, quantity and the discount -- 
select (c.first_name + ' ' + c.last_name) as full_name  , 
       i.quantity , 
	   i.discount 
from sales.customers as c
inner join sales.orders as o 
on c.customer_id = o.customer_id 
inner join sales.order_items as i 
on o.order_id = i.order_id 



-- 3-Get the store name and the full name of the employee assigned to each store where store id = 1 -- 
select (sf.first_name + ' ' + sf.last_name) as full_name , 
        so.store_id , 
		so.store_name 
from sales.staffs  as sf
inner join sales.stores as so
on sf.store_id = so.store_id and so.store_id = 1 



-- 4-What are the products and the quantity that our customers bought in 2016? -- 
select p.product_name , 
       sum (i.quantity ) as Total_quantity , 
	   year ( o.order_date ) as year 
from production.products as p 
inner join sales.order_items as i
on p.product_id = i.product_id 
inner join sales.orders as o
on i.order_id = o.order_id and year ( o.order_date )= 2016
group by p.product_name , 
         year ( o.order_date )



-- 5-Find out the average order value per customer -- 
/* avg order value per customer = total sales / total orders per each customer
                                  ( list price * quantity * (1-discount ))  / total orders (unique)   */ 
select (c.first_name + ' ' + c.last_name) as full_name , 
       sum (i.quantity ) as total_quantity ,
	   sum (i.list_price ) as total_list_price ,
	   count ( distinct i.order_id ) as total_order , 
	   SUM(i.quantity * i.list_price *  (1 - i.discount)) / count (distinct i.order_id)  as Avg_order_value_per_customer -- cast ( .... as float لتحويل القيمه ل عدد عشري ) -- 
from sales.customers as c
inner join sales.orders as o 
on c.customer_id = o.customer_id
inner join sales.order_items as i 
on o.order_id = i.order_id 
group by (c.first_name + ' ' + c.last_name) 
order by (CAST(SUM(i.quantity * i.list_price *  (1 - i.discount)) AS FLOAT) / count (distinct i.order_id) ) desc



-- 6-Calculate the total sales amount per store  --
select s.store_name , 
       SUM(i.quantity * i.list_price *  (1 - i.discount)) as total_sales 
from sales.stores as s
inner join sales.orders as o 
on s.store_id = o.store_id 
inner join sales.order_items as i 
on o.order_id = i.order_id 
group by store_name 
order by SUM(i.quantity * i.list_price *  (1 - i.discount)) desc 



-- 7-List top-selling products (by quantity) and their total sales amount -- 
select p.product_name , 
       sum (i.quantity ) as Total_quantity ,
	   sum (i.quantity * i.list_price *  (1 - i.discount)) as total_sales 

from sales.order_items as i
inner join production.products  as p
on i.product_id = p.product_id
group by product_name
order by sum (i.quantity ) desc



-- 8-count the number of products in each category --
select category_name ,
       count ( distinct product_id ) as no_of_products 
from production.categories as c 
inner join production.products as p 
on c.category_id = p.category_id 
group by category_name
order by  count ( distinct product_id ) desc



-- 9-List staff members who generated the highest total sales amount   -- 
select (s.first_name + ' ' + s.last_name) as full_name ,
        sum (i.quantity * i.list_price *  (1 - i.discount))   as total_sales
from sales.staffs  as s 
inner join sales.orders as o 
on s.staff_id = o.staff_id 
inner join sales.order_items as i 
on o.order_id = i.order_id 
group by (s.first_name + ' ' + s.last_name)
order by sum (i.quantity * i.list_price *  (1 - i.discount)) desc



-- 10-Identify customers who made the highest number of orders -- 
select (c.first_name + ' ' + c.last_name) as full_name ,
        count ( distinct o.order_id ) as total_order
from sales.customers as c
inner join sales.orders as o 
on c.customer_id = o.customer_id
group by (c.first_name + ' ' + c.last_name)
order by  count ( distinct o.order_id ) desc





