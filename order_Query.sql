--drop table data_orders

--select * from data_orders

--find top 10 highest revenues generating products

select top 10 product_id, sum(sale_price) as sales
from data_orders
group by product_id
order by sales desc

-- find top highest selling products in each region
with cte as(
select region, product_id, sum(sale_price) as sales
from data_orders
group by region, product_id)
select * from(
select *
,row_number() over(partition by region order by sales desc) as rn
from cte) as A
where rn <=5

--find month over month growth comparison for 2022 and 2023
with cte as(
select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales  
from data_orders
group by year(order_date), month(order_date))
select order_month
,sum(case when order_year = 2022 then sales else 0 end) as sales_2022
,sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

--for each category which month had the highest sales
with cte as(
select category, year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
from data_orders
group by category, year(order_date), month(order_date))
select * from(
select *
,row_number() over(partition by category order by sales desc) as rn
from cte) as B
where rn = 1

--which sub category had the highest growth by profit in 2023 compare to 2022
with cte as(
select sub_category, year(order_date) as order_year, sum(profit) as order_profit
from data_orders
group by sub_category, year(order_date)
)
--order by order_profit desc
,cte2 as( 
select sub_category
,sum(case when order_year = 2022 then order_profit else 0 end) as profit_2022
,sum(case when order_year = 2023 then order_profit else 0 end) as profit_2023
from cte
group by sub_category
)
select top 1 *
,(profit_2023 - profit_2022)*100/profit_2022 as percent_profit
from cte2
order by percent_profit desc
