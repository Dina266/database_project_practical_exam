use supermarket;
--calc total sales between to data
create function calc_totalSales(@startDate date,@endDate date)
returns decimal(10,2)
begin
declare @totalSales decimal(10,2)
select @totalSales= sum(p.product_price*h.number)
from orders o join have_product h on o.order_id=h.order_id
join product p on p.product_id=h.product_id  
where o.order_date between @startDate and @endDate
return @totalSales 
end

select dbo.calc_totalSales('2023-04-01','2023-06-01') as 'total sales'

------Query that add discount to some customer(his total_price >= check value) 
---------customer have discount:
create function customer_hvdiscount(@price decimal(10,2))
returns @table_hvdiscount table(customer_id int,
								Name varchar(20) , 
								total_price decimal(10,2))
as 
begin
	insert into @table_hvdiscount
	select c.customer_id, c.first_name , 
	sum(p.product_price * hv.number) as "total_price" 	
	from customer c join orders o on c.customer_id = o.customer_id
	join have_product hv on hv.order_id = o.order_id 
	join product p on p.product_id = hv.product_id
	group by c.customer_id, first_name
	having sum(p.product_price* hv.number) >= @price
	return;
end	
declare @price1 decimal(10,2) = 150
select * from customer_hvdiscount(@price1)

---------customer don't have discount:
create function customer_donot_hvdiscount(@price decimal(10,2))
returns @table_donot_hvdiscount table(customer_id int,
								Name varchar(20) , 
								total_price decimal(10,2))
as 
begin
	insert into @table_donot_hvdiscount
	select c.customer_id, c.first_name , 
	sum(p.product_price* hv.number) as "total_price" 	
	from customer c join orders o on c.customer_id = o.customer_id
	join have_product hv on hv.order_id = o.order_id 
	join product p on p.product_id = hv.product_id
	group by c.customer_id, first_name
	having sum(p.product_price* hv.number) < @price
	return;
end	

declare @price2 decimal(10,2) = 150;
select * from customer_donot_hvdiscount(@price2)

---------- func return price_after_discount:
create function price_after_discount(@price decimal(10,2),
									 @desired_price decimal(10,2),
									 @discount decimal(10,2))
returns decimal(10,2)
as 
begin
	declare @result decimal(10,2) ;
	if (@price >=  @desired_price)	
		set @result =  @price * (1 - @discount)
	else if (@price <  @desired_price)
		set @result =  @price

	return @result;
end

----- add discount to customeer only (his total_price >= 150):
declare @check_price decimal(10,2) = 150,
		@discount decimal(10,2) = 0.15;
select customer_id, name, total_price,
dbo.price_after_discount(total_price, @check_price, @discount) as"price_after_discount"
from customer_hvdiscount(150)
union
select customer_id, name, total_price,
dbo.price_after_discount(total_price, 150, .85) as"price_after_discount"
from customer_donot_hvdiscount(150)

---------------------------------
create function calc_discount(@disc decimal(3,2))
returns @t table (order_id int,total_price decimal(10,2),price_after_disc decimal(10,2))
begin
insert into @t
select o.order_id,sum(p.product_price*h.number),sum((p.product_price*h.number-@disc*(p.product_price*h.number)))
from orders o join have_product h on o.order_id=h.order_id
join product p on p.product_id=h.product_id
group by o.order_id
return 
end


select* from dbo.calc_discount(0.2)






