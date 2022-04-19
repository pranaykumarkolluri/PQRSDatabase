
CREATE PROCEDURE [dbo].[SpUpdateMeasureRulesConfigPart5]
	-- Add the parameters for the stored procedure here
@CmsYear  int,
@CategoryId  int,
@RuleId  int,
@MeasureRuleConfigPart5_Type  MeasureRuleConfigPart5_Type READONLY
AS
BEGIN


	IF(@RuleId=8)
	BEGIN
		
	   With MeasureData as(
	   
	   select  distinct MeasureId,IsAvgMes  from @MeasureRuleConfigPart5_Type where ( (AvgMes !=null and Measure_Desc is not null)  or IsRemoveAll=1)
	   )

	   Update   M set M.Is_AvgMeasure=Md.IsAvgMes from tbl_Lookup_Measure M  inner join
				 	   MeasureData Md on  M.Measure_ID=Md.MeasureId
					   

					

	
    delete from tbl_lookup_Measure_Average  where Measure_Id
	
	in (select distinct  T.MeasureId from @MeasureRuleConfigPart5_Type T)   
	 
		 
       INSERT INTO [dbo].[tbl_lookup_Measure_Average]
           ([Measure_ID]
           ,[Avg_MeasureName]
		   ,Measure_Desc
		 )
		 select DT.MeasureId,DT.AvgMes,Measure_Desc from @MeasureRuleConfigPart5_Type DT 
		 where AvgMes is not null and Measure_Desc is not null		 
	end
	
END



