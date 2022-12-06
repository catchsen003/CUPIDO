/* Create queries */

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

/* Drop queries */
drop table [CUPIDO].[dbo].[Fact_Trip_Details];
drop table [CUPIDO].[dbo].[Fact_Trip_Feedback];
drop table [CUPIDO].[dbo].[Master_Business_Unit];
drop table [CUPIDO].[dbo].[Master_Driver];
drop table [CUPIDO].[dbo].[Master_Time];

/* Select queries */
select * from [CUPIDO].[dbo].[Fact_Trip_Details];
select * from [CUPIDO].[dbo].[Fact_Trip_Feedback];
select * from [CUPIDO].[dbo].[Master_Business_Unit];
select * from [CUPIDO].[dbo].[Master_Driver];
select * from [CUPIDO].[dbo].[Master_Time];