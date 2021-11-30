
-- STEP 1: CREATE TABLE 
CREATE TABLE sales(
"CustommerId" VARCHAR(1) NOT NULL,
"OrderDate" date,
"ProductID" INTEGER NOT NULL);
INSERT INTO sales ("CustommerId", "OrderDate", "ProductID")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
SELECT * 
FROM sales
CREATE TABLE Menu(
"ProductId" VARCHAR(1) NOT NULL,
"ProductName" VARCHAR(8),
"Price" INTEGER NOT NULL);
INSERT INTO Menu( "ProductId","ProductName","Price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
CREATE TABLE Members(
"CustommerId" VARCHAR(1) NOT NULL,
"JoinDate" Date)
INSERT INTO Members("CustommerId","JoinDate")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
-- 1. What is the total amount each customer spent at the restaurant?
SELECT * FROM sales
SELECT * FROM Members
SELECT * FROM Menu
SELECT CustommerId, SUM(Menu.Price) AS TotalPrice
FROM sales
JOIN Menu
ON sales.ProductID=Menu.ProductId
GROUP BY CustommerId
ORDER BY TotalPrice
--> In hear, we can see custommer A pay the most money to buys goods.
-- 2. How many "days" has "each" customer visited the restaurant?
SELECT CustommerId, COUNT(DISTINCT(Orderdate))u
FROM sales
GROUP BY CustommerId
-- 3. What was the first item from the menu purchased by each customer?
WITH CTE_RANK AS
(
SELECT CustommerID,ProductName,
DENSE_RANK()OVER(PARTITION BY CustommerId ORDER BY OrderDate) dense_rank_item
FROM sales AS a
JOIN menu AS b
ON a.ProductID=b.ProductID)
SELECT CustommerId, ProductName
FROM CTE_RANK
WHERE dense_rank_item=1
GROUP BY CustommerId,ProductName

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT ProductName,Count(sales.ProductID) AS Time_to_buy
FROM sales
JOIN Menu
ON sales.ProductID=Menu.ProductID
GROUP BY ProductName,sales.ProductID
ORDER BY Time_to_buy
-- Through the results, I am sure that ramen bought many time by customer
SELECT TOP 1(COUNT(sales.ProductID)) AS Top_seller,ProductName
FROM sales
JOIN Menu
ON sales.ProductID=Menu.ProductID
GROUP BY sales.ProductID,ProductName
ORDER BY  Top_seller desc;
-- 5. Which item was the most popular for each customer?
SELECT * 
FROM sales
WITH CTE AS
(
SELECT sales.CustommerId, sales.ProductID,Menu.ProductName,  COUNT(sales.ProductID) AS Q_ty,
DENSE_RANK()OVER (PARTITION BY CustommerId ORDER BY COUNT (CustommerId) DESC) AS dRank
FROM sales
JOIN Menu
ON sales.ProductID=Menu.ProductId
GROUP BY sales.ProductID, CustommerId,ProductName

)
SELECT *
FROM CTE
WHERE dRank=1

--6. Which item was purchased first by the customer after they became a member?

WITH CTE_RANK AS
(
SELECT a.CustommerID,b.ProductName,a.OrderDate,
DENSE_RANK () OVER (PARTITION BY a.CustommerID ORDER BY a.OrderDate) AS DENSE_RANKS
FROM ((sales AS a
JOIN menu AS b
ON a.ProductID=b.ProductID)
JOIN Members AS c
ON a.CustommerId= c.CustommerId	)
WHERE OrderDate>=JoinDate
)
SELECT * FROM CTE_RANK
WHERE DENSE_RANKS=1
--7. Which item was purchased just before the customer became a member?
WITH CTE_RANK AS
(
SELECT a.CustommerID,b.ProductName,a.OrderDate,
DENSE_RANK () OVER (PARTITION BY a.CustommerID ORDER BY a.OrderDate DESC) AS DENSE_RANKS
FROM ((sales AS a
JOIN menu AS b
ON a.ProductID=b.ProductID)
JOIN Members AS c
ON a.CustommerId= c.CustommerId	)
WHERE OrderDate<JoinDate
)
SELECT * FROM CTE_RANK
WHERE DENSE_RANKS=1

--but if we note, we can see that custommer C not a member yet and can become member in the fulture. We must continute to analysis. But in this problem, there is not enough data for analysis
-- I thought about FULL OUTER JOIN

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT sales.CustommerId,SUM(Price) AS TotalPrice, COUNT(sales.ProductID) As Qty
FROM ((sales
JOIN Menu
ON sales.ProductID=Menu.ProductId)
JOIN Members
ON sales.CustommerId=Members.CustommerId)
WHERE OrderDate<JoinDate
GROUP BY sales.CustommerId

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH POINT AS
(
SELECT CustommerId, ProductName,
CASE
	WHEN ProductName='sushi' THEN COUNT(sales.ProductID)*2*Price*10 
	ELSE COUNT(sales.ProductID)*Price*10
END AS point
FROM sales
JOIN Menu
ON sales.ProductID=Menu.ProductId
GROUP BY CustommerId,ProductName,Price
)
SELECT CustommerId,SUM(point)
FROM POINT 
GROUP BY CustommerId

/*In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi how many points do customer A and B have at the end of January?*/
WITH POINTS1 AS
(
SELECT sales.CustommerId, ProductName, 
CASE
	WHEN OrderDate>=JoinDate AND OrderDate<=JoinDate+7 THEN COUNT(sales.ProductID)*2*Price*10 
	ELSE (
		CASE
			WHEN ProductName='sushi' THEN COUNT(sales.ProductID)*2*Price*10 
			ELSE COUNT(sales.ProductID)*Price*10
		END) 
END
FROM(( sales
JOIN Menu
ON sales.ProductID=Menu.ProductId)
JOIN Members
ON Members.CustommerId=sales.CustommerId)
GROUP BY sales.CustommerId,ProductName,Price
)
SELECT CustommerId,SUM(point)
FROM POINTS1 
GROUP BY CustommerId 
-----------------------------------------BONUS QUESTION----------------------------------------------
SELECT a.CustommerId,OrderDate,ProductName,Price,
CASE 
	WHEN OrderDate>=JoinDate THEN 'Y'
	WHEN OrderDate<JoinDate THEN 'N'
	ELSE 'N'
END AS member
FROM ((sales AS a
LEFT OUTER JOIN Menu AS b 
ON a.ProductID=b.ProductId)
LEFT OUTER JOIN Members AS c
ON a.CustommerId=c.CustommerId)
-----------------------------------------RANK ALL THE THỊNK----------------------------------------------
SELECT a.CustommerId,OrderDate,ProductName,Price,
CASE 
	WHEN OrderDate>=JoinDate THEN 'Y'
	WHEN OrderDate<JoinDate THEN 'N'
	ELSE 'N'
END AS member,
CASE 
	WHEN OrderDate>=JoinDate THEN DENSE_RANK() OVER(PARTITION BY a.CustommerId ORDER BY OrderDate)
	ELSE NULL
END
FROM ((sales AS a
LEFT OUTER JOIN Menu AS b 
ON a.ProductID=b.ProductId)
LEFT OUTER JOIN Members AS c
ON a.CustommerId=c.CustommerId)

SELECT * FROM sales
SELECT * FROM Menu
SELECT * FROM Members