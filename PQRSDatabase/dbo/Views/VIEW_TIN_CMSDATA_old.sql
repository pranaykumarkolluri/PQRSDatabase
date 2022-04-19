



CREATE VIEW [dbo].[VIEW_TIN_CMSDATA_old] AS

SELECT DISTINCT
A.CMS_Submission_Year AS 'CMSReportingYear'
,A.Exam_TIN AS TIN
, (SELECT TOP 1 M.CMSSubmissionDate  FROM tbl_CI_Measuredata_value M where M.Cmsyear=A.CMS_Submission_Year AND M.TIN=A.Exam_TIN AND (M.NPI IS NULL or M.NPI ='') AND M.CMSSubmissionDate IS NOT NULL)  
        AS  'CMS_Submission_Date'

from tbl_TIN_Aggregation_Year A



