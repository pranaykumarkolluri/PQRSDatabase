

-- =============================================
-- Author:	Sumanth
-- Create date: April,16,2019
-- Description:	---
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_UpdateMeasureData]
	-- Add the parameters for the stored procedure here
	@Tin varchar(9),
	@NPI varchar(10),
	@Category_Id int,
	@tbl_CI_Measuredata_value_Type tbl_CI_Measuredata_value_Type READONLY
AS
BEGIN
	
INSERT INTO [dbo].[tbl_CI_Measuredata_value]
           (
           [CategoryId]
           ,[TIN]
           ,[NPI]
           ,[KeyId]
        
           ,[Measure_Name]
           ,[isEndToEndReported]
           ,[performanceMet]
           ,[eligiblePopulationExclusion]
           ,[eligiblePopulationException]
           ,[eligiblePopulation]
           ,[reportingRate]
           ,[performanceRate]
           ,[numerator]
           ,[denominator]
           ,[denominatorException]
           ,[numeratorExclusion]
           ,[valuebit]
        
           ,[Stratum_Name])

    SELECT 
      [CategoryId]
      ,[TIN]
      ,[NPI]
      ,[KeyId]
    
      ,[Measure_Name]
      , Case When isEndToEndReported ='Y' then 1 
	        When isEndToEndReported ='N' then 0
		     ELSE NULL END as isEndToEndReported
      , CASE When (performanceMet is null or performanceMet='') then null else Cast(performanceMet as int) end as performanceMet
	  , CASE When (eligiblePopulationExclusion is null or eligiblePopulationExclusion='') then null else Cast(eligiblePopulationExclusion as int) end as eligiblePopulationExclusion
       , CASE When (eligiblePopulationException is null or eligiblePopulationException='') then null else Cast(eligiblePopulationException as int) end as eligiblePopulationException
      , CASE When ([eligiblePopulation] is null or [eligiblePopulation]='') then null else Cast([eligiblePopulation] as int) end as [eligiblePopulation]

        , CASE When ([reportingRate] is null or [reportingRate]='') then null else Cast([reportingRate]  as decimal(18,4)) end as [reportingRate]
         , CASE When ([performanceRate] is null or [performanceRate]='') then null else Cast([performanceRate]  as decimal(18,4)) end as [performanceRate]
      , CASE When (numerator is null or numerator='') then null else Cast(numerator as int) end as numerator
      , CASE When (denominator is null or denominator='') then null else Cast(denominator as int) end as denominator

          , CASE When (denominatorException is null or denominatorException='') then null else Cast(denominatorException as int) end as denominatorException
      , CASE When (numeratorExclusion is null or numeratorExclusion='') then null else Cast(numeratorExclusion as int) end as numeratorExclusion
      ,Case When valuebit ='Y' then 1 
	        When valuebit ='N' then 0
		     ELSE NULL END as valuebit
     
      ,[Stratum_Name]
  FROM @tbl_CI_Measuredata_value_Type where Mid not in (select Mid from tbl_CI_Measuredata_value)
END



