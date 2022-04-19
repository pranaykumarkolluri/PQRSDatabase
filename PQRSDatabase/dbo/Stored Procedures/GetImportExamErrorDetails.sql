


-- =============================================
-- Author:		Prasshanth kumar
-- Create date: 29-07-2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[GetImportExamErrorDetails]
    @ImportExamId INT = 0 ,
    @ImportExamsMeasureId INT = 0 ,
    @ImportExamsMeasureExtID INT = 0
AS 
    BEGIN
        SET NOCOUNT ON ;--- added to prevent extra result sets from
	-- interfering with SELECT statements.
	
        IF OBJECT_ID('tempdb..#Exam') IS NOT NULL 
            DROP TABLE #Exam
        CREATE TABLE #Exam
            (
              ExamID INT NOT NULL ,
              [Description] VARCHAR(MAX) NOT NULL
            )

        INSERT  INTO #Exam
                SELECT  e.Import_examID ,
                        REPLACE(RTRIM(LTRIM(ISNULL(e.Error_Codes_Desc, '')
                                            + ISNULL(md.Error_Codes_Desc, '')
                                            + ISNULL(mde.Error_Codes_Desc, '')
								     + ISNULL(md.Warning_Codes_Desc, '')
									 + ISNULL(md.Exclusion_Codes_Desc, '') 
								    )),
                                CHAR(10), '|') AS [Hello]
                FROM    tbl_Import_Exam e
                        LEFT JOIN tbl_Import_Exam_Measure_Data md ON md.Import_ExamID = e.Import_examID
                        LEFT JOIN tbl_Import_Measure_Data_Extension mde ON mde.Import_Measure_Data_ID = md.Import_Exam_MeasureID
                WHERE   RTRIM(LTRIM(ISNULL(e.Error_Codes_Desc, '')
                                    + ISNULL(md.Error_Codes_Desc, '')
                                    + ISNULL(mde.Error_Codes_Desc, '')
							  + ISNULL(md.Warning_Codes_Desc, '')
							   + ISNULL(md.Exclusion_Codes_Desc, '') 
							 )) <> ''
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
                    FROM    #Exam ) 
            BEGIN
                UPDATE  #Exam
                SET     [Description] = SUBSTRING(LTRIM(RTRIM([Description])),
                                                  1,
                                                  ( LEN(LTRIM(RTRIM([Description])))
                                                    - 1 ))
            END
        ELSE 
            BEGIN
                INSERT  INTO #Exam
                VALUES  ( @ImportExamId, 'No Errors Found' )
            END


        SET nocount OFF
        SELECT --distinct #Exam.ExamID,
                A.Item
        FROM    #Exam
                CROSS APPLY dbo.Split(#Exam.[Description], '|') AS A
        WHERE   LTRIM(RTRIM(RTRIM(A.Item))) <> ''


    END


