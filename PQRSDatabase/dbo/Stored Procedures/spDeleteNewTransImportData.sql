





-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 20-jul-2014
-- Description:	This stored proc is used to delete New Transaction data is was already processed
--              this can happen when same set is submitted accidently.
-- =============================================

CREATE PROCEDURE [dbo].[spDeleteNewTransImportData]
    @ImportID INT ,
    @Transactionid AS VARCHAR(100) ,
    @Appid AS VARCHAR(100) ,
    @PartnerID AS VARCHAR(100) ,
    @facilityID AS VARCHAR(100)
AS 
    BEGIN
        SET nocount ON ;
--#1 : delete from tbl_Exam_Measure_Data_Extension
        DELETE  FROM tbl_Exam_Measure_Data_Extension
        WHERE   Exam_Measure_Data_ID IN (
                SELECT  Exam_Measure_Id
                FROM    tbl_Exam_Measure_Data
                WHERE   Exam_Id IN ( SELECT exam_id
                                     FROM   tbl_Exam
                                     WHERE  Transaction_ID = @Transactionid
                                            AND PartnerID = @PartnerID
                                            AND AppID = @Appid ) )
	
--#2 : delete from tbl_Exam_Measure_Data	
        DELETE  FROM tbl_Exam_Measure_Data
        WHERE   Exam_Id IN ( SELECT exam_id
                             FROM   tbl_Exam
                             WHERE  Transaction_ID = @Transactionid
                                    AND PartnerID = @PartnerID
                                    AND AppID = @Appid )

--#3 : delete from tbl_Exam
        DELETE  FROM tbl_Exam
        WHERE   Transaction_ID = @Transactionid
                AND PartnerID = @PartnerID
                AND AppID = @Appid
		
		
--#3 : set status in tbl_Import_exams and tbl_import_Raw to 7 

		
		
		
        UPDATE  E
        SET     E.Import_Status = 7
        FROM    tbl_Import_Raw AS R
                INNER JOIN tbl_Import_Exams E ON R.ImportID = E.RawData_Id
        WHERE   E.Transaction_ID = @Transactionid
                AND E.PartnerID = @PartnerID
                AND E.AppID = @Appid
                AND r.ImportID < @ImportID
		
        DECLARE @intGoodExamsSet INT ;
        SET @intGoodExamsSet = 0 ;
		
        SELECT  @intGoodExamsSet = COUNT(ImportID)
        FROM    tbl_Import_Raw AS R
                INNER JOIN tbl_Import_Exams E ON R.ImportID = E.RawData_Id
        WHERE   E.Transaction_ID = @Transactionid
                AND E.PartnerID = @PartnerID
                AND E.AppID = @Appid
                AND r.ImportID < @ImportID
                AND e.Import_Status IN ( 1, 3, 4, 6 )  
		
        IF @intGoodExamsSet = 0 
            BEGIN
                UPDATE  R
                SET     R.[Status] = 7 ,
                        R.Data_Status = 7
                FROM    tbl_Import_Raw AS R
                        INNER JOIN tbl_Import_Exams E ON R.ImportID = E.RawData_Id
                WHERE   E.Transaction_ID = @Transactionid
                        AND E.PartnerID = @PartnerID
                        AND E.AppID = @Appid
                        AND r.ImportID < @ImportID
            END
		
		

    END






