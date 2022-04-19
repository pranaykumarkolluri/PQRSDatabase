
create view vw_Exam_Data
as

Select exam.Exam_Id [ExamId],
exam.Physician_NPI,
exam.Exam_TIN,
exam.Patient_ID,
exam.Patient_Age,
exam.Patient_Gender,
exam.Patient_Medicare_Beneficiary,
exam.Patient_Medicare_Advantage,
exam.Exam_Date,
exam.Created_Date [Exam_Created_Date],
exam.Created_By [Exam_Created_By],
exam.Last_Modified_Date [Exam_Last_Modified_Date],
exam.Last_Modified_By [Exam_Last_Modified_By],
exam.Facility_ID,
exam.Exam_Unique_ID,
exam.PartnerID,
exam.AppID,
exam.Transaction_ID,
exam.DataSource_Id,
exam.CMS_Submission_Year,
exam.IsEncrypt,
data.Exam_Measure_Id,
data.Measure_ID,
data.Denominator,
data.Denominator_proc_code,
data.Denominator_Diag_code,
data.Numerator_response_value,
data.Status,
data.CMS_Submission_Status,
data.Created_Date [Measure_Data_Created_Date],
data.Created_By [Measure_Data_Created_By],
data.Last_Mod_Date [Measure_Data_Last_Mod_Date],
data.Last_Mod_By [Measure_Data_Last_Mod_By],
data.CMS_Submission_Date,
data.Aggregation_Id,
data.Criteria
From tbl_Exam exam Join tbl_Exam_Measure_Data data On exam.Exam_Id = data.Exam_Id
Where exam.CMS_Submission_Year = 2018

