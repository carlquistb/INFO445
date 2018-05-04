/*
supporting script for windowing lecture.
developed by: Brendan Carlquist
Spring 2018
*/

--use master drop database windowing_lecture_netID

create database windowing_lecture_netID
go
use windowing_lecture_netID
go
--construct PRODUCT table.
create table tblPRODUCT
	(
		ProductID int identity(1,1) not null,
		ProductName nvarchar(50) not null,
		ProductUnitPrice money not null

		constraint pk_tblPRODUCT primary key (ProductID)
	)
go
insert into tblPRODUCT (ProductName, ProductUnitPrice)
values
	('buns',1.79),
	('hamburger patties',7.99),
	('baked beans',2.99),
	('cole slaw',4.59),
	('ice cream',3.19)
go
--construct CUSTOMER table.
create table tblCUSTOMER
	(
		CustomerID int identity(1,1) not null,
		CustomerName nvarchar(50) not null

		constraint pk_tblCUSTOMER primary key (CustomerID)
	)
go
insert into tblCUSTOMER (CustomerName)
values
	('Jean Val Jean'),
	('Wednesday Addams'),
	('Audrey II'),
	('Seymour'),
	('King George')
go
--construct ORDER table
create table tblORDER
	(
		OrderID int identity(1,1) not null,
		OrderDatetime datetime not null,
		CustomerID int not null

		constraint pk_tblORDER primary key (OrderID),
		constraint fk_tblORDER_tblCUSTOMER foreign key (CustomerID) references tblCUSTOMER(CustomerID)
	)
go
--construct ORDERDETAIL table
create table tblORDER_DETAIL
	(
		OrderDetailID int identity(1,1) not null,
		OrderID int not null,
		ProductID int not null,
		numPurchased int not null default 1,
		itemValue money not null

		constraint pk_tblORDER_DETAIL primary key (orderDetailID),
		constraint fk_tblORDER_DETAIL_tblORDER foreign key (OrderID) references tblORDER(OrderID),
		constraint fk_tblORDER_DETAIL_tblPRODUCT foreign key (ProductID) references tblPRODUCT(ProductID)
	)
go
create proc uspInsertSyntheticOrderDetails
	
	@num int = 1,
	@datetimebacktrack int = 0,
	@datetimespread int = 7
as
	while(@num > 0)
	begin
		--fetch random Customer ID.
		declare @CustomerID int
		set @CustomerID = floor(rand()*(select count(*) from tblCUSTOMER)) + 1
		--fetch random date in the last month.
		declare @Orderdatetime datetime
		set @Orderdatetime = getdate()-(rand()*@datetimespread)-@datetimebacktrack
		--declare random number of details between 3 and 6.
		declare @numDetails int
		set @numDetails = floor(rand()*4)+3

		--insert into the order table, and pull out the ID created.
		insert into tblORDER (CustomerID, OrderDatetime) values (@CustomerID, @Orderdatetime)
		declare @OrderID int
		set @OrderID = @@IDENTITY

		--iteratively insert into the OrderDetails table.
		while(@numDetails > 0)
		begin
			--feth random product
			declare @productID int
			set @productID = floor(rand()*(select count(*) from tblPRODUCT))+1
			--fetch random number of products to be sold, between 1 and 3.
			declare @numPurchased int
			set @numPurchased = (floor(rand())*3)+1
			--fetch current price of product to be sold.
			declare @price money
			set @price = (select ProductUnitPrice from tblPRODUCT where ProductID = @productID)
		
			insert into tblORDER_DETAIL (OrderID, ProductID, numPurchased, itemValue)
				values (@OrderID, @productID, @numPurchased, @price)		

			set @numDetails = @numDetails-1
		end
	set @num = @num - 1
	end
go

--construct ORDERDETAIL view
create view vDetails as
select 
	O.OrderID as [orderID],
	OD.OrderDetailID as [detailID],
	P.ProductName as [product name],
	C.CustomerName as [customer name],
	(OD.itemValue*OD.numPurchased) as [detail value]
from tblORDER as O
	join tblORDER_DETAIL as OD
		on O.OrderID = OD.OrderID
	join tblPRODUCT as P
		on P.ProductID = OD.ProductID
	join tblCUSTOMER as C
		on C.CustomerID = O.CustomerID
go

--add middle of the week data that should be noticeable.
exec uspInsertSyntheticOrderDetails @num = 500, @datetimebacktrack = 0, @datetimespread = 5
exec uspInsertSyntheticOrderDetails @num = 500, @datetimebacktrack = 7, @datetimespread = 5
exec uspInsertSyntheticOrderDetails @num = 500, @datetimebacktrack = 14, @datetimespread = 5
exec uspInsertSyntheticOrderDetails @num = 500, @datetimebacktrack = 21, @datetimespread = 5
--add general data that should be looked over by windowing functions with weights.
exec uspInsertSyntheticOrderDetails @num = 200, @datetimebacktrack = 0, @datetimespread = 28
select * from vDetails