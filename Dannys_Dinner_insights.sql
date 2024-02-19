use dannys_diner;

select * from sales ;
select * from menu ;
select * from members ;


-- 1.  What is the total amount each customer spent at the restaurant?
select sum(price) , S.product_id , S.customer_id FROM sales S inner join menu m on S.product_id = m.product_id 
group by 2,3;
select sum(price)Total_product_price  , S.customer_id FROM sales S inner join menu m on S.product_id = m.product_id 
group by 2;
-- using case 
SELECT 
    SUM(CASE WHEN S.product_id = m.product_id THEN m.price ELSE 0 END) AS Total_product_price,
    S.customer_id
FROM 
    sales S
INNER JOIN 
    menu m ON S.product_id = m.product_id
GROUP BY 
    S.customer_id;

-- 2. How many days has each customer visited the restaurant?
 
 select count(distinct order_date)days_each_customer_vistited  , customer_id from sales group by 2;
 
 select customer_id ,count(order_date)over(partition by customer_id order by customer_id)days_each_customer_vistited
 from sales ; -- using windows function 
 
 -- 3. What was the first item from the menu purchased by each customer?
 -- own solution assumption (half correct and missed order date coloun)
 select  customer_id ,product_id , product_name, as_first_item_purchased from
( select S.customer_id , M.product_id , M.product_name , row_number() over(partition by S.customer_id ) as as_first_item_purchased
 from menu M inner join sales S on M.product_id = S.product_id
 order by customer_id)T where as_first_item_purchased = 1;

-- correct solution online (order_date_is_taken)
select customer_id , order_date ,product_name from (SELECT 
    sales.customer_id, 
    sales.order_date, 
    menu.product_name,
    DENSE_RANK() OVER(
      PARTITION BY sales.customer_id 
      ORDER BY sales.order_date) AS rankK
  FROM dannys_diner.sales
  JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id)T
    where rankk = 1 group by 1,2,3;
    
-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers
-- own solution correct 
select product_name , sum(county) as most_purchased_product  from
(select  S.customer_id , count(S.product_id)as county, M.product_name from  sales S  inner join menu M 
on M.product_id = S.product_id group by 1,3)T 
group by 1 order by 2 desc limit 1 ; 
-- online solution correct 
SELECT 
  M.product_name,
  COUNT(S.product_id) AS most_purchased_item
FROM  sales S
JOIN menu M on S.product_id = M.product_id 
GROUP BY M.product_name 
ORDER BY most_purchased_item DESC
LIMIT 1;

-- 5.Which item was the most popular for each customer?
-- my solution answer correct .
select  product_name , customer_id  from
(select count(S.product_id)as county ,S.order_date,M.product_name, S.customer_id   from 
 menu M inner join sales S on M.product_id = S.product_id  
 group by 2,3,4)t
 where county > 1 ;
 
 -- online solution answer correct (better method to get this answer )
 WITH most_popular AS (
  SELECT 
    sales.customer_id, 
    menu.product_name, 
    COUNT(menu.product_id) AS order_count,
    DENSE_RANK() OVER(
      PARTITION BY sales.customer_id 
      ORDER BY COUNT(sales.customer_id) DESC) AS rankk
  FROM dannys_diner.menu
  JOIN dannys_diner.sales
    ON menu.product_id = sales.product_id
  GROUP BY sales.customer_id, menu.product_name
)

SELECT 
  customer_id, 
  product_name, 
  order_count
FROM most_popular 
WHERE rankk = 1;

-- 6. Which item was purchased first by the customer after they became a member?

-- my solution . little complex 
select product_name , customer_id from 
(select COUNT(product_name) ,product_name, customer_id , order_date , 
dense_rank () over(partition by product_name)
  from
(select S.product_id, M.product_name ,B.join_date , S.order_date ,
 B.customer_id  from  sales S 
 inner join members B on S.customer_id = B.customer_id 
 inner join menu M on S.product_id = M.product_id )T
 where order_date > '2021-01-09' 
 GROUP BY 2,3,4
 )x where order_date  between '2021-01-10' and '2021-01-11' ;
 
 -- online solution simpler one and better 
 WITH joined_as_member AS (
  SELECT
    members.customer_id, 
    sales.product_id,
    ROW_NUMBER() OVER(
      PARTITION BY members.customer_id
      ORDER BY sales.order_date) AS row_num
  FROM dannys_diner.members
  JOIN dannys_diner.sales
    ON members.customer_id = sales.customer_id
    AND sales.order_date > members.join_date
)

SELECT 
  customer_id, 
  product_name 
FROM joined_as_member
JOIN dannys_diner.menu
  ON joined_as_member.product_id = menu.product_id
WHERE row_num = 1
ORDER BY customer_id ASC;

-- 7. Which item was purchased just before the customer became a member?
-- my solution 
select product_name , customer_id from
(select COUNT(product_name) ,product_name, customer_id , order_date , 
dense_rank () over(partition by product_name)
  from
(select S.product_id, M.product_name ,B.join_date , S.order_date ,
 B.customer_id  from  sales S 
 inner join members B on S.customer_id = B.customer_id 
 inner join menu M on S.product_id = M.product_id )T
 where order_date < '2021-01-09' 
 GROUP BY 2,3,4 
 )x where order_date between '2021-01-04' and '2021-01-07';
 
 -- online solution for better and simpler way 
 
 WITH purchased_prior_member AS (
  SELECT 
    members.customer_id, 
    sales.product_id,
    ROW_NUMBER() OVER(
       PARTITION BY members.customer_id
       ORDER BY sales.order_date DESC) AS rankk
  FROM dannys_diner.members
  JOIN dannys_diner.sales
    ON members.customer_id = sales.customer_id
    AND sales.order_date < members.join_date
)

SELECT 
  p_member.customer_id, 
  menu.product_name 
FROM purchased_prior_member AS p_member
JOIN dannys_diner.menu
  ON p_member.product_id = menu.product_id
WHERE rankk = 1
ORDER BY p_member.customer_id ASC;

SELECT customer_id, Product_id from sales;

-- 8. What is the total items and amount spent for each member before they became a member?

-- select count(S.product_id) , M.price , S.customer_id ,

SELECT 
  sales.customer_id, 
  COUNT(sales.product_id) AS total_items, 
  SUM(menu.price) AS total_sales
FROM dannys_diner.sales
JOIN dannys_diner.members
  ON sales.customer_id = members.customer_id
  AND sales.order_date < members.join_date
JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points 
-- multiplier - how many points would each customer have?
-- usage of case 

WITH points_cte AS (
  SELECT 
    menu.product_id, 
    CASE
      WHEN product_id = 1 THEN price * 20
      ELSE price * 10
    END AS points
  FROM dannys_diner.menu
)

SELECT 
  sales.customer_id, 
  SUM(points_cte.points) AS total_points
FROM dannys_diner.sales
JOIN points_cte
  ON sales.product_id = points_cte.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id; 

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - 
-- how many points do customer A and B have at the end of January?

WITH customers_data AS (
  SELECT 
    sales.customer_id, 
    sales.order_date,  
    menu.product_name, 
    menu.price,
    CASE
      WHEN members.join_date > sales.order_date THEN 'N'
      WHEN members.join_date <= sales.order_date THEN 'Y'
      ELSE 'N' END AS member_status
  FROM dannys_diner.sales
  LEFT JOIN dannys_diner.members
    ON sales.customer_id = members.customer_id
  JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
  ORDER BY members.customer_id, sales.order_date
)

SELECT 
  *, 
  CASE
    WHEN member_status = 'N' then NULL
    ELSE RANK () OVER(
      PARTITION BY customer_id, member_status
      ORDER BY order_date) END AS ranking
FROM customers_data;



















 














