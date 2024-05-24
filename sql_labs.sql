create database mysql_lab;
use mysql_lab;

show tables from mysql_lab;

create table if not exists Employee (
Emp_ID INT,
Emp_Name VARCHAR (100),
Age INT,
Company VARCHAR (100),
DOJ DATE
);

insert into Employee values 
(1, 'A', 26, "TCS", "2020-05-17"),
	(2, 'B', 33, "Infosys", "2010-02-13"),
	(3, 'C', 35, "IBM", "2015-08-26")  ;

select * from Employee;

-- 2nd question

use classicmodels;

-- 1.	Fetch the employee number, first name and last name of those employees who are working as
-- Sales Rep reporting to employee with  employeenumber 1102 (Refer employee table)

select * from employees;

select employeenumber, firstname,lastname from employees 
where jobTitle = 'sales Rep' and reportsTo = 1102;


-- 2.	Show the unique productline values containing the word cars at the end from the products table.

select * from products;

select distinct productline from products
where  productline like '%cars';



-- 1. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
                       -- "North America" for customers from USA or Canada
                       -- "Europe" for customers from UK, France, or Germany
--                        "Other" for all remaining countries
			-- Select the customerNumber, customerName, and the assigned region as "CustomerSegment".

use classicmodels;
select * from customers;

select customerNumber, customerName, 
case 
when country ='USA' or country = 'Canada' then 'North America' 
when country = 'UK' or country = 'France' or country = 'Germany' then 'Europe'
else 'Others'
end as customersegment
from customers;





-- 
-- --1.	Using the OrderDetails table, 
-- identify the top 10 products (by productCode) with the highest total order quantity across all orders.

select * from orderdetails;

select productCode , sum(quantityOrdered) as total_quantity
from orderdetails group by productCode
order by total_quantity desc limit 10;






-- 1.	Create table facility. Add the below fields into it.
-- ●	Facility_ID
 -- ●	Name
-- ●	State
-- ●	Country

-- i) Alter the table by adding the primary key and auto increment to Facility_ID column.
-- ii) Add a new column city after name with data type as varchar which should not accept any null values.
use classicmodels;

create table facility(
facilityid int ,
name varchar(100),
state varchar(100),
country varchar(100)
);
drop table facility;
alter table facility add PRIMARY KEY AUTO_INCREMENT(FACILITYID);
alter table facility add column city varchar(30) not null after name ;
desc facility;



-- 2.	Company wants to analyze payment frequency by month. 
-- Extract the month name from the payment date to count the total number of payments 
-- for each month and include only those months with a payment count exceeding 20 (Refer Payments table). 

select * from payments ;

select monthname(paymentDate) as month, count(*) as num_payments
from payments
group by month
having num_payments >20;

-- 1.	List the top 5 countries (by order count) that 
-- Classic Models ships to. (Use the Customers and Orders tables)
use classicmodels;
select * from customers;
select * from orders;

select country,count(*) as order_count 
from customers right join orders on customers.customerNumber = orders.customerNumber
group by country
order by order_count desc 
limit 5;

-- SELF JOIN
 -- 2.	Create a table project with below fields.


-- ●	EmployeeID : integer set as the PRIMARY KEY and AUTO_INCREMENT.
-- ●	FullName: varchar(50) with no null values
-- ●	Gender : Values should be only ‘Male’  or ‘Female’
-- ●	ManagerID: integer

create table if not exists project(
EmployeeID int primary key auto_increment,
Full_Name varchar(50) not null,
Gender varchar(10),
check(Gender in ("Male","Female")),
ManagerID int
); 

insert into Project values 
(1,'pranaya','Male',3),(2,'priyanka','Female',1),(3,'preety','Female',null),
(4,'Anurag','Male',1),(5,'sambit','Male',1),
(6,'Rajesh','Male',3),(7,'Heena','Female',3);
use classicmodels;
select * from project;

select m.Full_name as Manager_name, e.Full_Name as emp_name

from project e
left join project m on e.ManagerID = m.EmployeeID
where m.Full_name is not null;



select * from products;
select * from orders;
select * from orderdetails;


select * from products cross join orders cross join orderdetails;
use classicmodels;
select productline,count(*) as num_of_order
from products cross join orders cross join orderdetails
group by productline;

use classicmodels;

-- Window functions - Rank, dense_rank, lead and lag
-- Using customers and orders tables, rank the customers based on their order frequency


select * from customers limit 20;
select * from orders;
select c.customerName , count(*) over (partition by o.customernumber) as order_count 
from customers c join orders o on c.customerNumber = o.customerNumber order by order_count desc;

with e as (select c.customerName , count(*) over (partition by o.customernumber) as order_count 
from customers c join orders o on c.customerNumber = o.customerNumber) 
select distinct customername,order_count, dense_rank() over (order by order_count desc) as order_frequncy_rnk from e; 



-- 1b) Calculate year wise, month name wise count of orders and 
-- year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.
select *  from orders;

select year(orderdate) as c_year,
monthname(orderdate) as c_month,
count(orderNumber) as order_count
from orders
group by c_year,c_month;

with a as (select year(orderdate) as c_year,
monthname(orderdate) as c_month,
count(orderNumber) as order_count
from orders
group by c_year,c_month) 
select *, lag(order_count,1) over (partition by c_year ) as previous_year_orders from a;

with cte as (
 
select year(orderdate) as c_year,
monthname(orderdate) as c_month,
count(orderNumber) as order_count
from orders
group by c_year,c_month
),
yoy_cte as(
 
select c_year,c_month,order_count, lag(order_count,1) over (order by c_year) as previous_year_orders from cte
)
select c_year,c_month ,order_count,
concat (format((order_count - previous_year_orders)*100 / previous_year_orders,0),'%') as yoy_change


from yoy_cte
order by c_year;



/* Views in SQL
-- 1.	Create a view named product_category_sales that provides insights into sales performance by product category. This view should include the following information:
productLine: The category name of the product (from the ProductLines table).

total_sales: The total revenue generated by products within that category (calculated by summing the orderDetails.quantity * orderDetails.priceEach for each product in the category).

number_of_orders: The total number of orders containing products from that category.

(Hint: Tables to be used: Products, orders, orderdetails and productlines)

  
*/
select * from products;
select * from productlines;
select * from orders;
select * from orderdetails;

select * from orders o
JOIN orderdetails od
ON o.orderNumber=od.orderNumber
JOIN products p
ON od.productCode= p.productCode;
create view product_catagory_sales as 
select p.productline,SUM(od.quantityOrdered * od.priceEach) AS Total_Sales,
count(DISTINCT o.ordernumber) as Total_orders 
from orders o
JOIN orderdetails od
ON o.orderNumber=od.orderNumber
JOIN products p
ON od.productCode= p.productCode
group by p.productline;

select * from product_catagory_sales;




-- Subqueries and their applications

-- 1.	Find out how many product lines are there for which the buy price value is greater
-- than the  average of buy price value. Show the output as product line and its count.

select * from products;

select avg(buyPrice) from products;


select productline ,count(*) as Total
from products 
where buyprice > (select avg(buyPrice) from products)
 group by productline;






-- ERROR HANDLING in SQL
-- 1.	Create the table Emp_EH. Below are its fields.
-- ●	EmpID (Primary Key)
-- ●	EmpName
 -- ●	EmailAddress
-- Create a procedure to accept the values for the columns in Emp_EH. 
-- Handle the error using exception handling concept. Show the message as “Error occurred” in case of anything wrong.
use classicmodels;
create table if not exists Emp_Eh(
Emp_id int primary key ,
Empname varchar(100),
EmailAddress varchar(50)

);

select * from emp_eh;
call Error_handler_assignment(108,'Akash','aksh@456gmail.com');



-- TRIGGERS
-- 1.	Create the table Emp_BIT. Add below fields in it.
-- ●	Name
-- ●	Occupation
-- ●	Working_date
 -- ●	Working_hours

create table Emp_BIT(
name varchar(50),
occupation varchar(30),
working_date date,
working_hours int
);
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);  

select * from emp_bit;
INSERT INTO Emp_BIT VALUES ('Amol','Data_analyst','2024-04-25',-13);


