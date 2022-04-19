



-- =============================================
-- Author:		Prasshanth kumar
-- Create date: 29-07-2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[GetImportErrorDetails] 
	-- Add the parameters for the stored procedure here
    @ImportID INT = 0 ,
    @ImportExamsId INT = 0 ,
    @ImportExamId INT = 0 ,
    @ImportExamsMeasureId INT = 0 ,
    @ImportExamsMeasureExtID INT = 0
AS 
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SELECT  r.ImportID ,
                RTRIM(LTRIM(ISNULL(r.Error_Codes, '')
                            + ISNULL(es.Error_Codes_Desc, '')
                            + ISNULL(e.Error_Codes_Desc, '')
                            + ISNULL(md.Error_Codes_Desc, '')
                            + ISNULL(mde.Error_Codes_Desc, '')
					    + ISNULL(md.Warning_Codes_Desc, '')
					   
					   )) AS [Hello]
        FROM    tbl_Import_Raw R
                LEFT JOIN tbl_Import_Exams es ON es.RawData_Id = r.ImportID
                LEFT JOIN tbl_Import_Exam e ON e.Import_ExamsID = es.ExamsID
                LEFT JOIN tbl_Import_Exam_Measure_Data md ON md.Import_ExamID = e.Import_ExamsID
                LEFT JOIN tbl_Import_Measure_Data_Extension mde ON mde.Import_Measure_Data_ID = md.Import_Exam_MeasureID
--CROSS APPLY dbo.split(rtrim(ltrim(isnull(r.Error_Codes,'')+ ISNULL(es.Error_Codes_Desc,'')
--+ ISNULL(e.Error_Codes_Desc,'')
--+ ISNULL(md.Error_Codes_Desc ,'')
--+ ISNULL(mde.Error_Codes_Desc,''))),char(10)
--) AS s
        WHERE   RTRIM(LTRIM(ISNULL(r.Error_Codes, '')
                            + ISNULL(es.Error_Codes_Desc, '')
                            + ISNULL(e.Error_Codes_Desc, '')
                            + ISNULL(md.Error_Codes_Desc, '')
                            + ISNULL(mde.Error_Codes_Desc, '')
					   + ISNULL(md.Warning_Codes_Desc, '')
					   )) <> '' 
    END




