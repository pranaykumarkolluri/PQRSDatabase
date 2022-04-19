
-- =============================================
-- Author:		Hari
-- Create date: March 14,2018
-- Description:	 Get StartDate and End Date for xml Generation
-- Change#1:Description :For Getting Startdate and EndDate added new condition  is " SelectedForCMSSubmission=1"
-- Change#1:Created By: Raju G
-- Change#1:Date: 2/4/2019
-- =============================================
CREATE PROCEDURE [dbo].[spGetStartEndDateForTIN_TINNPIforXML]
@isTINonly bit=1,--1 for GPRO and 0 for NON GPRO
@Exam_TIN varchar(10),
@Physician_NPI varchar(25),
@CMS_Submission_Year int,
@is90days bit
AS
BEGIN
if(@isTINonly=1)
begin
select 
convert(char(10),MIN(a.Encounter_From_Date),126)+','+ CONVERT(char(10),MAX(a.Encounter_To_Date),126) as STARTENDDates 
from tbl_TIN_Aggregation_Year a join tbl_GPRO_TIN_Selected_Measures b on a.Exam_TIN=b.TIN where a.CMS_Submission_Year=@CMS_Submission_Year 
and a.Exam_TIN=@Exam_TIN 
and a.Is_90Days=@is90days
and b.SelectedForSubmission=1
and b.Submission_year=@CMS_Submission_Year
and a.Measure_Num=b.Measure_num


end
else
begin
select 
convert(char(10),MIN(p.Encounter_From_Date),126)+','+ CONVERT(char(10),MAX(p.Encounter_To_Date),126) as STARTENDDates
from tbl_Physician_Aggregation_Year p join  tbl_Physician_Selected_Measures s on 
p.Exam_TIN=s.TIN and p.Physician_NPI=s.NPI
where p.CMS_Submission_Year=@CMS_Submission_Year and p.Exam_TIN=@Exam_TIN 
and p.Physician_NPI=@Physician_NPI 
and p.Is_90Days=@is90days 
and s.SelectedForSubmission=1
and s.Submission_year=@CMS_Submission_Year
and p.Measure_Num=s.Measure_num_ID

end

END
