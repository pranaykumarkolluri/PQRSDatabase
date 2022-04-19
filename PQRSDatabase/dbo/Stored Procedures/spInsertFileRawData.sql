

-- =============================================
-- Author:		Raju G
-- Create date: sep-3-2018
-- Description:	text/excel data insert into tbl_File_rawdata 
-- =============================================
CREATE PROCEDURE [dbo].[spInsertFileRawData] 
	-- Add the parameters for the stored procedure here
	
	@CreatedBy varchar(50),
	@FileId int,
	@tbl_File_rawdata_type tbl_File_rawdata_type READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	insert into tbl_File_rawdata (Fileid,
		[Exam_Date_Time]
      ,[Physician_Group_TIN]
      ,[Physician_NPI]
      ,[Patient_ID]
      ,[Patient_Age]
      ,[Patient_Gender]
      ,[Patient_Medicare_Beneficiary]
      ,[Patient_Medicare_Advantage]
      ,[Measure_Number]
      ,[CPT_Code]
      ,[Denominator_Diagnosis_Code]
      ,[Numerator_Response_value]
      ,[Measure_Extension_Num]
      ,[Extension_Response_Value]
      ,[Exam_Unique_ID]
	   ,created_date
	   ,createdby
	   ,Record_Status

	)
	select 
	@FileId,
		[Exam_Date_Time]
      ,[Physician_Group_TIN]
      ,[Physician_NPI]
      ,[Patient_ID]
      ,[Patient_Age]
      ,[Patient_Gender]
      ,[Patient_Medicare_Beneficiary]
      ,[Patient_Medicare_Advantage]
      ,[Measure_Number]
      ,[CPT_Code]
      ,[Denominator_Diagnosis_Code]
      ,[Numerator_Response_value]
      ,[Measure_Extension_Num]
      ,[Extension_Response_Value]
      ,[Exam_Unique_ID]
	  ,GETDATE()
	  ,@CreatedBy
	  ,'NotYetStarted'
	 from @tbl_File_rawdata_type
  
END
