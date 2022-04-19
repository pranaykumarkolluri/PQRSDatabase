-- =============================================
-- Author:		Hari j
-- Create date: <Create Date,,>
-- Description:	This is used to INSERT/UPDATE tbl_GPRO_TIN_Selected_Measures based on Backend Data

--exec SpBackend_GPROTIN_Measures 2017,1,'haribackend@gmail.com'
--change#1:hari j ,Mar 14th,2019
--change#1: remove the finalize functionality 
--Change#2: If the updating value is less than the value in db, we insert the greater value between them.
--Change#3: Hari J ,March 18th,2020- added HundredPercentSubmit column in TBL_SELECT_GPRO_MEASURES_BACKEND and when HundredPercentSubmit=1 then TotalCasesReviewed should be null
-- =============================================
CREATE PROCEDURE [dbo].[SpBackend_GPROTIN_Measures] @CMSYear INT,
                                                   @UserID  INT
 --@AttestedEmailAddress varchar (50) --change#1:
AS
         BEGIN
             DECLARE @strCurTIN VARCHAR(10);
             DECLARE @strCurMeasure_num VARCHAR(50);
             DECLARE @CurTotalCasesReviewed INT;
             DECLARE @ErrorCode AS INT;
             DECLARE @blnGPRO AS BIT;
             DECLARE @IsHundredPercentSubmit AS BIT; --Change#3

   -----------------TIN Cursor STARTS------------------------------

             DECLARE CurTINs CURSOR
             FOR

    --STEP #1: Getting Required TIN 
                 SELECT DISTINCT
                        TIN
                 FROM TBL_SELECT_GPRO_MEASURES_BACKEND WITH (NOLOCK)
                 WHERE TIN NOT IN
(
    SELECT DISTINCT
           TIN
    FROM TBL_AUDIT_SELECT_GPRO_MEASURES_BACKEND
);
             OPEN CurTINs;
             FETCH NEXT FROM CurTINs INTO @strCurTIN;
             WHILE @@FETCH_STATUS = 0
                 BEGIN
                     PRINT 'TIN Cursor Started with  TIN: '+CAST(@strCurTIN AS VARCHAR(10));
                     BEGIN TRY
                         BEGIN TRANSACTION;
     --STEP #1.1: FIND Whether TIN GPRO or Not?
                         SET @blnGPRO = 0;			
							--Check tin gpro status
                         EXEC sp_getTIN_GPRO
                              @strCurTIN;
                         SELECT TOP 1 @blnGPRO = is_GPRO
                         FROM tbl_TIN_GPRO
                         WHERE LTRIM(RTRIM(TIN)) = LTRIM(RTRIM(@strCurTIN));

----START 2018 Year logic--------------change#1:
                         SET @ErrorCode = 4;
                         IF(@blnGPRO = 0)---Converting non GPRO to GPRO
                             BEGIN
                                 PRINT 'CODE:101 -TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' ';
                                 EXEC spUpdate_GPROtoNonGPRO_ViceVersa
                                      @strCurTIN,
                                      1,
                                      @CMSYear,
                                      '',
                                      @ErrorCode = @ErrorCode OUTPUT;
                             END;
----END 2018 Year logic------------



                         IF(@ErrorCode = 4)
                             BEGIN
                                 IF(@blnGPRO = 1)--For GPRO TIN
                                     BEGIN
                                         PRINT 'CODE:103 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' is GPRO TIN'; 
   
    

-----------------TIN,MEASURE Cursor STARTS------------------------------

                                         DECLARE CurTINs_CurMeasures_CurExamCount CURSOR
                                         FOR

    --STEP #5: Getting Required TIN ,MeasureNumber and TotalCasesReviewed count data
                                             SELECT DISTINCT
                                                    [Measure_num],
                                                    [Total_exam_count],
                                                    HundredPercentSubmit
                                             FROM TBL_SELECT_GPRO_MEASURES_BACKEND WITH (NOLOCK)
                                             WHERE TIN = @strCurTIN;
                                         OPEN CurTINs_CurMeasures_CurExamCount;
                                         FETCH NEXT FROM CurTINs_CurMeasures_CurExamCount INTO @strCurMeasure_num, @CurTotalCasesReviewed, @IsHundredPercentSubmit;
                                         WHILE @@FETCH_STATUS = 0
                                             BEGIN
                                                 PRINT 'CODE:106 TIN-Measure Cursor Started with  TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' Measure_num: '+CAST(@strCurMeasure_num AS VARCHAR(50))+' and TotalCasesReviewed: '+CAST(@CurTotalCasesReviewed AS VARCHAR(50));

	 --STEP #6: INSERT/UPDATE tbl_GPRO_TIN_Selected_Measures


                                                 IF NOT EXISTS
(
    SELECT 1
    FROM [tbl_GPRO_TIN_Selected_Measures]
    WHERE TIN = @strCurTIN
          AND Submission_year = @CMSYear
          AND Measure_num = @strCurMeasure_num
)
                                                     BEGIN
                                                         PRINT 'CODE:107 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' is inserting into the tbl_GPRO_TIN_Selected_Measures for CMS';
                                                         INSERT INTO [tbl_GPRO_TIN_Selected_Measures]
([Measure_num],
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
(@strCurMeasure_num,
 @CMSYear,
 @strCurTIN,
 1,
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
         --  ,<DateLastUnSelected, datetime,> 
 CONVERT(VARCHAR(10), @UserID), --<LastModifiedBy, varchar(50),> 
 1, --<Is_Active, bit,> 
 0--<Is_90Days, bit,>
);
                                                     END;
                                                     ELSE
                                                     BEGIN
                                                         PRINT 'CODE:108 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' is updating into the tbl_GPRO_TIN_Selected_Measures for CMS';
                                                         UPDATE [dbo].[tbl_GPRO_TIN_Selected_Measures]
                                                           SET
                                                               [SelectedForSubmission] = 1, --<SelectedForSubmission, bit,>
      --,[TotalCasesReviewed] = @CurTotalCasesReviewed-- <TotalCasesReviewed, int,> 
                                                               [TotalCasesReviewed] = CASE
                                                                                          WHEN @IsHundredPercentSubmit = 1
                                                                                          THEN NULL
                                                                                          ELSE CASE
                                                                                                   WHEN @CurTotalCasesReviewed >= ISNULL(TotalCasesReviewed, 0)
                                                                                                   THEN @CurTotalCasesReviewed
                                                                                                   ELSE TotalCasesReviewed
                                                                                               END
                                                                                      END, -- <TotalCasesReviewed, int,>   --Change#2: 
                                                               [HundredPercentSubmit] = CASE
                                                                                            WHEN @IsHundredPercentSubmit = 1
                                                                                            THEN 1
                                                                                            ELSE 0
                                                                                        END, --<HundredPercentSubmit, bit,> 
                                                               [DateLastSelected] = GETDATE(), --<DateLastSelected, datetime,>
     -- ,[DateLastUnSelected] = <DateLastUnSelected, datetime,> 
                                                               [LastModifiedBy] = CONVERT(VARCHAR(10), @UserID), -- <LastModifiedBy, varchar(50),> 
                                                               [Is_Active] = 1, --<Is_Active, bit,> 
                                                               [Is_90Days] = 0--<Is_90Days, bit,>
                                                         WHERE TIN = @strCurTIN
                                                               AND Submission_year = @CMSYear
                                                               AND Measure_num = @strCurMeasure_num;
                                                     END;
 
  --STEP #7: INSERT TBL_AUDIT_SELECT_GPRO_MEASURES_BACKEND
                                                 PRINT 'CODE:108 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' is inserting into the TBL_AUDIT_SELECT_GPRO_MEASURES_BACKEND for Audit';
                                                 INSERT INTO [TBL_AUDIT_SELECT_GPRO_MEASURES_BACKEND]
([TIN],
 [Measure_num],
 [Created_datetime]
)
                                                 VALUES
(@strCurTIN,
 @strCurMeasure_num,
 GETDATE()
);
                                                 PRINT 'CODE:109 TIN-Measure Cursor Ends with  TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' Measure_num: '+CAST(@strCurMeasure_num AS VARCHAR(50))+' and TotalCasesReviewed: '+CAST(@CurTotalCasesReviewed AS VARCHAR(50));
                                                 FETCH NEXT FROM CurTINs_CurMeasures_CurExamCount INTO @strCurMeasure_num, @CurTotalCasesReviewed, @IsHundredPercentSubmit;
                                             END;
                                         CLOSE CurTINs_CurMeasures_CurExamCount;
                                         DEALLOCATE CurTINs_CurMeasures_CurExamCount;

    -----------------TIN,MEASURE Cursor Ends------------------------------


                                     END--ENDs IF(@blnGPRO=1);
                                     ELSE --For NON GPRO TIN


                                     BEGIN
                                         PRINT 'CODE:110 TIN '+CAST(@strCurTIN AS VARCHAR(10))+' is  NON GPRO ';
                                     END;
                             END--GPRO Convertion  Ends IF(@ErrorCode=4);
                             ELSE
                             BEGIN
                                 PRINT 'CODE:111 Getting Error While Converting GPRO: TIN'+CAST(@strCurTIN AS VARCHAR(10))+' and GPRO Error Code'+CAST(@ErrorCode AS VARCHAR(10));
                             END;
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
                         PRINT 'CODE:112 Error AT TIN: '+CAST(@strCurTIN AS VARCHAR(10));
                         RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
                     END CATCH;
                     PRINT 'CODE:113 TIN Cursor Ends with  TIN: '+CAST(@strCurTIN AS VARCHAR(10));
                     FETCH NEXT FROM CurTINs INTO @strCurTIN;
     -----------------TIN Cursor END------------------------------
                 END;
             CLOSE CurTINs;
             DEALLOCATE CurTINs;
         END;


