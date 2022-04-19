-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpUpdateMeasureRulesConfigPart1]
	-- Add the parameters for the stored procedure here
@CmsYear  int,
@CategoryId  int,
@RuleId  int,
@MeasureRuleConfigPart1_Type  MeasureRuleConfigPart1_Type READONLY
AS
BEGIN
	IF(@RuleId=1)
	BEGIN
		
	   UPDATE m SET M.Mandatory_Diagnos_Code=T.ValueType  FROM tbl_Lookup_Measure M INNER JOIN
	      @MeasureRuleConfigPart1_Type T ON M.Measure_num=T.Measure_Num
											AND M.CMSYear=@CmsYear

	END

	ELSE IF(@RuleId=2)
	BEGIN
	    UPDATE m SET M.Measure_Scoring= Case WHEN T.ValueType=1 then 'P' ELSE 'C' END  FROM tbl_Lookup_Measure M INNER JOIN
	      @MeasureRuleConfigPart1_Type T ON M.Measure_num=T.Measure_Num
											AND M.CMSYear=@CmsYear


	END
    ELSE IF(@RuleId=3)
	BEGIN
	    UPDATE m SET M.Gender_Restriction=T.Value FROM tbl_Lookup_Measure M INNER JOIN
	      @MeasureRuleConfigPart1_Type T ON M.Measure_num=T.Measure_Num
											AND M.CMSYear=@CmsYear


	END
	ELSE IF(@RuleId=5)
	BEGIN
	    UPDATE m SET M.IsStratum_Required=T.ValueType FROM tbl_Lookup_Measure M INNER JOIN
	      @MeasureRuleConfigPart1_Type T ON M.Measure_num=T.Measure_Num
											AND M.CMSYear=@CmsYear


	END
	ELSE IF(@RuleId=7)
	BEGIN
	    UPDATE m SET M.Is_DiagCodeAsKey=T.ValueType FROM tbl_Lookup_Measure M INNER JOIN
	      @MeasureRuleConfigPart1_Type T ON M.Measure_num=T.Measure_Num
											AND M.CMSYear=@CmsYear


	END
	ELSE IF(@RuleId=16)
	BEGIN
	    UPDATE m SET M.Is_eCQM=T.ValueType FROM tbl_Lookup_Measure M INNER JOIN
	      @MeasureRuleConfigPart1_Type T ON M.Measure_num=T.Measure_Num
											AND M.CMSYear=@CmsYear


	END

	ELSE IF(@RuleId=14)
	BEGIN

	  UPDATE A SET A.ACI_Id = CASE WHEN t.ValueType=1 THEN 3 ELSE A.ACI_Id END 
	  FROM tbl_Lookup_ACI_Data A  INNER JOIN @MeasureRuleConfigPart1_Type T
	  ON T.Measure_Num=a.MeasureId AND a.CMSYear=@CmsYear
	
	END

	ELSE IF(@RuleId=6)
	BEGIN

	update  M set M.Priority_ID=P.Priority_ID  from tbl_Lookup_Measure M  
	inner join @MeasureRuleConfigPart1_Type T on M.Measure_num=T.Measure_Num and M.CMSYear=@CmsYear 
	inner join tbl_Lookup_Measure_Priority P on  P.Name=T.Value

	
	END

	
END

