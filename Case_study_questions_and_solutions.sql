 Case Study Questions

 1. What is the total amount each customer spent at the restaurant?

USE dannys_diner;
SELECT sales.customer_id ,sum(menu.price ) as total_price 
FROM sales 
JOIN menu 
on sales.product_id=menu.product_id
GROUP BY sales.customer_id ;

Answer :
# customer_id	total_price
A	76
B	74
C	36


-- 2. How many days has each customer visited the restaurant?

SELECT customer_id,COUNT(DISTINCT order_date) as Days_Visited
FROM sales
GROUP BY customer_id ;

Answer:
# customer_id	Days_Visited
A	4
B	6
C	2


-- 3. What was the first item from the menu purchased by each customer?

WITH order_firstitem AS
(
SELECT  customer_id, order_date, product_name  ,
DENSE_RANK() OVER (PARTITION BY customer_id order by order_date )AS RANKS
FROM sales join menu
on sales .product_id=menu.product_id 
)
SELECT customer_id ,product_name
FROM order_firstitem
WHERE RANKS =1
GROUP BY customer_id ,product_name;

Answer:
# customer_id	product_name
A	sushi
A	curry
B	curry
C	ramen


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT COUNT(sales.product_id) as most_purchased,product_name
FROM sales join  menu
on sales.product_id=menu.product_id
GROUP BY  product_name
order by most_purchased DESC
LIMIT 1;

Answer:
# most_purchased	product_name
8	ramen


-- 5. Which item was the most popular for each customer?

WITH Fav_item AS
(
SELECT customer_id,product_name,count(menu.product_id) as order_count,
DENSE_RANK() OVER(PARTITION BY customer_id  ORDER BY count(customer_id) DESC)AS RANKS
FROM sales JOIN menu 
on sales.product_id=menu.product_id
GROUP BY product_name,customer_id
)
SELECT customer_id,product_name,order_count
From Fav_item 
where RANKS=1;

Answer:
# customer_id	product_name	order_count
A	ramen	3
B	curry	2
B	sushi	2
B	ramen	2
C	ramen	3


-- 6. Which item was purchased first by the customer after they became a member?

WITH member_first_purchase AS
(SELECT sales.customer_id,join_date,order_date,product_id,
DENSE_RANK () OVER (PARTITION BY customer_id ORDER BY order_date) AS Ranks
FROM Sales 
JOIN members ON 
sales .customer_id =members.customer_id
WHERE order_date >= join_date
)
SELECT customer_id ,order_date,menu.product_name
from member_first_purchase JOIN menu
ON member_first_purchase.product_id = menu.product_id
where Ranks =1
Order by Customer_id ASC;

Answer:
# customer_id	order_date	product_name
A	2021-01-07	curry
B	2021-01-11	sushi


-- 7. Which item was purchased just before the customer became a member?

WITH member_first_purchase AS
(SELECT sales.customer_id,join_date,order_date,product_id,
DENSE_RANK () OVER (PARTITION BY customer_id ORDER BY order_date) AS Ranks
FROM Sales 
JOIN members ON 
sales .customer_id =members.customer_id
WHERE order_date < join_date
)
SELECT customer_id ,order_date,menu.product_name
from member_first_purchase JOIN menu
ON member_first_purchase.product_id = menu.product_id
where Ranks =1
Order by Customer_id ASC;

Answer:
# customer_id	order_date	product_name
A	2021-01-01	sushi
A	2021-01-01	curry
B	2021-01-01	curry


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT members.customer_id,COUNT(DISTINCT menu .product_id) as total_item,sum(price) as Total_price
FROM sales join menu
on sales.product_id =menu.product_id
join members 
on sales.customer_id=members.customer_id
where sales.order_date < join_date
group by members.customer_id;

Answer:
# customer_id	total_item	Total_price
A	2	25
B	2	40


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH  price_point AS
(SELECT * ,
CASE WHEN product_id =1 THEN PRICE *20
ELSE price*10
END AS points
FROM menu )
SELECT sales.customer_id, SUM(points) as total_point
FROM price_point
JOIN sales
ON sales.product_id=price_point.product_id
GROUP BY  sales.customer_id;

Answer :
# customer_id	total_point
A	860
B	940
C	360


10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,not just sushi - how many points do customer A and B have at the end of January?

SELECT sales.customer_id,
	SUM(
		CASE
  		WHEN menu.product_name = 'sushi' THEN 20 * price
		WHEN order_date BETWEEN '2021-01-07' AND '2021-01-15' THEN 20 * price
  		ELSE 10 * PRICE
		END
	) AS Points
	FROM sales
    	JOIN menu
    	ON sales.product_id = menu.product_id
    	JOIN members
    	ON members.customer_id = sales.customer_id
	GROUP BY
	sales.customer_id
	ORDER BY
	sales.customer_id;
	
Answer :
# customer_id	Points
A	1370
B	940


