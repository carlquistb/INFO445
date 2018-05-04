/*
INFO 445 windowing lecture
prepared by: Brendan Carlquist
Spring 2018

learning objectives:
	understand the difference between set-based and iterative/pointer-based logical thinking.

additional resources:	
						Microsoft SQL Server 2012 High Performance T-SQL Using Window Functions, by Itzik Ben-Gan
						ISBN: 978-0-7356-5836-3
*/

--please run the auxilliary sql script for this lecture, from the Canvas announcement.
use windowing_lecture_netID
go

--Problem- computationally expensive to join aggregate data wth detailed data.

/*
tech 1- make a SELECT query that returns:
	orderID
	OrderLineItemID
	OrderLineItemTotalValue
	OrderTotalValue
*/
select * from vDetails

select 
	vD.[customer name],
	vD.[orderID], 
	vD.[detailID],
	vD.[product name],
	orderValue.[order value],
	vD.[detail value],
	([detail value] / orderValue.[order value]) * 100 as [percent of order]
from vDetails as vD
join (select orderID, sum([detail value]) as [order value] from vDetails group by orderID) as orderValue
	on orderValue.orderID = vD.orderID
order by [percent of order]

select 
	vD.[customer name],
	vD.[orderID],
	vD.[detailID],
	vD.[product name],
	sum([detail value]) 
		over(partition by vD.orderID) as [order value],
	vD.[detail value],
	100* vD.[detail value] / sum([detail value]) 
		over(partition by vD.orderID) as [percent of order]
from vDetails as vD
order by [percent of order]