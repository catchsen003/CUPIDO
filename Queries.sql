/* Creating Master and Transaction tables */

/* Create query for table: Fact_Trip_Details*/
create table [CUPIDO].[dbo].[Fact_Trip_Details]
(
Trip_ID nvarchar(4) NOT NULL,
Pickup_Driver_ID nvarchar(7) NULL,
Trip_Start smalldatetime NULL,
Trip_End smalldatetime NULL,
Duration_Days int NULL,
Duration_Hours int NULL,
Duration_Minutes int NULL,
Duration nvarchar(30) NULL,
Distance float NULL,
Payment_Mode varchar(10) NULL,
Vehicle varchar(4) NULL,
Fare int NULL,
Delay_Early varchar(5) NULL,
Reason varchar(20) NULL
);

/* Create query for table: Fact_Trip_Feedback*/
create table [CUPIDO].[dbo].[Fact_Trip_Feedback]
(
Trip_ID nvarchar(4) NOT NULL,
Vehicle_Rating int NULL,
Driver_Rating int NULL,
Safety_Rating int NULL,
Convenience_Rating int NULL,
Price_Rating int NULL
);

/* Create query for table: Master_Business_Unit*/
create table [CUPIDO].[dbo].[Master_Business_Unit]
(
BU_ID varchar(2) NOT NULL,
BU_Name varchar(15) NULL
);

/* Create query for table: Master_Driver*/
create table [CUPIDO].[dbo].[Master_Driver]
(
Driver_ID nvarchar(7) NOT NULL,
First_Name varchar(15) NULL,
Last_Name varchar(15) NULL,
Mail_ID nvarchar(40) NULL,
Service float NULL
);

/* Create query for table: Master_Time*/
create table [CUPIDO].[dbo].[Master_Time]
(
Date_Full date NOT NULL,
DT# int NULL,
MM# int NULL,
YY# int NULL,
DY# varchar(10) NULL,
WK# nvarchar(3) NULL,
QR# nvarchar(2) NULL,
Week_Year nvarchar(8) NULL,
Quarter_Year nvarchar(7) NULL
);

/* To view entire table */
select * from [CUPIDO].[dbo].[Fact_Trip_Details];
select * from [CUPIDO].[dbo].[Fact_Trip_Feedback];
select * from [CUPIDO].[dbo].[Master_Business_Unit];
select * from [CUPIDO].[dbo].[Master_Driver];
select * from [CUPIDO].[dbo].[Master_Time];

/* To view first row from all tables*/
select top 1 * from [CUPIDO].[dbo].[Fact_Trip_Details];
select top 1 * from [CUPIDO].[dbo].[Fact_Trip_Feedback];
select top 1 * from [CUPIDO].[dbo].[Master_Business_Unit];
select top 1 * from [CUPIDO].[dbo].[Master_Driver];
select top 1 * from [CUPIDO].[dbo].[Master_Time];

/* Potential questions with solutions */

/* 
Q1:
Show the no.of trips for each BU_Name having all ratings (individually) more than or equal to 3 and 
the average of all 5 ratings more than or equal to 4. 
Display the BU_Name which has the highest no.of trips first.
*/
select D.BU_Name,count(C.Average_Rating) as [No.of_Trips] from
(
select B.BU_Name,((A.Vehicle_Rating+A.Driver_Rating+A.Safety_Rating+A.Convenience_Rating+A.Price_Rating)/5) as [Average_Rating]
from [CUPIDO].[dbo].[Fact_Trip_Feedback] as A
join [CUPIDO].[dbo].[Master_Business_Unit] as B
on left(A.Trip_ID,2)=B.BU_ID
where A.Vehicle_Rating>=3 and A.Driver_Rating>=3 and A.Safety_Rating>=3 and A.Convenience_Rating>=3 and A.Price_Rating>=3 and 
((A.Vehicle_Rating+A.Driver_Rating+A.Safety_Rating+A.Convenience_Rating+A.Price_Rating)/5)>=4
group by B.BU_Name,A.Vehicle_Rating,A.Driver_Rating,A.Safety_Rating,A.Convenience_Rating,A.Price_Rating
) as C
right join [CUPIDO].[dbo].[Master_Business_Unit] as D
on C.BU_Name=D.BU_Name
group by D.BU_Name
order by [No.of_Trips] desc;

/*
Q2:
Display the year, no.of days trip days, no.of non-trip days and the percentage of occupancy.
occupancy (%) = (no.of days trip days/no.of days in the year)*100
*/
with cte1 as 
(
select count(*) as Total_days from [CUPIDO].[dbo].[Master_Time]
),
cte2 as 
(
select year(Trip_Start) as [Year],count(distinct(cast(Trip_Start as date))) as Trips_dates,
(select Total_days from cte1)-count(distinct(cast(Trip_Start as date))) as Non_Trips_dates
from [CUPIDO].[dbo].[Fact_Trip_Details]
group by year(Trip_Start)
)
select [Year],Trips_dates,Non_Trips_dates,
cast(cast(Trips_dates as decimal(10,2))/cast(Total_days as decimal(10,2))*100 as decimal(10,2)) as [Occupancy (%)] from cte2,cte1;

/*
Q3:
We want to send an email to the drivers who have the ranks in top 3. 
More than 1 driver can share the same rank.
Rank the drivers based on the all following conditions:
1. Trip distance is atleast 10 km
2. Fare is atleast 120
Display the Driver's rank, Driver ID, Driver name, Driver mail ID and the no.of trips that satify the condition.
*/
select * from
(
select dense_rank() over(order by count(Trip_ID) desc) as Driver_Rank,
B.Driver_ID,concat(B.First_Name,' ',B.Last_Name) as Driver_Name,
B.Mail_ID,
count(Trip_ID) as [No.of Trips]
from [CUPIDO].[dbo].[Fact_Trip_Details] as A
join [CUPIDO].[dbo].[Master_Driver] as B
on A.Pickup_Driver_ID=B.Driver_ID
where A.Distance>=10 and A.Fare>=150
group by B.Driver_ID,concat(B.First_Name,' ',B.Last_Name),B.Mail_ID
) as C
where Driver_Rank in (1,2,3);

/*
Q4:
Senior management wants to know that one driver who has less than or equal to 1.5 years of service and satifies the following:
1. has the least fare per distance
2. has taken the least no.of trips
Fare per distance = Fare/km
Display the Driver ID, Driver name, Driver mail ID.
Two driver's cannot share the same rank.
*/
select C.Driver_ID,C.Driver_Name,C.Mail_ID from
(
select B.[Driver_ID],concat(B.First_Name,' ',B.Last_Name) as Driver_Name,B.Mail_ID,
round(avg(A.Fare/A.Distance),2) as [Fare_per_distance],
count(*) as [No.of_Trips],
rank()over(order by round(avg(A.Fare/A.Distance),2),count(*)) as [Rank]
from [CUPIDO].[dbo].[Fact_Trip_Details] as A
join [CUPIDO].[dbo].[Master_Driver] as B
on A.Pickup_Driver_ID=B.Driver_ID
where B.Service<=1.5
group by B.[Driver_ID],concat(B.First_Name,' ',B.Last_Name),B.Mail_ID
) as C
where C.[Rank]=1;

/*
Q5:
Show the Quarter-wise trip count and their respective contribution in % for the year 2022
contribution (%) = no.of trips in quarter/total no.of trips
*/
select B.Quarter_Year,count(A.Trip_ID) as Trip_count,
cast((cast(count(A.Trip_ID) as decimal(10,2))/(select cast(count(Trip_ID) as decimal(10,2)) as Trip_total_count 
from [CUPIDO].[dbo].[Fact_Trip_Details]))*100 as decimal(10,2)) as [Contribution (%)]
from [CUPIDO].[dbo].[Fact_Trip_Details] as A
join [CUPIDO].[dbo].[Master_Time] as B
on cast(A.Trip_Start as date)=B.Date_Full
group by B.Quarter_Year;

/*
Q6:
Show the Day (e.g. Monday) which has the highest no.of trips 
*/
select C.DY# from 
(
select top 1 B.DY#,count(*) as [No.of_Trips] from [CUPIDO].[dbo].[Fact_Trip_Details] as A
join [CUPIDO].[dbo].[Master_Time] as B
on cast(A.Trip_Start as date)=B.Date_Full
group by B.DY#
order by [No.of_Trips] desc
) as C;

/*
Q7:
We need to send a report to Senior Management about the no.of trips that were delayed and early (category-wise) than the expected time 
according to the individual vechicles.
*/
select Vehicle, Delay_Early, count(Trip_ID) as [No.of_Trips]
from [CUPIDO].[dbo].[Fact_Trip_Details]
group by Vehicle, Delay_Early
order by Vehicle, Delay_Early;

/*
Q8:
Show the top 3 weeks along with the year (Week_Year column) and the Total_Fare in Rs. as the sum the the fares in the corresponding weeks
*/
select C.Week_Year,concat('Rs.',' ',Total_Fare) as [Total_Fare (Rs.)] from
(
select top 3 B.Week_Year, sum(A.Fare) as Total_Fare
from [CUPIDO].[dbo].[Fact_Trip_Details] as A
join [CUPIDO].[dbo].[Master_Time] as B
on cast(A.Trip_Start as date)=B.Date_Full
group by B.Week_Year
order by Total_Fare desc
) as C;

/*
Q9:
Find the frequent reason for which the trips were early than the expected time for Car.
Reasons for early:
1. Correct Location
2. No Traffic
3. Customer was nearby
*/
select top 1 Reason from 
(
select Reason, count(Trip_ID) as [No.of_Trips]
from [CUPIDO].[dbo].[Fact_Trip_Details]
where Reason in ('Correct Location','No Traffic','Customer was nearby') and Vehicle ='Car'
group by Reason
) as A
order by [No.of_Trips] desc;

/*
Q10:
Display the month name along with their respective no.of trips having the most trips on top and least trips at the bottom
*/
select 
case when month(B.Date_Full)=1 then 'January'
when month(B.Date_Full)=2 then 'February'
when month(B.Date_Full)=3 then 'March'
when month(B.Date_Full)=4 then 'April'
when month(B.Date_Full)=5 then 'May'
when month(B.Date_Full)=6 then 'June'
when month(B.Date_Full)=7 then 'July'
when month(B.Date_Full)=8 then 'August'
when month(B.Date_Full)=9 then 'September'
when month(B.Date_Full)=10 then 'October'
when month(B.Date_Full)=11 then 'November'
when month(B.Date_Full)=12 then 'December'
end
as [Month_number],count(A.Trip_ID) as [No.of trips]
from [CUPIDO].[dbo].[Fact_Trip_Details] as A
join [CUPIDO].[dbo].[Master_Time] as B
on cast(A.Trip_Start as date)=B.Date_Full
group by month(B.Date_Full)
order by [No.of trips] desc;

/* Combine all the data from both master and transactions tables to a single table that is fed as input to Power BI (for vizualization) */
select A.Trip_ID,
C.BU_ID, C.BU_Name,
A.Pickup_Driver_ID, 
D.First_Name, D.Last_Name, D.Mail_ID, D.Service,
A.Trip_Start, A.Trip_End, A.Duration_Days, A.Duration_Hours, A.Duration_Minutes, A.Duration,
E.DT#, E.MM#, E.YY#, E.DY#, E.WK#, E.QR#, E.Week_Year, E.Quarter_Year,
A.Distance, A.Payment_Mode, A.Vehicle, A.Fare,
B.Vehicle_Rating, B.Driver_Rating, B.Safety_Rating, B.Convenience_Rating, B.Price_Rating,
A.Delay_Early, A.Reason
from [CUPIDO].[dbo].[Fact_Trip_Details] as A
join [CUPIDO].[dbo].[Fact_Trip_Feedback] as B
on A.Trip_ID=B.Trip_ID
join [CUPIDO].[dbo].[Master_Business_Unit] as C
on left(A.Trip_ID,2)=C.BU_ID
join [CUPIDO].[dbo].[Master_Driver] as D
on A.Pickup_Driver_ID=D.Driver_ID
join [CUPIDO].[dbo].[Master_Time] as E
on cast(A.Trip_Start as date)=E.Date_Full;

/* To drop all rows from entire table */
drop table [CUPIDO].[dbo].[Fact_Trip_Details];
drop table [CUPIDO].[dbo].[Fact_Trip_Feedback];
drop table [CUPIDO].[dbo].[Master_Business_Unit];
drop table [CUPIDO].[dbo].[Master_Driver];
drop table [CUPIDO].[dbo].[Master_Time];