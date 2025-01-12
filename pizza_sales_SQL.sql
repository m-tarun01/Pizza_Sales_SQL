CREATE DATABASE pizzahut;
use pizzahut;

CREATE TABLE orders(
order_id int NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
PRIMARY KEY(order_id)
);

CREATE TABLE orders_details(
order_details_id INT NOT NULL,
order_id int NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id)
);

-- 1). Retrieve the total number of orders placed --
SELECT count(*) AS total_orders FROM orders;


-- 2). Calculate the total revenue generated from pizza sales --
SELECT ROUND(SUM(orders_details.quantity*pizzas.price),2) AS total_revenue
FROM orders_details
JOIN pizzas
ON pizzas.pizza_id = orders_details.pizza_id;


-- 3). Identify the highest-priced pizza --
SELECT pizza_types.name, pizzas.price
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
order by pizzas.price DESC
LIMIT 1;


-- 4). Identify the most common pizza size ordered --
SELECT pizzas.size, COUNT(orders_details.order_id) AS no_of_ordered
FROM orders_details JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY no_of_ordered DESC
LIMIT 1;


-- 5). List the top 5 most ordered pizza types along with their quantities --
SELECT pizza_types.name, SUM(orders_details.quantity) AS quantity_sales, COUNT(orders_details.order_id) AS no_of_ordered
FROM orders_details
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY no_of_ordered DESC
LIMIT 5;


-- 6). Join the necessary tables to find the total quantity of each pizza category ordered --
SELECT pizza_types.category, SUM(orders_details.quantity) AS quantity_ordered
FROM orders_details
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY quantity_ordered DESC;


-- 7). Determine the distribution of orders by hour of the day --
SELECT HOUR(order_time) AS Hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY Hour;


-- 8). Join relevant tables to find the category-wise distribution of pizzas --
SELECT category, COUNT(name) FROM pizza_types
GROUP BY category;


-- 9). Group the orders by date and calculate the average number of pizzas ordered per day --
SELECT ROUND(AVG(quantity),0)
FROM
(SELECT orders.order_date, SUM(orders_details.quantity) AS quantity
FROM orders JOIN orders_details
ON orders_details.order_id = orders.order_id
GROUP BY orders.order_date) AS quantity_order;


-- 10). Determine the top 3 most ordered pizza types based on revenue --
SELECT pizza_types.name, ROUND(SUM(orders_details.quantity*pizzas.price),2) AS Revenue
FROM orders_details JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;


-- 11). Calculate the percentage contribution of each pizza type to total revenue --
SELECT pizza_types.pizza_type_id, ROUND(SUM(orders_details.quantity*pizzas.price),2)AS Revenue, CONCAT(ROUND(SUM(orders_details.quantity*pizzas.price) /(SELECT SUM(orders_details.quantity*pizzas.price) AS total_sales
FROM orders_details
JOIN pizzas
ON pizzas.pizza_id = orders_details.pizza_id)*100,2), '%') AS contribution_in_revenue
FROM orders_details JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.pizza_type_id
ORDER BY contribution_in_revenue DESC;


-- 12). Analyze the cumulative revenue generated over time --

SELECT order_date, Revenue AS Daily_revenue ,ROUND(SUM(Revenue) OVER(ORDER BY order_date),2) AS Cumulative_revenue
FROM
(SELECT orders.order_date, ROUND(SUM(orders_details.quantity*pizzas.price),2) AS Revenue
FROM orders_details JOIN pizzas
ON pizzas.pizza_id = orders_details.pizza_id
JOIN orders ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS sales;


-- 13). Determine the top 3 most ordered pizza types based on revenue for each pizza category --
SELECT category, name, Revenue
FROM
(SELECT category, name, Revenue, RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS RNK
FROM
(SELECT pizza_types.category, pizza_types.name, ROUND(SUM(orders_details.quantity*pizzas.price),2) AS Revenue
FROM orders_details
JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category, pizza_types.name)AS a) AS b
WHERE RNK <= 3;



