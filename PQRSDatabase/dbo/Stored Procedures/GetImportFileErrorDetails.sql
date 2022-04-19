

-- =============================================
-- Author:		Prasshanth kumar
-- Create date: 29-07-2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[GetImportFileErrorDetails] 
	-- Add the parameters for the stored procedure here
    @ImportID INT = 0 ,
    @ImportExamsId INT = 0 ,
    @ImportExamId INT = 0 ,
    @ImportExamsMeasureId INT = 0 ,
    @ImportExamsMeasureExtID INT = 0
AS 
    BEGIN
        SET NOCOUNT ON ;--- added to prevent extra result sets from
	-- interfering with SELECT statements.
	
        IF OBJECT_ID('tempdb..#Mytemp') IS NOT NULL 
            DROP TABLE #Exams
        CREATE TABLE #Mytemp
            (
              ImportID INT NOT NULL ,
              [Description] VARCHAR(MAX) NOT NULL
            )

        INSERT  INTO #Mytemp
                SELECT  r.ImportID ,
                        REPLACE(RTRIM(LTRIM(ISNULL(r.Error_Codes, '')
                                            + ISNULL(es.Error_Codes_Desc, '')
                                            + ISNULL(e.Error_Codes_Desc, '')
                                            + ISNULL(md.Error_Codes_Desc, '')
                                            + ISNULL(mde.Error_Codes_Desc, '')
								     + ISNULL(md.Warning_Codes_Desc, '')
									 + ISNULL(md.Exclusion_Codes_Desc, '') 
								    )),
                                CHAR(10), '|') AS [Hello]
                FROM    tbl_Import_Raw R
                        LEFT JOIN tbl_Import_Exams es ON es.RawData_Id = r.ImportID
                        LEFT JOIN tbl_Import_Exam e ON e.Import_ExamsID = es.ExamsID
                        LEFT JOIN tbl_Import_Exam_Measure_Data md ON md.Import_ExamID = e.Import_examID
                        LEFT JOIN tbl_Import_Measure_Data_Extension mde ON mde.Import_Measure_Data_ID = md.Import_Exam_MeasureID
                WHERE   RTRIM(LTRIM(ISNULL(r.Error_Codes, '')
                                    + ISNULL(es.Error_Codes_Desc, '')
                                    + ISNULL(e.Error_Codes_Desc, '')
                                    + ISNULL(md.Error_Codes_Desc, '')
                                    + ISNULL(mde.Error_Codes_Desc, '')
							  + ISNULL(md.Warning_Codes_Desc, '')
							   + ISNULL(md.Exclusion_Codes_Desc, '') 
							 )) <> ''
                        AND r.ImportID = CASE @ImportID
                                           WHEN 0 THEN r.ImportID
                                           ELSE @ImportID
                                         END
                        AND es.ExamsID = CASE @ImportExamsId
                                           WHEN 0 THEN es.ExamsID
                                           ELSE @ImportExamsId
                                         END
                        AND ISNULL(e.Import_examID, 0) = CASE @ImportExamId
                                                           WHEN 0
                                                           THEN ISNULL(e.Import_examID,
                                                              0)
                                                           ELSE @ImportExamId
                                                         END
                        AND ISNULL(md.Import_Exam_MeasureID, 0) = CASE @ImportExamsMeasureId
                                                              WHEN 0
                                                              THEN ISNULL(md.Import_Exam_MeasureID,
                                                              0)
                                                              ELSE @ImportExamsMeasureId
                                                              END
                        AND ISNULL(mde.Import_Measure_Data_Ext_ID, 0) = CASE @ImportExamsMeasureExtID
                                                              WHEN 0
                                                              THEN ISNULL(mde.Import_Measure_Data_Ext_ID,
                                                              0)
                                                              ELSE @ImportExamsMeasureExtID
                                                              END


        IF EXISTS ( SELECT TOP 1
                            *
                    FROM    #Mytemp ) 
            BEGIN
                UPDATE  #Mytemp
                SET     [Description] = SUBSTRING(LTRIM(RTRIM([Description])),
                                                  1,
                                                  ( LEN(LTRIM(RTRIM([Description])))
                                                    - 1 ))
            END
        ELSE 
            BEGIN
                INSERT  INTO #Mytemp
                VALUES  ( @ImportID, 'No Errors Found' )
            END

        SELECT DISTINCT
                *
        INTO    #myTemp1
        FROM    #Mytemp 


        SET nocount OFF
--select  --#Mytemp.ImportID,
-- A.Item  from #Mytemp 
--cross apply dbo.Split(#Mytemp.[Description],'|') as A
--where ltrim(rtrim(rtrim(A.Item))) <> ''

        SELECT  --#Mytemp.ImportID,
                A.Item
        FROM    #myTemp1
                CROSS APPLY dbo.Split(#myTemp1.[Description], '|') AS A
        WHERE   LTRIM(RTRIM(RTRIM(A.Item))) <> ''



    END








