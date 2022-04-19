
-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 20-jul-2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spMigrateExamMeasureDataExtension] 
	-- Add the parameters for the stored procedure here
@NewMeasure_Data_Id    INT,
@Import_measuredata_ID INT
AS
         BEGIN
             SET NOCOUNT ON;
             DECLARE @Import_Measure_Data_Ext_ID INT, @Import_Measure_Data_ID INT, @Import_Measure_Extension_Num VARCHAR(50), @Import_Measure_Extension_Reponse_Code VARCHAR(50);
             DECLARE @message VARCHAR(MAX);
             DECLARE @validMeasureNum VARCHAR(10), @validMeasureExtNum VARCHAR(10);
             DECLARE @intLookup_Mes_Data_Ext_Id INT;
             DECLARE @validCodes VARCHAR(1000);
             DECLARE @cmsSubmissionYear INT;
             DECLARE Cursor_Imp_Mes_Data_Ext CURSOR
             FOR SELECT Import_Measure_Data_Ext_ID,
                        Import_Measure_Data_ID,
                        Import_Measure_Extension_Num,
                        Import_Measure_Extension_Reponse_Code
                 FROM dbo.tbl_Import_Measure_Data_Extension
                 WHERE Import_Measure_Data_ID = @Import_measuredata_ID;
             OPEN Cursor_Imp_Mes_Data_Ext;
             FETCH NEXT FROM Cursor_Imp_Mes_Data_Ext INTO @Import_Measure_Data_Ext_ID, @Import_Measure_Data_ID, @Import_Measure_Extension_Num, @Import_Measure_Extension_Reponse_Code;
             WHILE @@FETCH_STATUS = 0
                 BEGIN
                     SET @validCodes = '';
                     SET @intLookup_Mes_Data_Ext_Id = 0;
                     SELECT @cmsSubmissionYear = YEAR(GETDATE());
                     SELECT @cmsSubmissionYear = isnull(CMS_Submission_Year, YEAR(GETDATE()))
                     FROM tbl_Exam_Measure_Data
                     WHERE Exam_Measure_Id = @NewMeasure_Data_Id;
                     SELECT TOP 1 @intLookup_Mes_Data_Ext_Id = Measure_Ext_Id
                     FROM tbl_Lookup_Measure_Extension
                     WHERE Other_Question_Num = @Import_Measure_Extension_Num
                           AND Measure_ID IN
(
    SELECT TOP 1 Measure_ID
    FROM tbl_Lookup_Measure
    WHERE Measure_num =
(
    SELECT TOP 1 Import_Measure_num
    FROM dbo.tbl_Import_Exam_Measure_Data
    WHERE Import_Exam_MeasureID = @Import_measuredata_ID
)
          AND CMSYear = @cmsSubmissionYear
);
                     SELECT @validCodes = @validCodes+CASE @validCodes
                                                          WHEN ''
                                                          THEN ''
                                                          ELSE ','
                                                      END+LTRIM(RTRIM(isnull(Measure_Ext_Response_Code_Value, '')))
                     FROM dbo.Split_IgnoreParantheses(@Import_Measure_Extension_Reponse_Code, ',')
                          INNER JOIN tbl_Lookup_Measure_Extension_values ON LTRIM(RTRIM(isnull(Item, ''))) = LTRIM(RTRIM(isnull(Measure_Ext_Response_Code, '')))
                     WHERE Measure_Ext_Id = @intLookup_Mes_Data_Ext_Id;
                     IF EXISTS
(
    SELECT Exam_Measure_Data_Ext_ID
    FROM tbl_Exam_Measure_Data_Extension
    WHERE Measure_Ext_Id = @intLookup_Mes_Data_Ext_Id
          AND Other_Question_num = @Import_Measure_Extension_Num
          AND Exam_Measure_Data_ID = @NewMeasure_Data_Id
)
                         BEGIN
                             UPDATE tbl_Exam_Measure_Data_Extension
                               SET
                                   Measure_Ext_Id = @intLookup_Mes_Data_Ext_Id,
                                   Other_Question_num = @Import_Measure_Extension_Num,
                                   Exam_Measure_Data_ID = @NewMeasure_Data_Id,
                                   Response_Value = @validCodes,
                                   Last_Modified_By = 'ImportWorkFlow',
                                   Last_Modified_Date = GETDATE();
                         END;
                         ELSE
                         BEGIN
                             INSERT INTO [tbl_Exam_Measure_Data_Extension]
([Exam_Measure_Data_ID],
 [Measure_Ext_Id],
 [Other_Question_num],
 [Response_Value],
 [Created_by],
 [Created_Date],
 [Last_Modified_Date],
 [Last_Modified_By]
)
                             VALUES
(@NewMeasure_Data_Id,
 @intLookup_Mes_Data_Ext_Id,
 @Import_Measure_Extension_Num,
 @validCodes,
 'ImportWorkFlow',
 GETDATE(),
 GETDATE(),
 'ImportWorkFlow'
);
                         END;
                     FETCH NEXT FROM Cursor_Imp_Mes_Data_Ext INTO @Import_Measure_Data_Ext_ID, @Import_Measure_Data_ID, @Import_Measure_Extension_Num, @Import_Measure_Extension_Reponse_Code;
                 END;
             CLOSE Cursor_Imp_Mes_Data_Ext;
             DEALLOCATE Cursor_Imp_Mes_Data_Ext;
         END;

