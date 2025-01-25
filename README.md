# Pizza Sales Analysis SQL Project

## Project Overview

**Project Title**: Pizza Sales Analysis  

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze pizza sales data. The project involves setting up a pizza sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a pizza sales database**: Create and populate a pizzahut database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `pizzahut`.
- **Table Creation**: A table named `orders` & `order_details` is created to store the sales data. The `orders` table structure includes columns for order_id  (PTIMARY KEY), order_date, order_time. And the `orders_details` table structure includes columns for order_details_id (PRIMARY KEY), order_id, pizza_id, quantity.
- **Import Data**: Import CSV files of pizzas, pizza_types & after creating `orders` & `orders_details` import CSV files of orders & orders_details.


```sql
CREATE DATABASE pizzahut;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

sql
3. **Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

-- 1). Retrieve the total number of orders placed --
``` SQL
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;
```


-- 2). Calculate the toal quantity & total revenue generated from pizza sales --
``` SQL
SELECT 
    SUM(orders_details.quantity) AS total_quantity,
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
```

-- 3). Identify the highest-priced pizza --
``` SQL
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
```


-- 4). Identify the most common pizza size ordered --
```SQL
SELECT 
    pizzas.size, COUNT(orders_details.order_id) AS no_of_ordered
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY no_of_ordered DESC
LIMIT 1;
```

-- 5). List the top 5 most ordered pizza types along with their quantities --
```SQL
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS quantity_sales,
    COUNT(orders_details.order_id) AS no_of_ordered
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY no_of_ordered DESC
LIMIT 5;
```

-- 6). Join the necessary tables to find the total quantity of each pizza category ordered --
```sql
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity_ordered
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY quantity_ordered DESC;
```

-- 7). Determine the distribution of orders by hour of the day --
```sql
SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY Hour;
```

-- 8). Join relevant tables to find the category-wise distribution of pizzas --
``` sql
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
```

-- 9). Group the orders by date and calculate the average number of pizzas ordered per day --
```sql
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders_details.order_id = orders.order_id
    GROUP BY orders.order_date) AS quantity_order;
```

-- 10). Determine the top 3 most ordered pizza types based on revenue --
```sql
SELECT 
    pizza_types.name,
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;
```


-- 11). Calculate the percentage contribution of each pizza type to total revenue --
```SQL
SELECT 
    pizza_types.pizza_type_id,
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Revenue,
    CONCAT(ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                            SUM(orders_details.quantity * pizzas.price) AS total_sales
                        FROM
                            orders_details
                                JOIN
                            pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100,
                    2),
            '%') AS contribution_in_revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.pizza_type_id
ORDER BY contribution_in_revenue DESC;
```


-- 12). Analyze the cumulative revenue generated over time --
```SQL
SELECT 
		order_date, 
        Revenue AS Daily_revenue ,
        ROUND(SUM(Revenue) OVER(ORDER BY order_date),2) AS Cumulative_revenue
FROM
		(SELECT 
				orders.order_date, 
				ROUND(SUM(orders_details.quantity*pizzas.price),2) AS Revenue
FROM 
	orders_details 
		JOIN 
			pizzas ON pizzas.pizza_id = orders_details.pizza_id
		JOIN 
			orders ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS sales;
```



-- 13). Determine the top 3 most ordered pizza types based on revenue for each pizza category --
```SQL
SELECT 
		category, 
		name, 
        Revenue
FROM
		(SELECT 
				category, 
                name, 
                Revenue, 
                RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS RNK
			FROM
					(SELECT 
							pizza_types.category, 
                            pizza_types.name, 
                            ROUND(SUM(orders_details.quantity*pizzas.price),2) AS Revenue
FROM orders_details
		JOIN 
			pizzas ON pizzas.pizza_id = orders_details.pizza_id
		JOIN
			pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category, pizza_types.name)AS a) AS b
WHERE RNK <= 3;
```

## Findings

- **High-Value Transactions**: High prized value pizza and most ordered pizzas generates high spends from each customer.
- **Sales Trends**: Average quantity sold per day is 134 and most high timings of sales are 12:00 PM to 1:00 PM and 5:00 PM to 7:00 PM.
- **Customer Insights**: The analysis identifies the top-spending customers on the most popular product categories are Chickens

## Reports

- **Sales Summary**: A detailed report summarizing total sales and category performance.
- **Trend Analysis**: Insights into sales trends across different timings.
- **Customer Insights**: Top spending category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.



For more content on SQL, data analysis, and other data-related, make sure to follow me on Linkedin:

- **LinkedIn**: [Connect with me professionally](www.linkedin.com/in/tarun-mahor-1735a61a7)

Thank you for your support, and I look forward to connecting with you!
