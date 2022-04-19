



-- =============================================
-- Author:		Prasshanth kumar
-- Create date: 29-07-2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[GetImportExamMeasureErrorDetails]
    @ImportExamsMeasureId INT = 0 ,
    @ImportExamsMeasureExtID INT = 0
AS 
    BEGIN
        SET NOCOUNT ON ;--- added to prevent extra result sets from
	-- interfering with SELECT statements.
	
        IF OBJECT_ID('tempdb..#ExamMeasure') IS NOT NULL 
            DROP TABLE #ExamMeasure
        CREATE TABLE #ExamMeasure
            (
              ExamMeasureID INT NOT NULL ,
              [Description] VARCHAR(MAX) NOT NULL
            )

        INSERT  INTO #ExamMeasure
                SELECT  md.Import_Exam_MeasureID ,
                        REPLACE(RTRIM(LTRIM(ISNULL(md.Error_Codes_Desc, '')
                                            + ISNULL(mde.Error_Codes_Desc, '')
								    + ISNULL(md.Warning_Codes_Desc, '') 
								     + ISNULL(md.Exclusion_Codes_Desc, '') 
								    )),
                                CHAR(10), '|') AS [Hello]
                FROM    tbl_Import_Exam_Measure_Data md
                        LEFT JOIN tbl_Import_Measure_Data_Extension mde ON mde.Import_Measure_Data_ID = md.Import_Exam_MeasureID
                WHERE   RTRIM(LTRIM(ISNULL(md.Error_Codes_Desc, '')
                                    + ISNULL(mde.Error_Codes_Desc, '')
							  + ISNULL(md.Warning_Codes_Desc, '')
							   + ISNULL(md.Exclusion_Codes_Desc, '') 
							 )) <> ''
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
                    FROM    #ExamMeasure ) 
            BEGIN
                UPDATE  #ExamMeasure
                SET     [Description] = SUBSTRING(LTRIM(RTRIM([Description])),
                                                  1,
                                                  ( LEN(LTRIM(RTRIM([Description])))
                                                    - 1 ))
            END
        ELSE 
            BEGIN
                INSERT  INTO #ExamMeasure
                VALUES  ( @ImportExamsMeasureId, 'No Errors Found' )
            END


        SET nocount OFF
        SELECT --distinct ##ExamMeasure.Import_Exam_MeasureID,
                A.Item
        FROM    #ExamMeasure
                CROSS APPLY dbo.Split(#ExamMeasure.[Description], '|') AS A
        WHERE   LTRIM(RTRIM(RTRIM(A.Item))) <> ''


    END






