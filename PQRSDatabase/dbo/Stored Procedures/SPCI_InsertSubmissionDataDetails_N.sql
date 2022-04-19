-- =============================================
-- Author:		Raju G
-- Create date: <Create Date,,>
-- Description:	Inserting Submission Details
-- =============================================
create PROCEDURE [dbo].[SPCI_InsertSubmissionDataDetails_N]

@tbl_CI_Submissions_MSet_Data_Type tbl_CI_Submissions_MSet_Data_Type READONLY,

@tbl_CI_Submissions_Data_Type  tbl_CI_Submissions_Data_Type READONLY
AS
BEGIN

insert into tbl_CI_Submissions_Data

(
CI_Submission_Id, 
[Submissions_Req_Id]
      ,[Tin]
      ,[Npi]
      ,[SubmissionUniqueKey]
      ,[CmsYear]
      ,[EntityType]
      ,[CreatedDate]
      ,[CreatedBy])
  Select
   NEWID(),
  [Submissions_Req_Id]
      ,[Tin]
      ,[Npi]
      ,[SubmissionUniqueKey]
      ,[CmsYear]
      ,[EntityType]
      ,[CreatedDate]
      ,[CreatedBy]
  FROM @tbl_CI_Submissions_Data_Type

  insert into tbl_CI_Submissions_MSet_Data
  (
  CI_Mset_Id,
  [SubmissionUniqueKey]
  ,[MSet_UniqueKey_Id]
      ,[Category]
      ,[PerformanceStart]
      ,[PerformanceEnd]
      ,[Measure_Id]
      ,[Measure_Name]
      ,[value]
      ,[CreatedDate]
      ,[CreatedBy])
 select 
 NEWID(),
 [SubmissionUniqueKey]
      ,[MSet_UniqueKey_Id]
      ,[Category]
      ,[PerformanceStart]
      ,[PerformanceEnd]
      ,[Measure_Id]
      ,[Measure_Name]
      ,[value]
      ,[CreatedDate]
      ,[CreatedBy]
  FROM @tbl_CI_Submissions_MSet_Data_Type
END

