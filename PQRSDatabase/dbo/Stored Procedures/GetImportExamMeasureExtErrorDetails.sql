
-- =============================================
-- Author:		Prasshanth kumar
-- Create date: 29-07-2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[GetImportExamMeasureExtErrorDetails]
    @ImportExamsMeasureExtID INT = 0
AS 
    BEGIN
        SET NOCOUNT ON ;--- added to prevent extra result sets from
	-- interfering with SELECT statements.
	
        IF OBJECT_ID('tempdb..#ExamMeasureExt') IS NOT NULL 
            DROP TABLE #ExamMeasureExt
        CREATE TABLE #ExamMeasureExt
            (
              ExamMeasureExtID INT NOT NULL ,
              [Description] VARCHAR(MAX) NOT NULL
            )

        INSERT  INTO #ExamMeasureExt
                SELECT  mde.Import_Measure_Data_ID ,
                        REPLACE(RTRIM(LTRIM(ISNULL(mde.Error_Codes_Desc, ''))),
                                CHAR(10), '|') AS [Hello]
                FROM    tbl_Import_Measure_Data_Extension mde
                WHERE   RTRIM(LTRIM(ISNULL(mde.Error_Codes_Desc, ''))) <> ''
                        AND ISNULL(mde.Import_Measure_Data_Ext_ID, 0) = CASE @ImportExamsMeasureExtID
                                                              WHEN 0
                                                              THEN ISNULL(mde.Import_Measure_Data_Ext_ID,
                                                              0)
                                                              ELSE @ImportExamsMeasureExtID
                                                              END


        IF EXISTS ( SELECT TOP 1
                            *
                    FROM    #ExamMeasureExt ) 
            BEGIN
                UPDATE  #ExamMeasureExt
                SET     [Description] = SUBSTRING(LTRIM(RTRIM([Description])),
                                                  1,
                                                  ( LEN(LTRIM(RTRIM([Description])))
                                                    - 1 ))
            END
        ELSE 
            BEGIN
                INSERT  INTO #ExamMeasureExt
                VALUES  ( @ImportExamsMeasureExtID, 'No Errors Found' )
            END


        SET nocount OFF
        SELECT --distinct ##ExamMeasure.Import_Exam_MeasureID,
                A.Item
        FROM    #ExamMeasureExt
                CROSS APPLY dbo.Split(#ExamMeasureExt.[Description], '|') AS A
        WHERE   LTRIM(RTRIM(RTRIM(A.Item))) <> ''


    END






