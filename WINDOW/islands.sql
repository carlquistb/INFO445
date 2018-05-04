/* 
identifying islands

your boss wants to know times of high volume, and times of low volume. How do we determine this in SQL?

this is the end goal:

|--beginDate--||---endDate---|
|=============||=============|
|-2018-04-08--||--2018-04-12-|
|-2018-04-15--||--2018-04-19-|
|-2018-04-22--||--2018-04-26-|
|-2018-04-29--||--2018-05-03-|

*/

--we have orders in a table.
select * from tblORDER
go
--select only what we need:
select
	CAST(OrderDateTime as DATE) as [date] 
from tblORDER
go
--determine the number of each of the same date:
select 
	count(CAST(OrderDateTime as DATE)) [numOrders], CAST(OrderDateTime as DATE) [date]
from tblORDER
group by CAST(OrderDateTime as DATE)
order by CAST(OrderDateTime as DATE)
go
--filter dates that have 'wimpy' numbers. Realistically, you would use 3 times the std dev.
select 
	CAST(OrderDateTime as DATE) [date]
from tblORDER
group by CAST(OrderDateTime as DATE)
having count(CAST(OrderDateTime as DATE)) > 50
order by CAST(OrderDateTime as DATE)
go
--now, we know the dates that we care about. We now want to locate the consecutive values, start and end dates.
with dates as (select CAST(OrderDateTime as DATE) [date] from tblORDER group by CAST(OrderDateTime as DATE) having count(CAST(OrderDateTime as DATE)) > 50)
select A.[date],
	(select	
		min(B.[date])
		from dates as B
		where B.[date] >= A.[date] 
			and not exists (select * from dates as C where C.[date] = DATEADD(day, 1, B.[date]))) as [group]
from dates as A
order by date
go

--now use a group by on the group to get the minimum and maximum of each group.
with dates as (select CAST(OrderDateTime as DATE) [date] from tblORDER group by CAST(OrderDateTime as DATE) having count(CAST(OrderDateTime as DATE)) > 50)
select min([date]) as [start], max([date]) as [end]
from (
	select A.[date],
		(select	
			min(B.[date])
		from dates as B
		where B.[date] >= A.[date] 
			and not exists (select * from dates as C where C.[date] = DATEADD(day, 1, B.[date]))) as [group]
	from dates as A
) as D
group by [group]
go
--now, lets start that afresh with window functions.
with dates as (select CAST(OrderDateTime as DATE) [date] from tblORDER group by CAST(OrderDateTime as DATE) having count(CAST(OrderDateTime as DATE)) > 50)
select [date], row_number() over(order by [date]) as [rownum]
from dates
go
--we want to know if the difference between two consecutive dates is one day. Its kinda cool that our rownum increments by one...
with dates as (select CAST(OrderDateTime as DATE) [date] from tblORDER group by CAST(OrderDateTime as DATE) having count(CAST(OrderDateTime as DATE)) > 50)
select [date], dateadd(day, (row_number() over(order by [date]))*-1, [date]) as [difference]
from dates
go
--now, we can do the same as we did with simple code:
with dates as (select CAST(OrderDateTime as DATE) [date] from tblORDER group by CAST(OrderDateTime as DATE) having count(CAST(OrderDateTime as DATE)) > 50)
select min([date]) as [start], max([date]) as [end]
from (select [date], dateadd(day, (row_number() over(order by [date]))*-1, [date]) as [difference]
from dates) D
group by [difference]

go

--direct comparison:
--long
with dates as (select CAST(OrderDateTime as DATE) [date] from tblORDER group by CAST(OrderDateTime as DATE) having count(CAST(OrderDateTime as DATE)) > 50)
select 
	min([date]) as [start], 
	max([date]) as [end]
from (
	select
		A.[date],
		(
			select	
				min(B.[date])
			from dates as B
			where B.[date] >= A.[date] 
				and not exists (
									select * 
									from dates as C 
									where C.[date] = DATEADD(day, 1, B.[date]))
								) as [group]
		from dates as A
) D
group by [group]
go
--short:
with dates as (select CAST(OrderDateTime as DATE) [date] from tblORDER group by CAST(OrderDateTime as DATE) having count(CAST(OrderDateTime as DATE)) > 50)
select 
	min([date]) as [start], 
	max([date]) as [end]
from (
		select 
			[date], 
			dateadd(day, (row_number() over(order by [date]))*-1, [date]) as [difference]
		from dates
) D
group by [difference]
go

