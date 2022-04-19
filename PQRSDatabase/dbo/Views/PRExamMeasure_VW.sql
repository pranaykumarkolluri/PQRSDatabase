




CREATE VIEW [dbo].[PRExamMeasure_VW]
WITH SCHEMABINDING
AS
SELECT E.Exam_TIN,e.Physician_NPI,E.CMS_Submission_Year,md.Measure_ID,L.Measure_num, COUNT_BIG(*) AS MeasureCount FROM [dbo].tbl_Exam e  
        INNER JOIN [dbo].tbl_Exam_Measure_Data md  ON md.Exam_Id = e.Exam_Id
	   INNER JOIN [dbo].tbl_Lookup_Measure L ON L.Measure_ID=md.Measure_ID AND L.CMSYear=e.CMS_Submission_Year
	  -- JOIN [dbo].tbl_Users U on U.NPI=E.Physician_NPI
        WHERE  md.[Status]  IN (2,3)
	   GROUP BY E.Exam_TIN,e.Physician_NPI,E.CMS_Submission_Year,md.Measure_ID,L.Measure_num





