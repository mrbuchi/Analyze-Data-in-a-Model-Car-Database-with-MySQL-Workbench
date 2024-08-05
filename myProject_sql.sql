-- Familiarizing myself with the Mint Classics relational database.
select* from warehouses;
select* from products;
select* from productlines;
select* from orderdetails;
select* from payments;
select* from customers;
select* from orders;
select* from employees;

-- both query generate the same output
SELECT COUNT(*)
FROM products;
SELECT COUNT(DISTINCT(productCode))
FROM products;
 -- The company currently holds a diverse inventory of 110 distinct products.Let’s look at where are
 -- the product stored. But, we have to verify whether any products are stored in multiple warehouses.
 
 -- check if there are products that stored in multiple warehouse
SELECT 
 productCode, 
 COUNT(warehouseCode) AS warehouse
FROM products
GROUP BY productCode
HAVING COUNT(warehouseCode) > 1;
-- There are no products stored in multiple warehouses.

-- What is the current storage location of each product
SELECT p.productname, p.quantityinstock, w.warehousecode, 
w.warehousename FROM products p JOIN warehouses w ON p.warehouseCode = w.warehouseCode;

-- Are there products with low quantities that can be consolidated into fewer storage locations
SELECT productcode, productname, warehousecode, SUM(quantityinstock) AS total_quantity 
FROM products GROUP BY productcode ,warehousecode order by total_quantity ,warehouseCode asc;
 /*from abovr question we can suggest that warehouse */ /*code a has 1960 BSA Gold Star DBD34 
 product in very less quantity 15 and warehouse b having 68 quantity of 1968 Ford Mustang */
 
 -- Are there any storage locations that can be eliminated by rearranging the products
 SELECT p.productCode, p.productname, sum(p.quantityinstock) as total_quantity, 
 sum(o.quantityOrdered) as total_sale, warehouseCode, count(p.warehouseCode)
 FROM orderdetails o JOIN products p ON p.productCode = o.productCode group by p.productCode
 order by total_sale asc; /* from belew table we get the list of products and warecousecode 
 that has the low / / sale over the overall database there is need to rearrange the products */
 
 -- Product and Inventory Analysis
 SELECT
 DISTINCT(status)
FROM orders;

-- Which products which is in warehouse D and not in A,B,C
SELECT DISTINCT p.productName FROM products p INNER JOIN orderdetails o ON p.productCode 
= o.productCode WHERE p.warehouseCode = 'D' AND p.productCode NOT IN 
(SELECT DISTINCT p2.productCode FROM products p2 INNER JOIN orderdetails o2 ON p2.productCode 
= o2.productCode WHERE p2.warehouseCode IN ('A' , 'B', 'c'));

-- identify products that have not been sold for a specific period of time
SELECT o.orderDate, od.quantityOrdered, p.productName, od.productCode, p.productName, 
p.quantityInStock, p.warehouseCode FROM orders o INNER JOIN orderdetails od ON o.orderNumber
 = od.orderNumber INNER JOIN products p ON p.productcode = od.productcode WHERE o.orderDate 
 IS NULL OR o.orderDate < DATE_SUB(NOW(), INTERVAL 300 DAY);
 
 -- Identify products with low turnover rates that might be candidates for reevaluation or reduction.
 SELECT sum(py.amount) as total_amount, sum(od.quantityordered) as total_orders, p.productname,
 p.warehouseCode, sum(p.quantityInStock), count( p.productname) FROM payments py JOIN orders o ON 
 py.customernumber = o.customernumber JOIN orderdetails od ON o.orderNumber = od.orderNumber 
 JOIN products p ON od.productcode = p.productcode group by p.productName, p.warehouseCode 
 order by p.warehouseCode, total_amount asc; /* The product 1960 BSA Gold Star DBD34 has less 
 orders as well as low revenue in overall sell in warehousecode 'A'*/ /*In ware housecode 'B' 
 the product 1972 Alfa Romeo GTA has less revenue */ /*In ware housecode 'c' from quantity in stock 
 we can say that 1941 Chevrolet Special Deluxe Cabriolet has less revenue and less sell in overall 
 sell but has more stock */
 
 -- Are there products that consistently have high sales but low inventory, indicating a potential opportunity for increased stocking
 SELECT SUM(py.amount) AS total_amount, SUM(od.quantityordered) AS total_orders, p.productname, 
 p.warehouseCode, SUM(p.quantityInStock), COUNT(p.productname) FROM payments py JOIN orders o ON 
 py.customernumber = o.customernumber JOIN orderdetails od ON o.orderNumber = od.orderNumber JOIN 
 products p ON od.productcode = p.productcode GROUP BY p.productName , p.warehouseCode ORDER BY 
 p.warehouseCode , total_amount ASC; /*product 1928 Ford Phaeton Deluxe In ware housecode 'c' 
 from quantity in stock 1928 Ford Phaeton Deluxe need of keeping more stock */ /*In ware housecode 
 'B' ,1968 Ford Mustang has more revenue and has more orders but has very less in stock there is a 
 need of keeping more stock of this model / / In warehouse code 'D' the model The Mayflower has more 
 orders and more revenue from it but we have less stock of it */
 
-- Which customer borrow the most products from the inventory
sELECT c.customerName, c.customerNumber, c.country, sum(od.quantityOrdered) as total_order
FROM customers c JOIN orders o ON c.customerNumber = o.customerNumber JOIN orderdetails od ON 
od.ordernumber = o.orderNumber group by c.customerNumber,c.city,c.country order by total_order desc;

-- top 10 customer bought the products from the inventory
SELECT c.customerName, c.customerNumber, c.country, SUM(od.quantityOrdered) AS total_order FROM 
customers c JOIN orders o ON c.customerNumber = o.customerNumber JOIN orderdetails od ON 
od.ordernumber = o.orderNumber JOIN products p ON p.productCode = od.productCode GROUP BY 
c.customerNumber , c.country ORDER BY total_order DESC LIMIT 10; /* from above code we get the 
top 10 customers that bought product */
-- find top 10 vendors whose products have not been selling well and might need revaluation
SELECT p.productVendor, SUM(od.quantityOrdered) AS total_order FROM orderdetails od JOIN products p 
ON p.productCode = od.productCode GROUP BY p.productVendor ORDER BY total_order ASC limit 10; 

 -- which seller sale less products and from which warehouse they belongs
 SELECT c.customerName, c.customerNumber, c.country, count(c.country) as no_of_customer,
 sum(od.quantityOrdered) as total_order, p.warehousecode, p.productName
FROM customers c JOIN orders o ON c.customerNumber = o.customerNumber JOIN orderdetails od ON 
od.ordernumber = o.orderNumber join products p on p.productCode=od.productCode 
group by c.customerNumber,c.city,c.country,p.warehouseCode,p.productName
order by p.warehouseCode desc; /*from above we will suggest that which seller sale less products 
and from which warehouse it belong*/



