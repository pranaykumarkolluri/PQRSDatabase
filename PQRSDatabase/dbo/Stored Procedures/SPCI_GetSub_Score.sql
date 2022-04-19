
-- =============================================
-- Author:		Harikrishna
-- Create date:24/10/2018
-- Description:	get the CI score based on TIN and Year
--#1 Raju G: Sp used for TINNpi Combination of getting score from only "tbl_CI_Submission_Score" this table  
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_GetSub_Score]
	-- Add the parameters for the stored procedure here
	@TIN varchar(9),
	@Npi varchar(10),
	@CMSYear int,
	@Category_ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	declare @Sub_Score_Id int;
	set @Sub_Score_Id =0;

	select  top 1 @Sub_Score_Id =B.Sub_ScoreId from tbl_CI_Source_UniqueKeys A inner join tbl_CI_Submission_Score B on 
	  A.Submission_Uniquekey_Id =B.Submission_Uniquekey_Id		
	  where 
	  A.tin=@TIN and ISNULL(A.Npi,'') =case ISNULL(@Npi,'') when '' then '' else @Npi end 
	  and A.CmsYear=@CMSYear
	  and A.IsMSetIdActive=1
	   and A.CmsYear=B.CmsYear
	    order by B.Sub_ScoreId desc

	select distinct 
	
	@TIN as TIN,
	@Npi as NPI
	--,@CMSYear as CMSYear
	, (select Category_Name from tbl_CI_lookup_Categories where Category_Id=@Category_ID) AS Category_Name,
      sc.[Sub_ScoreId]
    --  ,sc.[Submission_Uniquekey_Id]
     -- ,sc.[Response_Id]
      ,sc.[Response_Data]
      ,CAST(ISNULL(sc.[QM_Weight_Score],0) as numeric (18,1) )as QM_Weight_Score
      ,CAST(ISNULL(sc.[QM_UnWeight_Score],0) as numeric (18,1) )as QM_UnWeight_Score
      ,CAST(ISNULL(sc.[QM_Max_Contribution],0) as numeric (18,1) )as QM_Max_Contribution
      ,sc.[QM_Weight_Msg]
      ,sc.[QM_hasACRMeasure]
      ,sc.[QM_hasQualityMeasures]
      ,CAST(ISNULL(sc.[IA_Weight_Score],0) as numeric (18,1) )as IA_Weight_Score
      ,CAST(ISNULL(sc.[IA_UnWeight_Score],0) as numeric (18,1) )as IA_UnWeight_Score
      ,CAST(ISNULL(sc.[IA_Max_Contribution],0) as numeric (18,1) )as IA_Max_Contribution
      ,sc.[IA_Weight_Msg]
      ,sc.[IA_hasIAWeightStatus]
      ,sc.[IA_givenIACreditPCMH]
      ,sc.[IA_givenIAStudyCredit]
      ,sc.[IA_feedback_message]
      ,CAST(ISNULL(sc.[PI_Weight_Score],0) as numeric (18,1) )as PI_Weight_Score
      ,CAST(ISNULL(sc.[PI_Max_Contribution],0) as numeric (18,1) )as PI_Max_Contribution
      ,sc.[PI_Weight_Msg]
      ,CAST(ISNULL(sc.[PI_baseScore],0) as numeric (18,1) )as PI_baseScore
      ,CAST(ISNULL(sc.[PI_attestationBonusEligible],0) as numeric (18,1) )as PI_attestationBonusEligible
      ,CAST(ISNULL(sc.[PI_performance],0) as numeric (18,1) )as PI_performance
      ,CAST(ISNULL(sc.[PI_bonus],0) as numeric (18,1) )as PI_bonus
      ,CAST(ISNULL(sc.[PI_cehrt_bonus],0) as numeric (18,1) )as PI_cehrt_bonus
      ,CAST(ISNULL(sc.[PI_base_max],0) as numeric (18,1) )as PI_base_max
      ,CAST(ISNULL(sc.[PI_performance_max],0) as numeric (18,1) )as PI_performance_max
      ,CAST(ISNULL(sc.[PI_bonus_max],0) as numeric (18,1) )as PI_bonus_max
      ,CAST(ISNULL(sc.[PI_cehrt_bonus_max],0) as numeric (18,1) )as PI_cehrt_bonus_max
      ,CAST(ISNULL(sc.[PI_UnWeight_Score],0) as numeric (18,1) )as PI_UnWeight_Score
      ,sc.[PI_feedback_message]
      ,CAST(ISNULL(sc.[Total_Score],0) as numeric (18,1) )as Total_Score
      ,sc.[CMS_Error_Message]
      ,sc.[CMS_Warning_Message]
      ,sc.[Created_Date]
      ,sc.[CmsYear]
      ,sc.[CreatedBy]
	  ,sc.PI_hasMinimumPIPerformancePeriod

	 from  tbl_CI_Submission_Score Sc
	 INNER JOIN tbl_CI_Source_UniqueKeys SU on SU.Submission_Uniquekey_Id=sc.Submission_Uniquekey_Id
	 and SU.CmsYear=@CMSYear
	 and SU.IsMSetIdActive=1
	where 	
	 Sc.Sub_ScoreId =@Sub_Score_Id 

END

