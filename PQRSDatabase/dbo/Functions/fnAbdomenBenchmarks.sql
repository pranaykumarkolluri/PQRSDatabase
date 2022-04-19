




-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 5-10-2013
-- Description:	This function returns benchmark values for a passed userid, else for all the data available in 
--				tblAbdomen_form.
-- =============================================
CREATE FUNCTION [dbo].[fnAbdomenBenchmarks]
(
@Userid int = 0
)
RETURNS TABLE 
RETURN (



select 
--Physician_NPI,Exam_TIN
'Abdomen' as MeasureGroup
,Measure_Num as [MeasureName]
, cast(isnull(A.Performance_rate,0) as int) as [Actual]
, cast(isnull(M.Performance_Rate,0) as int) as [BenchmarkValue] 
,A.Performance_Numerator as [Numerator]
,A.Performance_denominator as [Denominator]
from dbo.tbl_Physician_Aggregation_Year A left join tbl_Measure_Mean_Performance_Rate M
on  M.CMS_Year =  A.CMS_Submission_Year  and m.Measure_No = A.Measure_Num 
inner join tbl_Users  U on U.NPI = A.Physician_NPI
 where A.CMS_Submission_Year = 2015  and U.UserID  = @Userid
 );


