

-- =============================================
-- Author:		Harikrishna J
-- Create date: March 1th,2021
-- Description: PQRS-924: A view to show the total score for  TIN and TIN/NPI submission.  
-- =============================================

CREATE VIEW [dbo].[VIEW_CI_Report_ScoreSummarySheet]
AS
     SELECT DISTINCT
            A.Exam_TIN,
		   NULL as 'Physician_NPI',
            A.CMS_Submission_Year,
            CASE
                WHEN U.Submission_Uniquekey_Id IS NOT NULL
                THEN 'submitted to CMS'
                ELSE 'have not submitted to CMS'
            END AS 'CMS Submission Status',
            S.QM_Weight_Score AS 'QM Contribution to Final Score',
            S.QM_UnWeight_Score AS 'QM Unweighted Score',
            S.IA_Weight_Score AS 'IA Contribution to Final Score',
            S.IA_UnWeight_Score AS 'IA Unweighted Score',
            S.PI_Weight_Score AS 'PI Contribution to Final Score',
            S.PI_UnWeight_Score AS 'PI Unweighted Score',
            S.Total_Score
     FROM   tbl_TIN_Aggregation_Year A
     INNER JOIN tbl_TIN_GPRO G ON A.Exam_TIN = G.TIN 
                                   AND G.is_GPRO = 1 
          LEFT JOIN tbl_CI_Source_UniqueKeys U ON U.Tin = G.TIN 
                                                  AND U.IsMSetIdActive = 1
                                                  AND (U.Npi IS NULL
                                                       OR U.Npi = '')
											AND U.CmsYear=A.CMS_Submission_Year
          LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id = U.Submission_Uniquekey_Id
                                                 AND S.Sub_ScoreId = U.Score_ResponseId
	UNION 

	SELECT DISTINCT
       G.Exam_TIN,
       G.Physician_NPI,
       G.CMS_Submission_Year,
       CASE
           WHEN U.Submission_Uniquekey_Id IS NOT NULL
           THEN 'submitted to CMS'
           ELSE 'have not submitted to CMS'
       END AS 'CMS Submission Status',
       S.QM_Weight_Score AS 'QM Contribution to Final Score',
       S.QM_UnWeight_Score AS 'QM Unweighted Score',
       S.IA_Weight_Score AS 'IA Contribution to Final Score',
       S.IA_UnWeight_Score AS 'IA Unweighted Score',
       S.PI_Weight_Score AS 'PI Contribution to Final Score',
       S.PI_UnWeight_Score AS 'PI Unweighted Score',
       S.Total_Score
FROM tbl_Physician_Aggregation_Year G
     INNER JOIN tbl_TIN_GPRO TG ON G.Exam_TIN = TG.TIN 
                                   AND TG.is_GPRO = 0
     LEFT JOIN tbl_CI_Source_UniqueKeys U ON U.Tin = TG.TIN
                                             AND U.Npi = G.Physician_NPI 
                                             AND U.IsMSetIdActive = 1
                                             AND U.Npi <> ''  
									AND U.CmsYear=G.CMS_Submission_Year                                          
     LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id = U.Submission_Uniquekey_Id
                                            AND S.Sub_ScoreId = U.Score_ResponseId 

