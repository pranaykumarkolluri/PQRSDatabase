


-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 15/7/2014
-- Description:	Used to Truncate all import tables
-- =============================================
CREATE PROCEDURE [dbo].[spTruncateImportTables] 
	
AS
BEGIN
	truncate table dbo.tbl_Import_Measure_Data_Extension
	truncate table dbo.tbl_Import_Exam_Measure_Data
	truncate table dbo.tbl_Import_Exam
	truncate table dbo.tbl_Import_Exams
	truncate table dbo.tbl_Import_Raw
	
END



