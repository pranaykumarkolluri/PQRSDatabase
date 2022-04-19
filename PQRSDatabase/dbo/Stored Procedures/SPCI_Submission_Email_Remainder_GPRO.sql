



-- =============================================
-- Author:		harikrishna j
-- Create date: 27th, Jan,2021
-- Description:	populate data for CI submission email remainder data for GPRO
--Chaange#1:getting GPRO tins only from tin aggrigation table
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_Submission_Email_Remainder_GPRO]
@Tin varchar(10)='',
@UserID varchar(50)=''
AS
         BEGIN
             DECLARE @CMSYear INT= 0;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
		   SET @Tin=ISNULL(@Tin,'');
		   SET @UserID=ISNULL(@UserID,'');
		SET  @UserID=CASE  @UserID WHEN '' THEN 'SheduleJob' ELSE @UserID END
	---STEP 1: Get Active and CMS Submission Year ----
             SELECT TOP 1 @CMSYear = Submission_Year
             FROM tbl_Lookup_Active_Submission_Year
             WHERE IsSubmittoCMS = 1
                   AND IsActive = 1;
   ---delete previous data from tbl_CI_Submission_Email_Remainder
             DELETE FROM tbl_CI_Submission_Email_Remainder
             WHERE CmsYear = @CMSYear
		   AND Tin = CASE  @Tin WHEN '' THEN Tin ELSE @Tin END
		   AND NPI IS NULL
		   ;
		   
    -- Step 2: populate MIPS submitted QM TINs and measures count data
             INSERT INTO [dbo].[tbl_CI_Submission_Email_Remainder]
([Tin],
 [QM_Measures_MIPS],
 [CmsYear],
 [CreatedDate],
 [CreatedBy]
)
                    SELECT Exam_TIN,
                           COUNT(DISTINCT Measure_Num) AS QM_Measures_MIPS,
                           @CMSYear,
                           GETDATE(),
                           @UserID
                    FROM [tbl_TIN_Aggregation_Year]
                    WHERE CMS_Submission_Year = @CMSYear
				 AND Exam_TIN = CASE  @Tin WHEN '' THEN Exam_TIN ELSE @Tin END
				AND GPRO=1--change#1
                    GROUP BY Exam_TIN;
				 -- Step 2.1: populate MIPS submitted Only IA TINs 
             INSERT INTO [dbo].[tbl_CI_Submission_Email_Remainder]
([Tin],
 [CmsYear],
 [CreatedDate],
 [CreatedBy]
)
                    SELECT TIN,@CMSYear,GETDATE(),@UserID
                    FROM tbl_IA_Users
                    WHERE CMSYear = @CMSYear
                          AND NPI IS NULL
					  AND Tin = CASE  @Tin WHEN '' THEN Tin ELSE @Tin END
                    EXCEPT
                    SELECT Tin,@CMSYear,GETDATE(),@UserID
                    FROM tbl_CI_Submission_Email_Remainder
                    WHERE CmsYear = @CMSYear
				 AND Tin = CASE  @Tin WHEN '' THEN Tin ELSE @Tin END
				 AND NPI IS NULL;
  --------------STEP 3:update the fields QM_Measures_CMS,QM_MeasuresData_CMS
             UPDATE E
               SET
                   E.QM_Measures_CMS =
(
    SELECT COUNT(M1.Measure_Name)
    FROM tbl_CI_Measuredata_value M1
    WHERE M1.KeyId = s.Key_Id
),
                   E.QM_MeasuresData_CMS = (STUFF(
(
    SELECT ', '+CAST(Measure_Name AS VARCHAR(10)) [text()]
    FROM tbl_CI_Measuredata_value M
    WHERE M.KeyId = s.Key_Id FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 2, ' '))
             FROM tbl_CI_Submission_Email_Remainder E
                  INNER JOIN tbl_CI_Source_UniqueKeys s ON E.Tin = s.Tin
                                                           AND E.CmsYear = s.CmsYear
                                                           AND s.IsMSetIdActive = 1
                                                           AND E.NPI IS NULL
                                                           AND s.Npi IS NULL
                                                           AND s.Category_Id = 1
											     AND E.Tin = CASE  @Tin WHEN '' THEN E.Tin ELSE @Tin END
             WHERE e.CmsYear = @CMSYear;
-------step 4: update QM_SixMeasures_CMS
             UPDATE tbl_CI_Submission_Email_Remainder
               SET
                   QM_SixMeasures_CMS = CASE
                                            WHEN QM_Measures_CMS > 5
                                            THEN 1
                                            ELSE NULL
                                        END
             WHERE CmsYear = @CMSYear
                   AND NPI IS NULL
                   AND QM_Measures_CMS IS NOT NULL
			     AND Tin = CASE  @Tin WHEN '' THEN Tin ELSE @Tin END;



---STEP 5: UPDATE IA MEASURES SUBMITTED TO MIPS
             UPDATE E
               SET
                   E.IA_Measures_MIPS = 1
             FROM tbl_CI_Submission_Email_Remainder E
                  INNER JOIN tbl_IA_Users I ON E.CmsYear = I.CMSYear
                                               AND E.CmsYear = @CMSYear
                                               AND E.Tin = I.TIN
                                               AND E.NPI IS NULL
                                               AND I.NPI IS NULL
									   AND E.Tin = CASE  @Tin WHEN '' THEN E.Tin ELSE @Tin END;
  ---STEP 6: UPDATE IA MEASURES SUBMITTED TO CMS
             UPDATE E
               SET
                   E.IA_Measures_CMS = 1
             FROM tbl_CI_Submission_Email_Remainder E
                  INNER JOIN tbl_CI_Source_UniqueKeys S ON E.CmsYear = S.CMSYear
                                                           AND E.CmsYear = @CMSYear
                                                           AND E.Tin = S.TIN
                                                           AND E.NPI IS NULL
                                                           AND S.NPI IS NULL
                                                           AND S.IsMSetIdActive = 1
                                                           AND S.Category_Id = 2
											    AND E.Tin = CASE  @Tin WHEN '' THEN E.Tin ELSE @Tin END;
  ---STEP 5: UPDATE PI MEASURES SUBMITTED TO MIPS
             UPDATE E
               SET
                   E.PI_Measures_MIPS = 1
             FROM tbl_CI_Submission_Email_Remainder E
                  INNER JOIN tbl_ACI_Users I ON E.CmsYear = I.CMSYear
                                                AND E.CmsYear = @CMSYear
                                                AND E.Tin = I.TIN
                                                AND E.NPI IS NULL
                                                AND I.NPI IS NULL
									   AND E.Tin = CASE  @Tin WHEN '' THEN E.Tin ELSE @Tin END;
   
  ---STEP 6: UPDATE PI MEASURES SUBMITTED TO CMS
             UPDATE E
               SET
                   E.PI_Measures_CMS = 1
             FROM tbl_CI_Submission_Email_Remainder E
                  INNER JOIN tbl_CI_Source_UniqueKeys S ON E.CmsYear = S.CMSYear
                                                           AND E.CmsYear = @CMSYear
                                                           AND E.Tin = S.TIN
                                                           AND E.NPI IS NULL
                                                           AND S.NPI IS NULL
                                                           AND S.IsMSetIdActive = 1
                                                           AND S.Category_Id = 3
											    AND E.Tin = CASE  @Tin WHEN '' THEN E.Tin ELSE @Tin END;
  --------------STEP 7: UPDATE EMAIL SUBJECT STATUS
             UPDATE tbl_CI_Submission_Email_Remainder
               SET
                   Email_SubjectStatus_Value = CASE
                                             WHEN(QM_SixMeasures_CMS = 1
                                                  AND IA_Measures_CMS = 1)
                                             THEN  ( select Email_SubjectStatus_Value from tbl_CI_lookup_Email_SubjectStatus where Email_SubjectStatus_Name= 'COMPLETE')
                                             WHEN(QM_Measures_CMS IS NOT NULL
                                                  AND QM_SixMeasures_CMS IS NULL
                                                  AND IA_Measures_CMS = 1)
                                             THEN ( select Email_SubjectStatus_Value from tbl_CI_lookup_Email_SubjectStatus where Email_SubjectStatus_Name= 'FEWERTHAN6')
                                             WHEN(QM_Measures_MIPS IS NULL
                                                  AND IA_Measures_MIPS IS NULL)
                                             THEN NULL
                                             ELSE ( select Email_SubjectStatus_Value from tbl_CI_lookup_Email_SubjectStatus where Email_SubjectStatus_Name= 'INCOMPLETE')
                                         END,
                   Email_NotificationRequired = 1
             WHERE CmsYear = @CMSYear
		   AND Tin = CASE  @Tin WHEN '' THEN Tin ELSE @Tin END
		   AND NPI IS NULL ;

             UPDATE tbl_CI_Submission_Email_Remainder
               SET
                   Email_NotificationRequired = 0
             WHERE Email_SubjectStatus_Value is null
                   AND CmsYear = @CMSYear
			    AND Tin = CASE  @Tin WHEN '' THEN Tin ELSE @Tin END
			    AND NPI IS NULL ;
         END;




