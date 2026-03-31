create Database RetailSalesManagement 
use retailsalesmanagement

create table customers(
customerid int identity(1,1) primary key,
customername varchar(100),
email varchar(100) unique,
phone varchar(15),
city varchar(50),
);

create table employees(
employeeid int identity(1,1) primary key,
employeename varchar(20),
position varchar(50),
salary decimal(10,2),
branchid int
);

create table suppliers(
supplierid int identity(1,1) primary key,
suppliername varchar(100),
phone varchar(15)
);

create table categories(
categoryid int identity(1,1) primary key,
categoryname varchar(100)
);

create table products(
productid int identity(1,1) primary key,
productname varchar(100),
price decimal(10,2) check (price > 0),
categoryid int,
supplierid int,
foreign key (categoryid) references categories(categoryid),
foreign key (supplierid) references suppliers(supplierid)
);

create table orders(
orderid int identity(1,1) primary key,
customerid int,
employeeid int,
orderdate date default getdate(),
foreign key (customerid) references customers(customerid),
foreign key (employeeid) references employees(employeeid)
);

create table orderdetils(
orderdetailid int identity(1,1) primary key,
orderid int,
productid int,
quantity int,
price decimal(10,2),
totalamount as(quantity * price),
foreign key (orderid) references orders(orderid),
foreign key (productid) references products(productid)
);
sp_rename 'orderdetils', 'orderdetails'

create table paymants(
paymentid int identity(1,1) primary key,
orderid int,
amount decimal(10,2),
paymentdate date,
paymentmethod varchar(50),
foreign key (orderid) references orders(orderid)
);
sp_rename 'paymants','payments'

create table inventory(
inventoryid int identity(1,1) primary key,
productid int,
stockquantity int,
foreign key (productid) references products(productid)
);

create table branches(
branchid int identity(1,1) primary key,
branchname varchar(100),
city varchar(50)
);

create table employeeattendance(
attendanceid int identity(1,1) primary key,
employeeid int,
attendancedate date,
status varchar(20),
foreign key (employeeid) references employees(employeeid)
);



INSERT INTO Customers (CustomerName, Email, Phone, City) VALUES
('Ravi','ravi@gmail.com','9876543210','Hyderabad'),
('Sita','sita@gmail.com','9876543211','Vizag'),
('Arjun','arjun@gmail.com','9876543212','Chennai'),
('Kiran','kiran@gmail.com','9876543213','Bangalore')

INSERT INTO Suppliers (SupplierName, Phone) VALUES
('ABC Suppliers','9000000001'),
('XYZ Traders','9000000002');

INSERT INTO Categories (CategoryName) VALUES
('Electronics'),
('Accessories');

INSERT INTO Products (ProductName, Price, CategoryID, SupplierID) VALUES
('Laptop',50000,1,1),
('Mobile',20000,1,2),
('Headphones',2000,2,1),
('Keyboard',1500,2,2);

INSERT INTO Branches (BranchName, City) VALUES
('Main Branch','Hyderabad'),
('City Branch','Vizag');

INSERT INTO Employees (EmployeeName, Position, Salary, BranchID) VALUES
('Raj','Manager',50000,1),
('Anu','Sales',30000,1),
('Vikram','Sales',28000,2);

INSERT INTO Orders (CustomerID, EmployeeID) VALUES
(1,1),
(2,2),
(1,2),
(3,3);

INSERT INTO OrderDetails(OrderID, ProductID, Quantity, Price) VALUES
(1,1,1,50000),
(1,3,2,2000),
(2,2,1,20000),
(3,4,1,1500),
(4,1,1,50000);

select * from information_schema.tables;

INSERT INTO Payments (OrderID, Amount, PaymentDate, PaymentMethod) VALUES
(1,54000,GETDATE(),'Cash'),
(2,20000,GETDATE(),'Card'),
(3,1500,GETDATE(),'UPI'),
(4,50000,GETDATE(),'Card');

INSERT INTO Inventory (ProductID, StockQuantity) VALUES
(1,10),
(2,20),
(3,50),
(4,30);

INSERT INTO EmployeeAttendance (EmployeeID, AttendanceDate, Status) VALUES
(1,GETDATE(),'Present'),
(2,GETDATE(),'Absent'),
(3,GETDATE(),'Present');


--BASIC QUERYS
--1. Display all customers
select * from customers

--2. Show products with price > 500 
select * from products where price >500

--3. Show orders placed this month
select * from orders 
where month(orderdate) = month(getdate())
and year(orderdate) = year(GETDATE())

--4. Display top 10 expensive products 
select top 10 * from products
order by price desc

--5. Count total customers 
select count(*) as totalcustomers
from customers;

--6. Average product price per category 
select categoryid, AVG(price) as avgprice
from products
group by categoryid

--7. Total sales per branch
select b.branchname, sum(od.quantity * od.price) as totalsales 
from orders o 
join employees e on o.employeeid = e.employeeid
join branches b on e.branchid = b.branchid
join orderdetails od on o.orderid = od.orderid
group by b.branchname;


--JOINS
--1. Orders with customer names 
select c.customername,o.orderid
from customers c
join orders o
on o.customerid = c.customerid

--2. Orders with employee and branch
select o.orderid, e.employeename, b.branchname
from orders o
join employees e 
on o.employeeid = e.employeeid
join branches b 
on b.branchid = e.branchid

--3. Product supplier details
select p.productname, s.suppliername
from products p 
join suppliers s
on s.supplierid = p.supplierid

--4. Customers without orders (LEFT JOIN)
select  c.customername
from customers c
left join orders o 
on o.customerid = c.customerid
where o.orderid is null

--5. Products never sold 
select p.productname
from products p 
join orderdetails od
on od.productid = p.productid
where od.productid is null

--6. Employee attendance with employee details 
select e.employeename, ea.attendancedate,ea.status
from employeeattendance ea
join employees e
on e.employeeid = ea.employeeid



--AGGREGATION + GROUP BY
--1. Monthly sales report 
select MONTH(o.orderdate) as month,
	sum(od.quantity * od.price) as Totalsales
from orders o 
join orderdetails od 
on o.orderid = od.orderid
group by MONTH(o.orderdate)

--2. Category wise sales 
select c.categoryname,
	sum(od.quantity * od.price) as Totalsales
from categories c
join products p 
on p.categoryid = c.categoryid
join orderdetails od 
on od.productid = p.productid
group by c.categoryname

--3. Employee wise sales performance 
select e.employeename,
	sum(od.quantity * od.price) as Totalsales
from employees e
join orders o 
on o.employeeid = e.employeeid
join orderdetails od 
on od.orderid = o.orderid
group by e.employeename

--4. Top selling product 
select top 1 p.productname,
	sum(od.quantity) as Totalsold
from products p
join orderdetails od 
on od.productid = p.productid
group by p.productname
order by Totalsold desc

--5. Least selling product 
select top 1 p.productname,
	sum(od.quantity) as Totalsold
from products p
join orderdetails od
on od.productid = od.productid
group by p.productname
order by Totalsold asc

--6. Supplier wise supply value 
select s.suppliername,
	sum(od.quantity * od.price) as Totalsupplyvalue
from suppliers s
join products p 
on p.supplierid = s.supplierid
join orderdetails od
on od.productid = p.productid
group by s.suppliername



--SUBQUERYS
--1. Products priced above average
select productname,price
from products
where price >(select avg(price) from products);

--2. Customers with highest orders 
select c.customername, count(o.orderid) as Totalorders
from customers c
join orders o
on c.customerid = o.customerid
group by c.customername
having count(o.orderid) = 
	( select max(ordercount)
	from (select count(orderid) as Ordercount
	from orders
	group by customerid) as Temp);

--3. Employees earning above department average 
select employeename, salary 
from employees 
where salary > (select avg(salary) from employees)

--4. Products never ordered 
select productname
from products
where productid not in
	(select productid from orderdetails);


--WINDOW FUNCTIONS
--1. Top 3 products per category 
select * from (
	select p.productname,c.categoryname,p.price,
	ROW_NUMBER() over(PARTITION by c.categoryname order by p.price
	desc) as rank_num
from products p 
join categories c 
on p.categoryid = p.categoryid
) t
where rank_num <=3


--VIEW
--1. Create SalesSummary view 
create view salesSummary as 
select o.orderid,
	sum(od.quantity * od.price) as Totalamount
from orders o 
join orderdetails od 
on o.orderid = od.orderid
group by o.orderid
select * from salesSummary

--2. Create ActiveCustomers view 
create view Activecustomers as 
select distinct c.customerid,c.customername
from customers c
join orders o 
on o.customerid = c.customerid
select * from Activecustomers

--3. Create ProductInventory view 
create view Productinventory as
select p.productname,i.stockquantity
from products p 
join inventory i 
on p.productid = i.productid
select * from Productinventory

--4. Update data through view 
create view Productview as 
select productid,productname,price
from products 

update productview
set price = 2000
where productid = 1

select * from Productview
where productid = 1



--STORED PROCEDURE
--1. Insert new order procedure 
create procedure addneworder
	@customerid int
as 
begin
	insert into orders(customerid,orderdate)
	values (@customerid,GETDATE());
end;
exec addneworder @customerid = 2
select * from addneworder


--2. Update product price procedure 
create procedure Updateproductprice
	@productid int,
	@newprice decimal(10,2)
as 
begin
	update products
	set price = @newprice
	where productid = @productid;
end;
exec Updateproductprice @productid = 1, @newprice = 2500


--3. Monthly sales report procedure 
create procedure Monthlysalesreport
as
begin
	select 
		month(orderdate) as Month,
		sum(od.quantity * od.price) as Totalsales
	from orders o
	join orderdetails od
	on od.orderid = o.orderid
	group by month(orderdate);
end;
exec Monthlysalesreport


--4. Employee attendance procedure 
create procedure Employeeattendancereport
	@employeeid int
as
begin
	select * from employeeattendance
	where employeeid = @employeeid
end;


--5. Dynamic search stored procedure 
create procedure Searchproducts
    @ProductName varchar(100) = null,
    @Categoryid int = null,
    @MinPrice decimal(10,2) = null,
    @MaxPrice decimal(10,2) = null
as
begin
    select * from Products
    where 
        (@ProductName is null or ProductName like '%' + @ProductName + '%')
        and (@CategoryID is null or CategoryID = @CategoryID)
        and (@MinPrice is null or price >= @MinPrice)
        and (@MaxPrice is null or price <= @MaxPrice);
end;
exec Searchproducts @ProductName = 'phone';
exec SearchProducts @MinPrice = 500, @MaxPrice = 2000;
exec SearchProducts @CategoryID = 2;
exec SearchProducts 
    @ProductName = 'phone',
    @MinPrice = 500;



--FUNCTION
--1. Scalar function to calculate discount
create function Calculatediscount (@price decimal(10,2))
returns decimal(10,2)
as
begin
	declare @discount decimal(10,2);
	set @discount = @price * 0.10;
	return @discount
end;
select productname,price,dbo.Calculatediscount(price) as Discount
from products


--2. Table-valued function for customer order history 
create function Getcustomerorder (@customerid int)
returns table 
as
return
(
	select * from orders
	where customerid = @customerid
);

select * from dbo.Getcustomerorder(1);

--3. Function to calculate tax 
create function Calcualatetax (@amount decimal(10,2))
returns decimal(10,2)
as
begin
	return @amount * 0.18;
end;


--4. Function returning monthly sales 
create function Getmonthlysales()
returns table
as
return
(
	select MONTH(o.orderdate) as Month,
			sum(od.quantity * od.price) as Totalsales
	from orders o 
join orderdetails od
on o.orderid = od.orderid
group  by MONTH(o.orderdate)
);
select * from dbo.Getmonthlysales();



--TRANSACTION
--1. Order processing transaction 
begin transaction;

insert into orders(customerid,orderdate)
values (1,GETDATE());


insert into orderdetails(orderid,productid,quantity,price)
values(1,2,3,500);

commit;



--2. Savepoint example 
begin transaction;

save transaction Savepoint1;

update Products
set price = price + 100
where productid = 1;

-- Something wrong
rollback transaction savepoint1;

commit;
