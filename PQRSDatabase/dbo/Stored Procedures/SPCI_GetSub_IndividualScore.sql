-- =============================================
-- Author:		Harikrishna
-- Create date:Dec 20,2018
-- Description:	get the CI INDIVIDUAL  score based on TIN and Year
  
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_GetSub_IndividualScore]
	-- Add the parameters for the stored procedure here
	@TIN varchar(9),
	@Npi varchar(10),
	@CMSYear int,
	@Category_ID int,
	@Sub_Score_Id int
AS
BEGIN

DECLARE @Key_ID int;


SET @Key_ID=(SELECT TOP 1 A.Key_Id from tbl_CI_Source_UniqueKeys A where A.Tin=@TIN
and  ISNULL(A.Npi,'') =case ISNULL(@Npi,'') when '' then '' else @Npi end 
AND A.Category_Id=@Category_ID 
AND A.CmsYear=@CMSYear
AND A.IsMSetIdActive=1)

	
	SELECT [Individual_Mes_ScoreId]
      ,[Measure_Name]
      ,CAST(ISNULL([Measure_Score],0) as numeric (18,1) )as Measure_Score
      ,[processingStatus]
      ,CAST(ISNULL([totaldecileScore],0) as numeric (18,1) )as totaldecileScore
      ,CAST(ISNULL([totalMeasurementPoints],0) as numeric (18,1) )as totalMeasurementPoints
      ,CAST(ISNULL([totalBonusPoints],0) as numeric (18,1) )as totalBonusPoints
      ,[measurementPicker]
      ,[feedback_quality]
      ,CAST(ISNULL([endToEndBonus],0) as numeric (18,1) )as endToEndBonus
      ,CAST(ISNULL([outcomeOrPatientExperienceBonus],0) as numeric (18,1) )as outcomeOrPatientExperienceBonus
      ,CAST(ISNULL([highPriorityBonus],0) as numeric (18,1) )as highPriorityBonus
      ,CAST(ISNULL([decile],0) as numeric (18,1) )as decile
      ,CAST(ISNULL([Contribution_Value],0) as numeric (18,1) )as Contribution_Value
      ,CAST(ISNULL([Max_Contribution],0) as numeric (18,1) )as Max_Contribution
      ,[Measure_Weight]
      ,[Ia_Complete]
      ,[Pi_Type]
      ,[Ia_Message]
      ,[Notes]
      ,[Category_Id]
      ,[Sub_ScoreId]
  FROM [dbo].[tbl_CI_Individual_Measure_Score]
  WHERE Category_Id=@Category_ID and Sub_ScoreId=@Sub_Score_Id

  UNION 

  
 SELECT 
	0 as [Individual_Mes_ScoreId]
      ,[Measure_Name]
      ,0.0 as [Measure_Score]
      ,'Not Available' as [processingStatus]
      ,0.0 as [totaldecileScore]
      ,0.0 as [totalMeasurementPoints]
      ,0.0 as [totalBonusPoints]
      ,'Not Available' as [measurementPicker]
      ,'Not Available' as [feedback_quality]
      ,0.0 as [endToEndBonus]
      ,0.0 as [outcomeOrPatientExperienceBonus]
      ,0.0 as [highPriorityBonus]
      ,0.0 as [decile]
      ,0.0 as [Contribution_Value]
      ,0.0 as [Max_Contribution]
      ,'Not Available' as [Measure_Weight]
      ,'Not Available' as [Ia_Complete]
      ,'Not Available' as [Pi_Type]
      ,'Not Available' as [Ia_Message]
      ,'Not Available' as [Notes]
      ,@Category_ID as[Category_Id]
      ,@Sub_Score_Id as [Sub_ScoreId]
  FROM [dbo].tbl_CI_Measuredata_value
  WHERE KeyId=@Key_ID 
  and CategoryId=@Category_ID
  and Measure_Name not in( SELECT Measure_Name from [tbl_CI_Individual_Measure_Score] where Sub_ScoreId=@Sub_Score_Id)
END

