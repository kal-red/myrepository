create database pizza_hut;

create table pizza_type(
pizza_type_id varchar(200) primary key,
name varchar (200),
category varchar (200),
ingredients varchar (200)
);

create table pizza(
pizza_id varchar (200),
pizza_type_id varchar (200),
size varchar (200),
price int,
foreign key(pizza_type_id) references pizza_type(pizza_type_id)
);

create table orders(
order_id int primary key,
order_date date,
order_time time
);

create table order_details(
order_details_id int primary key,
order_id int,
pizza_id varchar(200),
quantity int,
foreign key(pizza_id) references pizza(pizza_id),
foreign key(order_id) references orders(order_id)
);


-- 1. Retrieve the total number of orders placed.

select count(*) as total_orders
from orders;

-- 2. Calculate the total revenue generated from pizza sales.

select sum(price) as total_revenue
from pizza
join orders;

-- 3. Identify the highest-priced pizza.

select *
from pizza
order by price desc
limit 1;

-- 4. Identify the most common pizza size ordered.

select size, count(*) as order_count
from pizza
join order_details
on pizza.pizza_id = order_details.pizza_id
group by size
order by order_count desc
limit 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.

select pt.name, sum(quantity) as qty
from pizza_type pt
join pizza p 
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.pizza_type_id
order by qty desc
limit 5;

-- 6. Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, sum(quantity) as orders
from orders o
join order_details od
on o.order_id=od.order_id
group by hour;

-- 7. calculate the average number of pizzas ordered per day.

select avg(daily_total) as avg_pizzas_per_day
from(
     select sum(od.quantity) daily_total
     from orders o
     join order_details od
     on o.order_id=od.order_id
     group by o.order_date
) as daily_orders;

-- 8. Determine the top 3 most ordered pizza types based on revenue.

select pt.name, sum(quantity*p.price) as revenue
from pizza_type pt
join pizza p
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.name
order by revenue desc
limit 3;

-- 9. Calculate the percentage contribution of each pizza type to total revenue.

select pt.name, 
	   sum(od.quantity * p.price) as total_revenue,
       (sum(od.quantity * p.price)/(select sum(od.quantity * p.price)
                                   from order_details od
                                   join pizza p
                                   on od.pizza_id=p.pizza_id)) * 100 as revenue_percentage
from pizza_type pt
join pizza p
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.name
order by revenue_percentage desc;

-- 10. Analyze the cumulative revenue generated over time.

select o.order_date, sum(p.price*od.quantity) as daily_revenue,
       sum(sum(p.price*od.quantity)) over (order by o.order_date) as cumulative_revenue
from pizza p
join order_details od
on p.pizza_id=od.pizza_id
join orders o
on o.order_id=od.order_id
group by o.order_date
order by o.order_date;

-- 11. Determine the top 3 most ordered pizza types based on revenue for each pizza category.


with pizza_revenue as (
     select pt.category, pt.name as pizza_name, sum(p.price * od.quantity) as total_revenue, rank() over (partition by pt.category order by sum(p.price * od.quantity) desc) as Ranking
from pizza_type pt
join pizza p
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.name, pt.category
)
select category, pizza_name, total_revenue, ranking
from pizza_revenue
where ranking <=3
order by category, ranking;