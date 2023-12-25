create procedure search_by_name   ---on customer
  @name varchar(20)
as
begin 
    select * 
    from customer c
	where c.first_name =  @name
end
--------------------------------------
create procedure customer_inserted 
@customer_firstname varchar(20),
@customer_lasttname varchar(20),
@state varchar(20),
@city varchar(20),
@street varchar(50)
as 
begin
	begin try
		insert into customer(first_name,last_name,state,city,street)
		values(@customer_firstname,@customer_lasttname,@state,@city,@street)
		return 0
	end try
	begin catch
		return 1
	end catch
end



create procedure insert_employee
@firstname varchar(20),
@lastname varchar(20),
@age int,
@salary decimal(10,2),
@dapartment_id int
as
begin
	begin try
		insert into employee(first_name,last_name,age,salary,dep_id)
		values(@firstname,@lastname,@age,@salary,@dapartment_id)
		return 0
	end try
	begin catch
		return 1
	end catch
end


create procedure have_product_inserted 
@order_id int,
@product_id int,
@quantity_of_product int
as 
begin
	begin try
		insert into have_product(order_id,product_id,number)
		values(@order_id,@product_id,@quantity_of_product)
		return 0
	end try
	begin catch
		return 1
	end catch
end

create procedure order_insert 
@date date,
@customer_id int,
@employee_id int
as 
begin
	begin try
		insert into orders(order_date,customer_id,emp_id)
		values(@date,@customer_id,@employee_id)
		return 0
	end try
	begin catch
		return 1
	end catch
end
-------------------------------------------------
create trigger order_have_product
on orders 
after insert as
begin
	insert into have_product(order_id,product_id,number)
	select i.order_id,29,1
	from inserted i
end

------------------------------------ 
create trigger num_of_product
on have_product
after insert 
as
begin
   declare @prod_id int
   declare @num_of_prod int     -------number he take from this product
   select @prod_id = i.product_id ,@num_of_prod = i.number
   from inserted i

   update product 
   set num_of_product = num_of_product - @num_of_prod
   where product_id = @prod_id 

end