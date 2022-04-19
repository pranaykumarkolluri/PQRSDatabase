-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetMeasureRulesConfigPart1]
	-- Add the parameters for the stored procedure here
@CMSYear int,
@CategoryId int,
@RuleId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@CategoryId=1)
	BEGIN

		IF(@RuleId=1)
		BEGIN
			select Measure_Num as Measure, Mandatory_Diagnos_Code as Value,'Value:Mandatory_Diagnos_Code 1 means true and O means false' as Description
			FROM tbl_Lookup_Measure Where CMSYear=@CMSYear order by DisplayOrder  --Rule1
		END
		ELSE IF(@RuleId=2)
		BEGIN

			 select Measure_Num as Measure,CASE When Measure_Scoring ='P' then CONVERT(bit,1) else CONVERT(bit,0) end as Value,'Value: 1 means P type measures and 0 means C type measures' as Description
				FROM tbl_Lookup_Measure Where CMSYear =@CMSYear  order by Measure_Scoring --Rule2
		END
		ELSE IF(@RuleId=5)
		BEGIN
			 
			 select Measure_Num as Measure, IsStratum_Required as Value, 'Value: IsStratum_Required= 1 or 0' as Description FROM tbl_Lookup_Measure
				Where  CMSYear=@CMSYear order by DisplayOrder --Rule5
		END
		ELSE IF(@RuleId=7)
		BEGIN
			 
			 select Measure_Num as Measure, Is_DiagCodeAsKey as Value, 'Value: Is_DiagCodeAsKey= 1 or 0' as Description FROM tbl_Lookup_Measure
				Where  CMSYear=@CMSYear order by DisplayOrder --Rule7
		END
		ELSE IF(@RuleId=16)
		BEGIN
			   select Measure_Num as Measure,  Is_eCQM as Value ,'Value: Is_eCQM=1  or 0' as Description
               from tbl_Lookup_Measure where  CMSYear=@CMSYear order by DisplayOrder
		END

	-- ACI_ID=3, indicates attestation measures. System adds these attestation measures while PI CMS submission

 
	END

	ELSE
	BEGIN
	      IF(@RuleId=14)
		  BEGIN
		      
			select MeasureId as Measure,
			 CASE WHEN ACI_Id=3 THEN CONVERT(bit,1) ELSE CONVERT(bit,0)  END  as Value,
			 'Value:ACI_ID=3, indicates attestation measures. System adds these attestation measures while PI CMS submission' as Description 
			  from tbl_Lookup_ACI_Data where CMSYear=@CMSYear --Rule14
		  END
	END


END

