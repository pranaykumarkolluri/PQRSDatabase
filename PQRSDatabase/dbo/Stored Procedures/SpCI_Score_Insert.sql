

--DROP procedure SpCI_Score_Insert

-- =============================================
-- Author:		Hari & raju
-- Create date: oct 12,2018
-- Description:	Cms Integration Data Inserting
-- =============================================
CREATE PROCEDURE [dbo].[SpCI_Score_Insert] 
	-- Add the parameters for the stored procedure here
	@IsFromSheduler bit,
	@IsScoreSuccess bit,
	
@Tin varchar(9),
@Npi varchar(10),
@CmsYear int,
@CreatedBy varchar(50),
@Status  varchar(50),
@Response_Data varchar(max),
@Submission_Uniquekey_Id varchar(50),
@Method_Id int,
@Status_Id int ,
@Status_Code int,
@tbl_CI_Submission_Score_Type tbl_CI_Submission_Score_Type READONLY,
@Response_Start_Date datetime,
@Response_End_Date datetime,
@tbl_CI_Individual_Measure_Score_Type tbl_CI_Individual_Measure_Score_Type READONLY
AS
BEGIN
declare @RequestId int;
declare @Response_Id int;
--select 1 as 'hello'
-- Insert data into tbl_CI_RequsetData

INSERT INTO [dbo].[tbl_CI_RequestData]
           (
           [Tin]
           ,[Npi]
           ,[CmsYear]
       
           ,[CreatedDate]
           ,[CreatedBy],IsScoreRequired)
     VALUES
           (         
           @Tin,
           @Npi, 
           @CmsYear,
          
           GETDATE(),
           @CreatedBy,1)
set @RequestId=   Scope_Identity() 

--Fetch RequestId and Response Data insert into Tbl_CI_ResponseData
INSERT INTO [dbo].[tbl_CI_ResponseData]
           ([Method_Id]
           ,[Request_Id]
           --,[Response_Data]
           ,[Status_Id]
           ,[CreatedDate]
		   ,Status_Code
		   ,CreatedBy,
		    Status
		,Response_Start_Date
			,Response_End_Date)
     VALUES
           (@Method_Id, --@Method_Id
           @RequestId,
           --@Response_Data,
         @Status_Id, 
          GETDATE()
		, @Status_Code
		  ,@CreatedBy
		  ,@Status
		 ,@Response_Start_Date
		  ,@Response_End_Date)
set @Response_Id=   Scope_Identity() 


--#1  Inserting Score Tracking Details
--select * from tbl_CI_ScheduleGetScore




 ----
--Fetch Response_Id and Insert into tbl_Submission_Score
declare @Sub_ScoreId int;
if(@IsScoreSuccess =1)
begin
BEGIN TRY
begin Transaction

--JIRA 788
--start
/*
update  tbl_CI_ScheduleGetScore
set 
Status=@IsScoreSuccess ,IsFromSheduler =@IsFromSheduler,UpdatedBy=@CreatedBy,UpdatedDate=GETDATE()
where Submission_Uniquekey_Id =@Submission_Uniquekey_Id
*/
--end
--JIRA 788



--check condition--table have data or not with [Response_Data]='NoData'
INSERT INTO [dbo].[tbl_CI_Submission_Score]
           ([Submission_Uniquekey_Id]--1
           ,[Response_Id]--2
           ,[Response_Data]--3
           ,[QM_Weight_Score]--4
           ,[QM_UnWeight_Score]--5

           ,[QM_Max_Contribution]
           ,[QM_Weight_Msg]
           ,[QM_hasACRMeasure]
           ,[QM_hasQualityMeasures]
           ,[IA_Weight_Score]

           ,[IA_UnWeight_Score]
           ,[IA_Max_Contribution]
           ,[IA_Weight_Msg]
           ,[IA_hasIAWeightStatus]
           ,[IA_givenIACreditPCMH]

           ,[IA_givenIAStudyCredit]
           ,[IA_feedback_message]
           ,[PI_Weight_Score]
           ,[PI_Max_Contribution]
           ,[PI_Weight_Msg]

           ,[PI_baseScore]
           ,[PI_attestationBonusEligible]
           ,[PI_performance]
           ,[PI_bonus]
           ,[PI_cehrt_bonus]

           ,[PI_base_max]
           ,[PI_performance_max]
           ,[PI_bonus_max]
           ,[PI_cehrt_bonus_max]
           ,[PI_UnWeight_Score]

           ,[PI_feedback_message]
           ,[Total_Score]
           ,[CMS_Error_Message]
           ,[CMS_Warning_Message]
           ,[Created_Date]

           ,[CmsYear]
           ,[CreatedBy]--37
		 ,PI_hasMinimumPIPerformancePeriod
		 )

    SELECT
     @Submission_Uniquekey_Id
      ,@Response_Id--[Response_Id]   
	 ,Response_Data
      ,[QM_Weight_Score]
      ,[QM_UnWeight_Score]

      ,[QM_Max_Contribution]
      ,[QM_Weight_Msg]
      ,[QM_hasACRMeasure]
      ,[QM_hasQualityMeasures]
      ,[IA_Weight_Score]

      ,[IA_UnWeight_Score]
      ,[IA_Max_Contribution]
      ,[IA_Weight_Msg]
      ,[IA_hasIAWeightStatus]
      ,[IA_givenIACreditPCMH]

      ,[IA_givenIAStudyCredit]
      ,[IA_feedback_message]
      ,[PI_Weight_Score]
      ,[PI_Max_Contribution]
      ,[PI_Weight_Msg]

      ,[PI_baseScore]
      ,[PI_attestationBonusEligible]
      ,[PI_performance]
      ,[PI_bonus]
      ,[PI_cehrt_bonus]

      ,[PI_base_max]
      ,[PI_performance_max]
      ,[PI_bonus_max]
      ,[PI_cehrt_bonus_max]
      ,[PI_UnWeight_Score]

      ,[PI_feedback_message]
      ,[Total_Score]
      ,[CMS_Error_Message]
      ,[CMS_Warning_Message]
      ,GETDATE()

      ,@CmsYear--[CmsYear]
      ,@CreatedBy--[CreatedBy] --37
	 ,PI_hasMinimumPIPerformancePeriod

  FROM @tbl_CI_Submission_Score_Type
  set @Sub_ScoreId =SCOPE_IDENTITY()

  
				update tbl_CI_Source_UniqueKeys
					   set 
					    --  Submission_Uniquekey_Id=@Submission_Uniquekey_Id,
						--  MeasurementSet_Unquekey_id=@MeasurementSet_Unquekey_id,
						 -- IsMSetIdActive=1,
						 -- CmsSubmissionDate=@Created_Date,
						  Score_ResponseId=@Sub_ScoreId
					 
					   where
							 Submission_Uniquekey_Id=@Submission_Uniquekey_Id 
							 and CmsYear=@CmsYear 
							 and ISNULL(tin,'') =isnull(@Tin,'') 
							 and ISNULL(Npi,'')=ISNULL(@Npi,'')
							 and IsMSetIdActive=1
							
	
 -- Fetch Response_Id and insert into tbl_Individual_Measure_Score


INSERT INTO [dbo].[tbl_CI_Individual_Measure_Score]
           ([Measure_Name]
           ,[Measure_Score]
           ,[processingStatus]
           ,[totaldecileScore]
           ,[totalMeasurementPoints]

           ,[totalBonusPoints]
           ,[measurementPicker]
           ,[feedback_quality]
           ,[endToEndBonus]
           ,[outcomeOrPatientExperienceBonus]

           ,[highPriorityBonus]          
           ,[decile]
           ,[Contribution_Value]
           ,[Max_Contribution]
           ,[Measure_Weight]

           ,[Ia_Complete]
           ,[Pi_Type]
           ,[Ia_Message]
           ,[Notes]
           ,[Category_Id]
           ,[Sub_ScoreId]--21
		 )

    SELECT
     [Measure_Name]
      ,[Measure_Score]
      ,[processingStatus]
      ,[totaldecileScore]
      ,[totalMeasurementPoints]

      ,[totalBonusPoints]
      ,[measurementPicker]
      ,[feedback_quality]
      ,[endToEndBonus]
      ,[outcomeOrPatientExperienceBonus]

      ,[highPriorityBonus]     
      ,[decile]
      ,[Contribution_Value]
      ,[Max_Contribution]
      ,[Measure_Weight]

      ,[Ia_Complete]
      ,[Pi_Type]
      ,[Ia_Message]
      ,[Notes]
      ,[Category_Id]
      ,@Sub_ScoreId--21
  FROM @tbl_CI_Individual_Measure_Score_Type

  
commit Transaction
END TRY
BEGIN CATCH


INSERT INTO [dbo].[tbl_CI_FailureDetails]
           ([FailureCaseId]
           --,[CategoryId]
           ,[Tin]
           ,[Npi]
           ,[CmsYear]
           ,[FailureMessage]
           ,[CreatedDate]
           ,[CreatedBy])
     VALUES
           (11--<FailureCaseId, int,>
         --  ,<CategoryId, int,>
           ,@Tin--<Tin, varchar(9),>
           ,@Npi--<Npi, varchar(10),>
           ,@CmsYear--<CmsYear, int,>
           ,'Error in SpCI_Score_Insert from Sql server side: '+ERROR_MESSAGE()--<FailureMessage, varchar(max),>
           ,GETDATE()--<CreatedDate, datetime,>
           ,@CreatedBy--<CreatedBy, varchar(50),>
		 )
rollback Transaction


END CATCH
end

END








