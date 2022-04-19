
-- =============================================
-- Author:		Hari j
-- Create date: <Create Date,,>
-- Description:	This is used to INSERT/UPDATE tbl_GPRO_TIN_Selected_Measures based on Backend Data

--exec SpBackend_NONGPROTIN_NPI_Measures 2017,427,'hariTINNPIbackend@gmail.com'
--change#1:hari j ,Mar 14th,2019
--change#1: remove the finalize functionality 
--Change#2: If the updating value is less than the value in db, we insert the greater value between them.
--Change#3: Hari J ,March 18th,2020- added HundredPercentSubmit column in TBL_SELECT_NON_GPRO_MEASURES_BACKEND and when HundredPercentSubmit=1 then TotalCasesReviewed should be null
-- =============================================
CREATE PROCEDURE [dbo].[SpBackend_NONGPROTIN_NPI_Measures] @CMSYear INT,
                                                          @UserID  INT
 --@AttestedEmailAddress varchar (50) --change#1:
AS
         BEGIN
             DECLARE @strCurTIN VARCHAR(10);
             DECLARE @strCurNPI VARCHAR(10);
             DECLARE @strCurMeasure_num VARCHAR(50);
             DECLARE @CurTotalCasesReviewed INT;
             DECLARE @ErrorCode AS INT;
             DECLARE @blnGPRO AS BIT;
             DECLARE @phyUserID AS INT;
             DECLARE @IsHundredPercentSubmit AS BIT; --Change#3
             BEGIN TRY
                 BEGIN TRANSACTION; 


   -----------------TIN Cursor STARTS------------------------------

                 DECLARE CurTINs CURSOR
                 FOR

    --STEP #1: Getting Required TIN 
                     SELECT DISTINCT
                            TIN
                     FROM TBL_SELECT_NON_GPRO_MEASURES_BACKEND WITH (NOLOCK);
                 OPEN CurTINs;
                 FETCH NEXT FROM CurTINs INTO @strCurTIN;
                 WHILE @@FETCH_STATUS = 0
                     BEGIN
                         PRINT 'TIN Cursor Started with  TIN: '+CAST(@strCurTIN AS VARCHAR(10));

    --STEP #1.1: FIND Whether TIN GPRO or Not?
                         SET @blnGPRO = 0;			
							--Check tin gpro status
                         EXEC sp_getTIN_GPRO
                              @strCurTIN;
                         SELECT TOP 1 @blnGPRO = is_GPRO
                         FROM tbl_TIN_GPRO
                         WHERE LTRIM(RTRIM(TIN)) = LTRIM(RTRIM(@strCurTIN));

----start 2018 Year logic------------ --change#1:
                         IF(@blnGPRO = 1)--Converting  GPRO to non GPRO
                             BEGIN
                                 EXEC spUpdate_GPROtoNonGPRO_ViceVersa
                                      @strCurTIN,
                                      0,
                                      @CMSYear,
                                      '',
                                      @ErrorCode = @ErrorCode OUTPUT;
                             END;
----end 2018 Year logic------------ --change#1:


                         PRINT 'CODE:N 102 TIN Cursor Ends with  TIN: '+CAST(@strCurTIN AS VARCHAR(10));
                         FETCH NEXT FROM CurTINs INTO @strCurTIN;
     -----------------TIN Cursor END------------------------------
                     END;
                 CLOSE CurTINs;
                 DEALLOCATE CurTINs;


	
-----------------TIN,NPI MEASURE Cursor STARTS------------------------------

                 SET @strCurTIN = '';
                 DECLARE CurTINs_CurNPIss_CurMeasures_CurExamCount CURSOR
                 FOR

    --STEP #5: Getting Required TIN ,NPI,MeasureNumber and TotalCasesReviewed count data
                     SELECT DISTINCT
                            TIN,
                            NPI,
                            [Measure_num],
                            [Total_exam_count],
                            HundredPercentSubmit
                     FROM TBL_SELECT_NON_GPRO_MEASURES_BACKEND WITH (NOLOCK)
                     WHERE(IsProcessDone = 0
                           OR IsProcessDone IS NULL);
                 OPEN CurTINs_CurNPIss_CurMeasures_CurExamCount;
                 FETCH NEXT FROM CurTINs_CurNPIss_CurMeasures_CurExamCount INTO @strCurTIN, @strCurNPI, @strCurMeasure_num, @CurTotalCasesReviewed, @IsHundredPercentSubmit;
                 WHILE @@FETCH_STATUS = 0
                     BEGIN
                         PRINT 'CODE:N 103 TIN-NPI-Measure Cursor Started with  TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' NPI: '+CAST(@strCurNPI AS VARCHAR(50))+' Measure_num: '+CAST(@strCurMeasure_num AS VARCHAR(50))+' and TotalCasesReviewed: '+CAST(@CurTotalCasesReviewed AS VARCHAR(50));
                         SET @blnGPRO = 0;
                         SELECT TOP 1 @blnGPRO = is_GPRO
                         FROM tbl_TIN_GPRO
                         WHERE LTRIM(RTRIM(TIN)) = LTRIM(RTRIM(@strCurTIN));
                         IF(@blnGPRO = 0)--For NON GPRO TIN


                             BEGIN
                                 PRINT 'CODE:N 104 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' is NON GPRO TIN'; 

	 
	 --STEP #6: INSERT/UPDATE tbl_GPRO_TIN_Selected_Measures


                                 IF NOT EXISTS
(
    SELECT 1
    FROM tbl_Physician_Selected_Measures
    WHERE TIN = @strCurTIN
          AND NPI = @strCurNPI
          AND Submission_year = @CMSYear
          AND Measure_num_ID = @strCurMeasure_num
)
                                     BEGIN
                                         PRINT 'CODE:N 106 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' NPI: '+CAST(@strCurNPI AS VARCHAR(10))+' Measure_num_ID: '+CAST(@strCurMeasure_num AS VARCHAR(10))+' are inserting into the tbl_Physician_Selected_Measures for CMS';
                                         SELECT @phyUserID = UserID
                                         FROM tbl_Users
                                         WHERE NPI = @strCurNPI;
                                         INSERT INTO [dbo].[tbl_Physician_Selected_Measures]
([NPI],
 [Physician_ID],
 [Measure_num_ID],
 [Submission_year],
 [TIN],
 [SelectedForSubmission],
 [TotalCasesReviewed],
 [HundredPercentSubmit],
 [DateLastSelected],
           --,[DateLastUnSelected] 
 [LastModifiedBy],
 [Is_Active],
 [Is_90Days]
)
                                         VALUES
(@strCurNPI, --<NPI, varchar(50),> 
 ISNULL(@phyUserID, 0), --<Physician_ID, int,> 
 @strCurMeasure_num, --<Measure_num_ID, varchar(50),> 
 @CMSYear, --<Submission_year, int,> 
 @strCurTIN, --<TIN, varchar(50),> 
 1, --<SelectedForSubmission, bit,> 
 CASE
     WHEN @IsHundredPercentSubmit = 1
     THEN NULL
     ELSE @CurTotalCasesReviewed
 END, --<TotalCasesReviewed, int,> 
 CASE
     WHEN @IsHundredPercentSubmit = 1
     THEN 1
     ELSE 0
 END, --<HundredPercentSubmit, bit,> 
 GETDATE(), --<DateLastSelected, datetime,>
           --,<DateLastUnSelected, datetime,> 
 CONVERT(VARCHAR(10), @UserID), --<LastModifiedBy, varchar(50),> 
 1, --<Is_Active, bit,> 
 0--<Is_90Days, bit,>
);
                                     END;
                                     ELSE
                                     BEGIN
                                         PRINT 'CODE:N 107 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' NPI: '+CAST(@strCurNPI AS VARCHAR(10))+' is updating into the tbl_Physician_Selected_Measures for CMS';
                                         UPDATE [dbo].[tbl_Physician_Selected_Measures]
                                           SET
                                               [SelectedForSubmission] = 1, --<SelectedForSubmission, bit,>
      --,[TotalCasesReviewed] = @CurTotalCasesReviewed--<TotalCasesReviewed, int,> 
                                               [TotalCasesReviewed] = CASE
                                                                          WHEN @IsHundredPercentSubmit = 1
                                                                          THEN NULL
                                                                          ELSE CASE
                                                                                   WHEN @CurTotalCasesReviewed >= ISNULL(TotalCasesReviewed, 0)
                                                                                   THEN @CurTotalCasesReviewed
                                                                                   ELSE TotalCasesReviewed
                                                                               END
                                                                      END, -- <TotalCasesReviewed, int,>   --Change#2 
                                               [HundredPercentSubmit] = CASE
                                                                            WHEN @IsHundredPercentSubmit = 1
                                                                            THEN 1
                                                                            ELSE 0
                                                                        END, --<HundredPercentSubmit, bit,> 
                                               [DateLastSelected] = GETDATE(), -- <DateLastSelected, datetime,> 
                                               [LastModifiedBy] = CONVERT(VARCHAR(10), @UserID), --<LastModifiedBy, varchar(50),> 
                                               [Is_Active] = 1, --<Is_Active, bit,> 
                                               [Is_90Days] = 0-- <Is_90Days, bit,>
                                         WHERE TIN = @strCurTIN
                                               AND NPI = @strCurNPI
                                               AND Submission_year = @CMSYear
                                               AND Measure_num_ID = @strCurMeasure_num;
                                     END;
 
  --STEP #7: INSERT TBL_AUDIT_SELECT_GPRO_MEASURES_BACKEND
                                 PRINT 'CODE:N 108 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' is inserting into the TBL_AUDIT_SELECT_NON_GPRO_MEASURES_BACKEND for Audit';
                                 INSERT INTO [TBL_AUDIT_SELECT_NON_GPRO_MEASURES_BACKEND]
([TIN],
 NPI,
 [Measure_num],
 [Created_datetime]
)
                                 VALUES
(@strCurTIN,
 @strCurNPI,
 @strCurMeasure_num,
 GETDATE()
);



	 --STEP #8: Update the [IsProcessDone]=1 for the table [TBL_SELECT_NON_GPRO_MEASURES_BACKEND] 
                                 UPDATE [dbo].[TBL_SELECT_NON_GPRO_MEASURES_BACKEND]
                                   SET
                                       [IsProcessDone] = 1-- <IsProcessDone, bit,>
                                 WHERE TIN = @strCurTIN
                                       AND NPI = @strCurNPI
                                       AND Measure_num = @strCurMeasure_num;
                             END--ENDs IF(@blnGPRO=1);
                             ELSE --For NON GPRO TIN


                             BEGIN
                                 PRINT 'CODE:N 110 TIN '+CAST(@strCurTIN AS VARCHAR(10))+' is   GPRO ';
                             END;
                         PRINT 'CODE:N 109 TIN-NPI-Measure Cursor Ends with  TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' Measure_num: '+CAST(@strCurMeasure_num AS VARCHAR(50))+' and TotalCasesReviewed: '+CAST(@CurTotalCasesReviewed AS VARCHAR(50));
                         FETCH NEXT FROM CurTINs_CurNPIss_CurMeasures_CurExamCount INTO @strCurTIN, @strCurNPI, @strCurMeasure_num, @CurTotalCasesReviewed, @IsHundredPercentSubmit;
                     END;
                 CLOSE CurTINs_CurNPIss_CurMeasures_CurExamCount;
                 DEALLOCATE CurTINs_CurNPIss_CurMeasures_CurExamCount;

    -----------------TIN,NPI,MEASURE Cursor Ends------------------------------




                 COMMIT TRANSACTION;
             END TRY
             BEGIN CATCH
                 IF @@TRANCOUNT > 0
                     ROLLBACK TRANSACTION;
                 DECLARE @ErrorNumber INT= ERROR_NUMBER();
                 DECLARE @ErrorLine INT= ERROR_LINE();
                 DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE();
                 DECLARE @ErrorSeverity INT= ERROR_SEVERITY();
                 DECLARE @ErrorState INT= ERROR_STATE();
                 PRINT 'Actual error number: '+CAST(@ErrorNumber AS VARCHAR(10));
                 PRINT 'Actual line number: '+CAST(@ErrorLine AS VARCHAR(10));
                 PRINT 'CODE:N 112 Error AT TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' NPI: '+CAST(@strCurNPI AS VARCHAR(10));
                 RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
             END CATCH;
         END;


