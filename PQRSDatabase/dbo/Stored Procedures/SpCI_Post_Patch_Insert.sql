


-- drop procedure SpCI_Post_Patch_Insert

-- =============================================
-- Author:		Hari & raju
-- Create date: oct 12,2018
-- Description:	Cms Integration Data Inserting
--Change #1: 08-mar-2019 
--Change #1: inserting the status of TIN/NPI for Batch submission
--Change #2: updating Response_Id in table tbl_CI_OptIn_Details

--Change #3: JIRA-767 numerator column data type modified to decimal instead of int
--Change #3: by Raju G
--Change#4 : by Pavan adding CMs Submission logic to bulk Submission
-- =============================================
CREATE PROCEDURE [dbo].[SpCI_Post_Patch_Insert] 
	-- Add the parameters for the stored procedure here
@InputCategory_Id int,
@Request_Data varchar(max),
@Tin varchar(9),
@Npi varchar(10),
@CmsYear int,
@Status  varchar(50),
@CreatedBy varchar(50),
@Method_Id int,
@Response_Data varchar(max),
@Status_Id int ,
@Submission_Uniquekey_Id varchar(50),
@MeasurementSet_Unquekey_id varchar(50),
@Measurement_Uniquekey_id varchar(50),
--@tbl_CI_Submission_Score_Type tbl_CI_Submission_Score_Type READONLY,
--@tbl_CI_Source_UniqueKeys_Type tbl_CI_Source_UniqueKeys_Type READONLY,
@Category_Id int,
@IsScoreSuccess bit,
@Status_Code int,
@IsFromSheduler bit,
@IsScoreRequired bit,
@IsPostType bit,
@ResponseStartDate datetime,
@measurecount int,
@Response_End_Date datetime,
@BulkGpro bit,
@ShedulerReqId int,
--@tbl_CI_Measure_Data_Type tbl_CI_Measure_Data_Type READONLY,
@tbl_CI_Measure_Data_value_Type tbl_CI_Measure_Data_value_Type READONLY,
@Created_Date datetime,
@IsBatchTins bit,
@cehrtId varchar(50)
AS
BEGIN



declare @RequestId int;
declare @Response_Id int;
DECLARE @KEY_ID int;
--select 1 as 'hello'
-- Insert data into tbl_CI_RequsetData
BEGIN TRY
Begin Transaction
INSERT INTO [dbo].[tbl_CI_RequestData]
           (
           [Category_Id]
           ,[Request_Data]
           ,[Tin]
           ,[Npi]
           ,[CmsYear]
          -- ,[Status]
           ,[CreatedDate]
           ,[CreatedBy],
		   IsScoreRequired)
     VALUES
           (
           @InputCategory_Id, 
           @Request_Data, 
           @Tin,
           @Npi, 
           @CmsYear,
         --  @Status,
           @Created_Date,
           @CreatedBy,@IsScoreRequired)
set @RequestId=   Scope_Identity() 

--Fetch RequestId and Response Data insert into Tbl_CI_ResponseData
INSERT INTO [dbo].[tbl_CI_ResponseData]
           ([Method_Id]
           ,[Request_Id]
           ,[Response_Data]
           ,[Status_Id]
           ,[CreatedDate]
		   ,[CreatedBy]
		   ,Status_Code
		   ,[Status]
		   ,Response_End_Date
		   ,Response_Start_Date
		   ,NoofMeasures)
     VALUES
           (@Method_Id,
           @RequestId,
           @Response_Data,
           @Status_Id, 
          --@Created_Date
		 --  GETDATE()   --this field used in schedularCI no need to change
		 @Created_Date
		  ,@CreatedBy
		  ,@Status_Code
		  
		  ,@Status
		  ,@Response_End_Date
		  ,@ResponseStartDate
		  ,@measurecount
		  )
set @Response_Id=   Scope_Identity() 
 --Batch Cms Upload time below code required. we will move into next release.Line No(113 to 127)


if(ISNULL(@ShedulerReqId,'') <> '' )
begin
--Change#4
update tbl_CI_BulkUpload_Requests
	set Status= case when @Status='success' then 7  else 20   end,
	EndDate=ISNULL(EndDate,GETDATE())
	  ,Request_Id=@RequestId
    where id=@ShedulerReqId and  Tin=@Tin and ISNULL(Npi,'')= ISNULL(@Npi,'')
	

	/*
	if(@BulkGpro =1)
	begin
	update tbl_CI_BulkUpload_AvailableGPROTINs set Request_ID=@RequestId ,Updated_Date=@Created_Date
	where TIN=@Tin and CMSYear=@CmsYear and Category_ID=@InputCategory_Id and Shedule_Requestid=@ShedulerReqId
	end
	else
	begin
	update tbl_CI_BulkUpload_Available_TINNPIs set Request_ID=@RequestId ,Updated_Date=@Created_Date
	where TIN=@Tin and NPI=@Npi
	 and CMSYear=@CmsYear and Category_ID=@InputCategory_Id and Shedule_Requestid=@ShedulerReqId
	end
	*/
	print('-')
end
/*
if(@IsBatchTins=1)          --Change #1
begin
Update tbl_CI_BulkTINNPI_CMSSubmission 
set CMSStatus=@Status,
IsSubmittoCMS=1,
Notes='',
Request_ID=@RequestId,
Updated_Date=@Created_Date,
Updated_By=@CreatedBy
where TIN=@Tin 
and ISNULL(NPI,'')=isnull(@Npi,'') 
and CMSYear=@CmsYear 
and IsSubmittoCMS=0
and Category_ID=@Category_Id
end
*/

--Fetch ResponseId and Insert Unique keys into Tbl_CI_Source_Uniquekeys



--if(@IsPostType=1)
--begin
  declare @MaxKeyId int;
  select @MaxKeyId=MAX(Key_Id) from  tbl_CI_Source_UniqueKeys where   Category_Id=@Category_Id and CmsYear=@CmsYear and ISNULL(tin,'') =isnull(@Tin,'') and ISNULL(Npi,'')=ISNULL(@Npi,'') and IsMSetIdActive=1

  update 

   tbl_CI_Source_UniqueKeys set 
   IsMSetIdActive=0
   where   
   Category_Id=@Category_Id 
   and CmsYear=@CmsYear 
   and ISNULL(tin,'') =isnull(@Tin,'') 
   and ISNULL(Npi,'')=ISNULL(@Npi,'') 
   and IsMSetIdActive=1
   and  Key_Id < @MaxKeyId

	if not exists(select 1 from  tbl_CI_Source_UniqueKeys where Category_Id=@Category_Id and CmsYear=@CmsYear and ISNULL(tin,'') =isnull(@Tin,'') and ISNULL(Npi,'')=ISNULL(@Npi,'') and IsMSetIdActive=1)
	begin
	
				INSERT INTO [dbo].[tbl_CI_Source_UniqueKeys]
						   ([Submission_Uniquekey_Id]
						   ,[MeasurementSet_Unquekey_id]
						   --,[Measurement_Uniquekey_id]
						   ,[Category_Id]
						   ,[Response_Id]
						   ,IsMSetIdActive
						   ,Tin
						   ,Npi
						   ,CmsYear,
						   CmsSubmissionDate
						   ,CehrtId)
						SELECT
							@Submission_Uniquekey_Id
						   ,@MeasurementSet_Unquekey_id
						   --,[Measurement_Uniquekey_id]
						   ,@Category_Id
						   ,@Response_Id
						   ,1 -- 1 active and 0 for deleted.
						   ,@Tin
						   ,@Npi
						   ,@CmsYear
						   ,@Created_Date
						   ,@cehrtId
		end
		else
		begin
			
				update tbl_CI_Source_UniqueKeys
					   set 
					      Submission_Uniquekey_Id=@Submission_Uniquekey_Id,
						  MeasurementSet_Unquekey_id=@MeasurementSet_Unquekey_id,
						  IsMSetIdActive=1,
						  CmsSubmissionDate=@Created_Date,
						  Response_Id=@Response_Id,
						  CehrtId=@cehrtId
					 
					   where
							 Category_Id=@Category_Id 
							 and CmsYear=@CmsYear 
							 and ISNULL(tin,'') =isnull(@Tin,'') 
							 and ISNULL(Npi,'')=ISNULL(@Npi,'')
							 and IsMSetIdActive=1
					    
		end
		   
   IF(@IsPostType=1)
   BEGIN 
         Declare @userid int;
		 set @userid=ISNULL(CAST(@CreatedBy as int),0)
         update tbl_CI_OptIn_Details set ResponseId=@Response_Id               --Change #2             
		 where Tin=@Tin and Npi=case when (@Npi is null or @Npi='') then Npi else @Npi end  and OptinYear=@CmsYear and CreatedBy=@userid
   END

----STEP#:find key id

SET @KEY_ID=0;
SELECT @KEY_ID=[Key_Id] from tbl_CI_Source_UniqueKeys where Submission_Uniquekey_Id=@Submission_Uniquekey_Id

and MeasurementSet_Unquekey_id=@MeasurementSet_Unquekey_id  
and IsMSetIdActive=1 
AND CmsYear=@CmsYear
AND  Category_Id=@Category_Id 
and ISNULL(tin,'') =isnull(@Tin,'') 
and ISNULL(Npi,'')=ISNULL(@Npi,'')
						

IF((@KEY_ID>0) AND (@Method_Id=5 OR @Method_Id=6) AND @Category_Id <> 5 )--@Method_Id=5--MeasurementSetPost OR @Method_Id=6--MeasurementSetPatch
BEGIN
delete from tbl_CI_Measuredata_value where [KeyId] =@KEY_ID
/*

INSERT INTO [dbo].[tbl_CI_Measure_Data]
           ([KeyId]
           ,[CategoryId]
          -- ,[PerformanceStart]
          -- ,[PerformanceEnd]
           ,[Measure_UniquekeyId]
           ,[Measure_Name]
           ,[value]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[Notes])
           --,[IMeasureStatus])
    SELECT 
    @KEY_ID,--keyid
     [CategoryId] ,
	--[PerformanceStart],
	--[PerformanceEnd],
	[Measure_Id] ,
	[Measure_Name] ,
	[value],
	@Created_Date,
	@CreatedBy ,
	[Notes]
	--1--[IMeasureStatus]
	  from @tbl_CI_Measure_Data_Type where [CategoryId] <> 5

	  */

	  INSERT INTO [dbo].[tbl_CI_Measuredata_value]
           (
		 
		   [CategoryId],
		   [TIN],
		   [NPI],
		   [KeyId]
          
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
           ,[Stratum_Name]
		   ,ObservationInstances
		   )

    SELECT 
	 @Category_Id
	   ,@TIN
	   ,@NPI
	   ,@KEY_ID
	 
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
      , CASE When (numerator is null or numerator='') then null else Cast(numerator as decimal) end as numerator
      , CASE When (denominator is null or denominator='') then null else Cast(denominator as decimal) end as denominator

          , CASE When (denominatorException is null or denominatorException='') then null else Cast(denominatorException as int) end as denominatorException
      , CASE When (numeratorExclusion is null or numeratorExclusion='') then null else Cast(numeratorExclusion as int) end as numeratorExclusion  
	  , CASE When (valuebit is null or valuebit='') then null else 
	    CASE When  valuebit='true' then 1
		     when valuebit='false' then 0 
			 else null end
	  end as valuebit  
	       
      ,[Stratum_Name]
	  , CASE When (observationInstances is null or observationInstances='') then null else Cast(observationInstances as int) end as observationInstances

	  
  FROM @tbl_CI_Measure_Data_value_Type 

END

Commit Transaction
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
           ,'Error in SpCI_Post_Patch_Insert from Sql server side: '+ERROR_MESSAGE()--<FailureMessage, varchar(max),>
           ,GETDATE()--<CreatedDate, datetime,>
           ,@CreatedBy--<CreatedBy, varchar(50),>
		 )
 Rollback Transaction
END CATCH
END

