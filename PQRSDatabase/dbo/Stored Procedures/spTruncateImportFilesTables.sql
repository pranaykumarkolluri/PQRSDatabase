-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 24-jul-2014
-- Description:	Used to wipeout transaction tables. Use with Caution.
-- =============================================
create PROCEDURE spTruncateImportFilesTables 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	delete from dbo.tbl_Import_Measure_Data_Extension where Import_Measure_Data_ID in (
select Import_Exam_MeasureID from  dbo.tbl_Import_Exam_Measure_Data where Import_ExamID in (
select  Import_ExamID  from  dbo.tbl_Import_Exam WHERE Import_ExamsID IN (

SELECT Import_ExamsID FROM dbo.tbl_Import_Exams where RawData_Id in ( 
select ImportID from dbo.tbl_Import_Raw
)
)
)
)


delete from  dbo.tbl_Import_Exam_Measure_Data where Import_ExamID in (
select  Import_ExamID  from  dbo.tbl_Import_Exam WHERE Import_ExamsID IN (

SELECT Import_ExamsID FROM dbo.tbl_Import_Exams where RawData_Id in ( 
select ImportID from dbo.tbl_Import_Raw
)
)
)

delete from  dbo.tbl_Import_Exam WHERE Import_ExamsID IN (

SELECT Import_ExamsID FROM dbo.tbl_Import_Exams where RawData_Id in ( 
select ImportID from dbo.tbl_Import_Raw
)
)


Delete FROM dbo.tbl_Import_Exams where RawData_Id in ( 
select ImportID from dbo.tbl_Import_Raw
)

delete from dbo.tbl_Import_Raw
END
