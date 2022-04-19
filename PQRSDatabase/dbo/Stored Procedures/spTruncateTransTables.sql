




-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 24-jul-2014
-- Description:	Used to wipeout transaction tables. Use with Caution.
-- =============================================
CREATE PROCEDURE [dbo].[spTruncateTransTables] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	delete from dbo.tbl_Exam_Measure_Data_Extension where Exam_Measure_Data_ID in (
select Exam_Measure_Id from  dbo.tbl_Exam_Measure_Data where Exam_Id in (
select  Exam_Id  from  dbo.tbl_Exam
)
)

delete from  dbo.tbl_Exam_Measure_Data where Exam_Id in (
select  Exam_Id  from  dbo.tbl_Exam
)

delete from dbo.tbl_Exam

END





