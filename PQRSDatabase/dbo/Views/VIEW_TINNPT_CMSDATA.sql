

	CREATE VIEW [dbo].[VIEW_TINNPT_CMSDATA]
AS
     SELECT DISTINCT
            A2.Exam_TIN,
            A2.Physician_NPI,
            A2.CMS_Submission_Year,
            CAST(0 as bit)  as GPRO,
(
    SELECT TOP 1 M.CMSSubmissionDate
    FROM tbl_CI_Source_UniqueKeys M
    WHERE M.Cmsyear = A2.CMS_Submission_Year
          AND M.TIN = A2.Exam_TIN
          AND M.NPI = A2.Physician_NPI
		  and m.IsMSetIdActive=1
          AND M.CMSSubmissionDate IS NOT NULL
) AS 'CMS_Submission_Date'
          
     FROM dbo.tbl_Physician_Aggregation_Year A2
    -- ORDER BY A2.CMS_Submission_Year;




