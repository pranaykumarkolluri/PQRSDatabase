



-- =============================================
-- Author:		Harikrishna J
-- Create date: March 2nd,2021
-- Description: PQRS-924: A view to show the total QM score for  TIN and TIN/NPI submission.  
-- =============================================

CREATE VIEW [dbo].[VIEW_CI_Report_ScoreQMSheet]
AS
     SELECT G.Exam_TIN,
            NULL AS 'Physician_NPI',
            G.CMS_Submission_Year,
            G.Measure_num AS 'QMMeasureNumber',
            CASE
                WHEN U.SelectedForSubmission = 1
                THEN 'selected'
                ELSE 'have not selected'
            END AS 'Measure Selection Status',
            CASE
                WHEN M.Measure_Name IS NOT NULL
                THEN 'submitted to CMS'
                ELSE 'have not submitted to CMS'
            END AS 'CMS Submission Status',
            I.Measure_Score AS 'Measurement Score Value',
            I.totalBonusPoints AS 'Total Bonus Point',
            I.measurementPicker AS 'Processing Status',
            I.feedback_quality AS 'Feeback-Quality',
            I.endToEndBonus AS 'End to End Bonus',
            I.outcomeOrPatientExperienceBonus AS 'Outcome or Patient Experience Bonus',
            I.highPriorityBonus AS 'High Priority Bonus',
            I.totaldecileScore AS 'Decile Score'
     FROM tbl_TIN_GPRO F
          INNER JOIN tbl_TIN_Aggregation_Year G ON G.Exam_TIN = F.TIN
                                                   AND F.is_GPRO = 1
			 --and (G.Measure_Num not like '%Q%' and G.Measure_Num not like '%acr%' )
          LEFT JOIN tbl_GPRO_TIN_Selected_Measures U ON U.Tin = G.Exam_TIN
                                                        AND U.Measure_num = G.Measure_Num
                                                        AND U.Submission_year = G.CMS_Submission_Year
          LEFT JOIN tbl_CI_Source_UniqueKeys SS ON SS.Tin = G.Exam_TIN
                                                   AND (SS.Npi IS NULL
                                                        OR SS.Npi = '')
                                                   AND SS.IsMSetIdActive = 1
                                                   AND SS.Category_Id = 1
                                                   AND SS.CmsYear = G.CMS_Submission_Year
          LEFT JOIN tbl_CI_Measuredata_value M ON SS.Key_Id = M.KeyId
                                                  AND M.Measure_Name = CASE
                                                                           WHEN LEN(G.Measure_num) = 1
                                                                           THEN '00'+G.Measure_num
                                                                           WHEN LEN(G.Measure_num) = 2
                                                                           THEN '0'+G.Measure_num
                                                                           ELSE REPLACE(G.Measure_num, ' ', '')
                                                                       END
          LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name = M.Measure_Name
                                                         AND I.Sub_ScoreId = SS.Score_ResponseId
                                                         AND i.Category_Id = sS.Category_Id
     UNION
     SELECT G.Exam_TIN,
            G.Physician_NPI,
            G.CMS_Submission_Year,
            G.Measure_Num AS 'QM Measure Number',
            CASE
                WHEN U.SelectedForSubmission = 1
                THEN 'selected'
                ELSE 'have not selected'
            END AS 'Measure Selection Status',
            CASE
                WHEN M.Measure_Name IS NOT NULL
                THEN 'submitted to CMS'
                ELSE 'have not submitted to CMS'
            END AS 'CMS Submission Status',
            I.Measure_Score AS 'Measurement Score Value',
            I.totalBonusPoints AS 'Total Bonus Point',
            I.measurementPicker AS 'Processing Status',
            I.feedback_quality AS 'Feeback-Quality',
            I.endToEndBonus AS 'End to End Bonus',
            I.outcomeOrPatientExperienceBonus AS 'Outcome or Patient Experience Bonus',
            I.highPriorityBonus AS 'High Priority Bonus',
            I.totaldecileScore AS 'Decile Score'
     FROM tbl_Physician_Aggregation_Year G
          INNER JOIN tbl_TIN_GPRO TG ON G.Exam_TIN = TG.TIN
                                        AND TG.is_GPRO = 0
                                   --AND (G.Measure_Num NOT LIKE '%Q%'
                                   --     AND G.Measure_Num NOT LIKE '%acr%')
          LEFT JOIN tbl_Physician_Selected_Measures U ON U.Tin = G.Exam_TIN
                                                         AND U.NPI = G.Physician_NPI
                                                         AND U.Measure_num_ID = G.Measure_Num
                                                         AND U.Submission_year = G.CMS_Submission_Year
          LEFT JOIN tbl_CI_Source_UniqueKeys SS ON SS.Tin = G.Exam_TIN
                                                   AND (SS.Npi IS NULL
                                                        OR SS.Npi = '')
                                                   AND SS.IsMSetIdActive = 1
                                                   AND SS.Category_Id = 1
                                                   AND SS.CmsYear = G.CMS_Submission_Year
          LEFT JOIN tbl_CI_Measuredata_value M ON SS.Key_Id = M.KeyId
                                                  AND M.Measure_Name = CASE
                                                                           WHEN LEN(G.Measure_Num) = 1
                                                                           THEN '00'+G.Measure_Num
                                                                           WHEN LEN(G.Measure_Num) = 2
                                                                           THEN '0'+G.Measure_Num
                                                                           ELSE REPLACE(G.Measure_num, ' ', '')
                                                                       END
          LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name = M.Measure_Name
                                                         AND I.Sub_ScoreId = SS.Score_ResponseId
                                                         AND i.Category_Id = sS.Category_Id;

