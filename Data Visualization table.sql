/* Data Visualization */

/* Combine all the data from both master and transactions tables to a single table that is fed as input to Power BI */
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