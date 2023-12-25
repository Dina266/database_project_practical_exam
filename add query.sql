use supermarket
go


select * from customer
where first_name like'%p%'

select emp_id,first_name , age from employee
where salary = (select max(salary) from employee);

-- num of emp in dep
select d.dep_id,d.name as department,count(*) as 'number of employees'
from employee e join department d on e.dep_id=d.dep_id
group by d.dep_id,d.name

-- total price for all dep.
select d.dep_id,d.name,sum(p.product_price*number) as total_sales
from orders o join have_product h on o.order_id=h.order_id
join product p on p.product_id=h.product_id
join department d on d.dep_id=p.dep_id
group by d.dep_id,d.name

-- num of customer in state.
select upper(state) as "STATE" ,count(customer_id) as num_of_customer from customer
where state in ('California','florida','new york','indiana')
group by state
order by num_of_customer desc;

-- num of order for all customer.
select c.customer_id, c.first_name+' '+c.last_name as 'customer name',count(*) as number_of_orders
from orders o join customer c on o.customer_id=c.customer_id
group by c.customer_id,c.first_name+' '+c.last_name
order by number_of_orders desc,c.customer_id asc

-- information from product.
declare @taxes decimal(10,3) = 0.15; 
select product_id , upper(name) AS ProductName, product_price,
product_price * (1+@taxes) as "price after taxes"
from product
where year(expire_date) = 2023 and day(expire_date) = 10;

--employee make order.
select o.order_id, o.order_date , e.emp_id ,e.first_name , e.age 
from orders o , employee e 
where o.emp_id = e.emp_id and o.emp_id in 
(select emp_id from employee where age > 35)

--total price for every customer.
select c.customer_id, concat(c.first_name,' ',c.last_name) as full_name, 
sum(p.product_price * hv.number) as "total_price"
from customer c join orders o on c.customer_id = o.customer_id
join have_product hv on hv.order_id = o.order_id 
join product p on p.product_id = hv.product_id
group by c.customer_id, concat(c.first_name,' ',c.last_name)
having  sum(p.product_price * hv.number) > 50
order by sum(p.product_price * hv.number) desc;


--quantity for every dep.
select p.product_id,p.name as 'product name',d.name as 'department name',
sum(h.number) as quantity
from orders o join have_product h on o.order_id=h.order_id
join product p on p.product_id=h.product_id 
join department d on d.dep_id=p.dep_id
group by p.product_id,p.name,d.name
order by quantity desc

---------------------------------------------------
-- customer has more than one num.
select first_name ,last_name,  count( distinct cp.phone) as num 
  from customer c  , customer_phone  cp
  where c.customer_id=cp.customer_id 
group by first_name ,last_name 
having count (*)>1
order by num desc;

--add bonus salary to customer(more than one order).
select e.emp_id, first_name,salary, 
case 
when  count(o.emp_id)>1 then salary*(1+0.1)
else salary*1
end as bonused_salary
from employee e join orders o 
on e.emp_id = o.emp_id
group by e.emp_id ,first_name , salary


go

create function
 get_annualsalary()
returns table
as return
(select first_name,salary*12 as annual_salary
from employee)
go


select * from dbo.get_annualsalary()

-- all order
create view v1 as
select  o.order_id,e.emp_id,e.first_name+' '+e.last_name as 'employee_name',
sum(p.product_price*h.number) as 'total price'
from orders o join have_product h on o.order_id=h.order_id
join product p on p.product_id=h.product_id
join employee e on e.emp_id=o.emp_id
group by o.order_id,e.emp_id,e.first_name+' '+e.last_name

-- all employee
select v.emp_id,v.employee_name,sum(v.[total price]) 
from v1 v 
group by v.emp_id,v.employee_name
order by sum(v.[total price]) desc