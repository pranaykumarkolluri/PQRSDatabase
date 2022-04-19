

-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 20-jul-2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spDeleteMigrateImportData]
AS 
    BEGIN
        DELETE  FROM tbl_Exam_Measure_Data_Extension
        WHERE   Exam_Measure_Data_ID IN (
                SELECT  Exam_Measure_Id
                FROM    tbl_Exam_Measure_Data
                WHERE   Exam_Id IN ( SELECT exam_id
                                     FROM   tbl_Exam
                                     WHERE  Created_By = 'ImportWorkFlow' ) )
	
	
        DELETE  FROM tbl_Exam_Measure_Data
        WHERE   Exam_Id IN ( SELECT exam_id
                             FROM   tbl_Exam
                             WHERE  Created_By = 'ImportWorkFlow' )

        DELETE  FROM tbl_Exam
        WHERE   Created_By = 'ImportWorkFlow'

    END


