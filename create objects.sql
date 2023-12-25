create database supermarket
use supermarket
go
create table customer(
	customer_id int identity(1,1) primary key,
	first_name varchar(20) NOT NULL,
	last_name varchar(20) not null,
	street VARCHAR (255),
	city VARCHAR (50),
	state VARCHAR (25),
)
create table customer_phone(
	customer_id int ,
	phone VARCHAR (25) unique,
	constraint pk_customer_phone primary key(customer_id, phone),
    constraint fk_phone_customer foreign key (customer_id) references customer(customer_id) 
)
ALTER TABLE customer_phone
  drop CONSTRAINT fk_phone_customer;
alter table customer_phone
  add constraint fk_phone_customer
  foreign key (customer_id)
  references customer (customer_id) on delete cascade;

create table orders (
	order_id int identity(1,1) primary key,
	order_date date not null,
	customer_id int ,
	emp_id int,
	constraint fk_orders_customer foreign key (customer_id) 
	references customer(customer_id)
)
ALTER TABLE orders
  drop CONSTRAINT fk_orders_customer;
alter table orders
  add constraint fk_orders_customer
  foreign key (customer_id)
  references customer (customer_id) on delete cascade;

create table product(
	product_id int identity(1,1) primary key,
	name varchar(20) not null,
	product_price DECIMAL (10, 2) check(product_price > 0),
	num_of_product int not null,
	expire_date date,
	dep_id int 
)
create table department(
	dep_id int identity(1,1) primary key,
	name varchar(20) not null,
	emp_id int
)

create table employee (
	emp_id int identity(1,1) primary key,
	first_name varchar(20) not null,
	last_name varchar(20) not null,
	age int not null,
	salary decimal(10,2) not null,
	dep_id int ,
	constraint fk_employee_dep foreign key (dep_id)
	references department(dep_id)
)

create table have_product(
	order_id int,
	product_id int,
	number int,
	constraint pk_have_product primary key(order_id, product_id),
	constraint fk_hvp_order foreign key(order_id)
	references orders(order_id),
    constraint fk_hvp_product foreign key (product_id) references
	product(product_id)
)
ALTER TABLE have_product
  drop CONSTRAINT fk_hvp_order;
alter table have_product
  add constraint fk_hvp_order
  foreign key (order_id)
  references orders(order_id) on delete cascade;


alter table orders
add constraint fk_orders_dep foreign key (emp_id)  
references employee(emp_id)

alter table product
add constraint fk_product_dep foreign key (dep_id)  
references department(dep_id)

alter table department
add constraint fk_dep_emp foreign key (emp_id)  
references employee(emp_id)