



CREATE VIEW [dbo].[VIEW_TINNPT_CMSDATA_old]
AS
     SELECT DISTINCT
            A2.Exam_TIN,
            A2.Physician_NPI,
            A2.CMS_Submission_Year,
            CAST(0 as bit)  as GPRO,
(
    SELECT TOP 1 M.CMSSubmissionDate
    FROM tbl_CI_Measuredata_value M
    WHERE M.Cmsyear = A2.CMS_Submission_Year
          AND M.TIN = A2.Exam_TIN
          AND M.NPI = A2.Physician_NPI
          AND M.CMSSubmissionDate IS NOT NULL
) AS 'CMS_Submission_Date',
            SUBSTRING(
(
    SELECT DISTINCT
           '|'+A1.Measure_Num AS [text()]
    FROM dbo.tbl_Physician_Aggregation_Year A1
    WHERE A1.Exam_TIN = A2.Exam_TIN
          AND A1.Physician_NPI = A2.Physician_NPI
          AND A1.CMS_Submission_Year = A2.CMS_Submission_Year FOR XML PATH('')
), 2, 3000) [Measures]
     FROM dbo.tbl_Physician_Aggregation_Year A2
    -- ORDER BY A2.CMS_Submission_Year;



