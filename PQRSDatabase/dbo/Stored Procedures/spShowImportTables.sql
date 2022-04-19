-- =============================================
-- Author:		prashanth kumarGarlapally
-- Create date: 15/7/2014
-- Description:	display data in all import tables
-- =============================================
CREATE PROCEDURE [dbo].[spShowImportTables] 
	
AS
BEGIN
select * from  dbo.tbl_Import_Raw
select * from  dbo.tbl_Import_Exams
select * from  dbo.tbl_Import_Exam
select * from  dbo.tbl_Import_Exam_Measure_Data
select * from  dbo.tbl_Import_Measure_Data_Extension
	
	
	
	
END
