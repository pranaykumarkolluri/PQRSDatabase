




CREATE VIEW [dbo].[PRExamNumerator_VW]
WITH SCHEMABINDING
AS
SELECT     e.CMS_Submission_Year,e.Physician_NPI,e.Exam_TIN,e.Exam_Date,e.Patient_Age, md.Exam_Measure_Id, md.Measure_ID,N.Denominator_Exceptions,N.Exclusion,N.Performance_met
                                FROM    dbo.tbl_Exam e 
                                        INNER JOIN dbo.tbl_Exam_Measure_Data md
                                        ON md.Exam_Id = e.Exam_Id
                                        INNER JOIN dbo.tbl_lookup_Numerator_Code N
                                        ON N.Measure_ID = md.Measure_ID and N.Numerator_response_Value=md.Numerator_response_value
										and isnull(n.Criteria,'NA') = case when md.Criteria is null or md.Criteria ='' then 'NA' else md.Criteria end
                                WHERE   md.[Status] IN ( 2, 3 )






GO
CREATE UNIQUE CLUSTERED INDEX [CX_PRExamNumerator_VW]
    ON [dbo].[PRExamNumerator_VW]([CMS_Submission_Year] ASC, [Physician_NPI] ASC, [Exam_TIN] ASC, [Exam_Date] ASC, [Exam_Measure_Id] ASC, [Measure_ID] ASC, [Denominator_Exceptions] ASC, [Exclusion] ASC, [Performance_met] ASC);

