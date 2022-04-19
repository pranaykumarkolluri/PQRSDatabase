



-- =============================================
-- Author:		Harikrishna J
-- Create date: March 2nd,2021
-- Description: PQRS-924: A view to show the total IA score for  TIN and TIN/NPI submission.  
-- =============================================

CREATE VIEW [dbo].[VIEW_CI_Report_ScoreIASheet]
AS
  SELECT DISTINCT
       A.Exam_TIN,
       NULL AS 'Physician_NPI',
       A.CMS_Submission_Year,
       S.SelectedActivity AS 'IA Measure Number',
       CASE
           WHEN M.Measure_Name IS NOT NULL
           THEN 'submitted to CMS'
           ELSE 'have not submitted to CMS'
       END AS 'CMS Submission Status',
       I.Contribution_Value AS 'Contribution Value',
       I.Measure_Weight AS 'Weight',
       I.Ia_Complete AS Complete
FROM tbl_TIN_Aggregation_Year A
     INNER JOIN tbl_TIN_GPRO T ON A.Exam_TIN = T.TIN
                                  AND T.is_GPRO = 1
     LEFT JOIN tbl_IA_Users G ON G.TIN = T.TIN
                                 AND G.CMSYear = A.CMS_Submission_Year
                                 AND ((G.CMSYear >= 2020
                                       AND G.IsGpro = 1)
                                      OR G.CMSYear < 2020)                      --Change1
     LEFT JOIN tbl_IA_User_Selected S ON S.SelectedID = G.SelectedID
                                         AND S.attest = 1
     LEFT JOIN tbl_CI_Source_UniqueKeys SS ON SS.Tin = G.TIN
                                              AND (SS.Npi = ''
                                                   OR SS.Npi IS NULL)
                                              AND SS.Category_Id = 2
                                              AND SS.IsMSetIdActive = 1
                                              AND SS.CmsYear = A.CMS_Submission_Year
     LEFT JOIN tbl_CI_Measuredata_value M ON SS.Key_Id = M.KeyId
                                             AND M.Measure_Name = S.SelectedActivity
     LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name = M.Measure_Name
                                                    AND I.Sub_ScoreId = SS.Score_ResponseId
                                                    AND I.Category_Id = SS.Category_Id
UNION
SELECT DISTINCT
       P.Exam_TIN,
       P.Physician_NPI,
       P.CMS_Submission_Year,
       S.SelectedActivity AS 'IA Measure Number',
       CASE
           WHEN M.Measure_Name IS NOT NULL
           THEN 'submitted to CMS'
           ELSE 'have not submitted to CMS'
       END AS 'CMS Submission Status',
       I.Contribution_Value AS 'Contribution Value',
       I.Measure_Weight AS 'Weight',
       I.Ia_Complete AS Complete
FROM tbl_Physician_Aggregation_Year P
     INNER JOIN tbl_TIN_GPRO TG ON P.Exam_TIN = TG.TIN
                                   AND TG.is_GPRO = 0
     LEFT JOIN tbl_IA_Users G ON G.TIN = P.Exam_TIN
                                 AND G.NPI = P.Physician_NPI
                                 AND G.CMSYear = P.CMS_Submission_Year
     LEFT JOIN tbl_IA_User_Selected S ON S.SelectedID = G.SelectedID
     LEFT JOIN tbl_CI_Source_UniqueKeys SS ON SS.Tin = G.TIN
                                              AND (SS.Npi = G.NPI)
                                              AND SS.Category_Id = 2
                                              AND SS.IsMSetIdActive = 1
                                              AND SS.CmsYear = P.CMS_Submission_Year
     LEFT JOIN tbl_CI_Measuredata_value M ON SS.Key_Id = M.KeyId
                                             AND M.Measure_Name = S.SelectedActivity
     LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name = M.Measure_Name
                                                    AND I.Sub_ScoreId = SS.Score_ResponseId
                                                    AND i.Category_Id = SS.Category_Id;



