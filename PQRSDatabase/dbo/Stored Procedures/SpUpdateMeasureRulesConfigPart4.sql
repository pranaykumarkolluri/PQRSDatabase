
CREATE PROCEDURE [dbo].[SpUpdateMeasureRulesConfigPart4]
	-- Add the parameters for the stored procedure here
@CmsYear  int,
@CategoryId  int,
@RuleId  int,
@MeasureRuleConfigPart4_Type  MeasureRuleConfigPart4_Type READONLY
AS
BEGIN


	IF(@RuleId=4)
	BEGIN
		
	   With MeasureData as(	   
	   select  distinct MeasureId,IsAcceptableDateRange  from @MeasureRuleConfigPart4_Type
	   )

	   Update   M set M.IsAcceptableDateRange=Md.IsAcceptableDateRange 
		from tbl_Lookup_Measure M  inner join
	    MeasureData Md on  M.Measure_ID=Md.MeasureId

      
	     delete  Av from tbl_Lookup_Acceptable_DateRange Av 		 
		 INNER  JOIN  @MeasureRuleConfigPart4_Type m ON M.MeasureId=Av.Measure_Id 
		              and ((M.StartDate is not null and M.EndDate is not null) or M.IsRemoveAll=1 )
													 
		 
       INSERT INTO [dbo].[tbl_Lookup_Acceptable_DateRange]
           ([Measure_ID]
           ,[Measure_Num]
           ,[CMSYear]
           ,[acceptable_date_start]
           ,[acceptable_date_end])

		 SELECT DT.MeasureId,
				M.Measure_num,
				M.CMSYear,
				DT.StartDate,
				DT.EndDate  		 
		 FROM @MeasureRuleConfigPart4_Type DT 
							inner join 
							tbl_Lookup_Measure M 
									ON DT.MeasureId=M.Measure_ID								
	            and ((DT.StartDate is not null and DT.EndDate is not null) )
	end
	
END


