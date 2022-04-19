


-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 24-jul-2014
-- Description:	Used to wipeout transaction tables. Use with Caution.
-- =============================================
CREATE PROCEDURE [dbo].[spTruncateImportFilesDataInTables] 
	-- Add the parameters for the stored procedure here
AS 
    BEGIN
        DELETE  FROM dbo.tbl_Import_Measure_Data_Extension
        WHERE   Import_Measure_Data_ID IN (
                SELECT  Import_Exam_MeasureID
                FROM    dbo.tbl_Import_Exam_Measure_Data
                WHERE   Import_ExamID IN (
                        SELECT  Import_ExamID
                        FROM    dbo.tbl_Import_Exam
                        WHERE   Import_ExamsID IN (
                                SELECT  Import_ExamsID
                                FROM    dbo.tbl_Import_Exams
                                WHERE   RawData_Id IN (
                                        SELECT  ImportID
                                        FROM    dbo.tbl_Import_Raw ) ) ) )


        DELETE  FROM dbo.tbl_Import_Exam_Measure_Data
        WHERE   Import_ExamID IN (
                SELECT  Import_ExamID
                FROM    dbo.tbl_Import_Exam
                WHERE   Import_ExamsID IN (
                        SELECT  Import_ExamsID
                        FROM    dbo.tbl_Import_Exams
                        WHERE   RawData_Id IN ( SELECT  ImportID
                                                FROM    dbo.tbl_Import_Raw ) ) )

        DELETE  FROM dbo.tbl_Import_Exam
        WHERE   Import_ExamsID IN (
                SELECT  Import_ExamsID
                FROM    dbo.tbl_Import_Exams
                WHERE   RawData_Id IN ( SELECT  ImportID
                                        FROM    dbo.tbl_Import_Raw ) )


        DELETE  FROM dbo.tbl_Import_Exams
        WHERE   RawData_Id IN ( SELECT  ImportID
                                FROM    dbo.tbl_Import_Raw )

        DELETE  FROM dbo.tbl_Import_Raw
    END



