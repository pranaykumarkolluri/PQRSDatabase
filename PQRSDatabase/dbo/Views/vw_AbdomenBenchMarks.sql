CREATE VIEW [dbo].[vw_AbdomenBenchMarks]
AS

select  'Abdomen' as [MeasureGroup] 
, Measure_Num  as [MeasureName]
,cast(Performance_rate as int) 'Actual'
,CAST( (50.56) as  int) as BenchmarkValue
,cast(0 as int) as [Numerator]
,cast(0 as int) as [Denominator]
from tbl_Physician_Aggregation_Year where  CMS_Submission_Year = 2014


