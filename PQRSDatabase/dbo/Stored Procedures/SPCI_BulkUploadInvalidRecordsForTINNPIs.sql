-- =============================================
-- Author:		RAJU G
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Change#1: CMS Submission Status 08/31/2021
-- Change@2: JIRA#1074 Pavan 12/14/2021
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BulkUploadInvalidRecordsForTINNPIs]
	-- Add the parameters for the stored procedure here
 @FileId int,
 @CategoryId int
AS
BEGIN
	
	if( @CategoryId = 1 )
		BEGIN
		  select M.TIN,M.Npi,M.Measure_Name AS Measure_Number,
      M.NoofExamsSubmitted as Total_Exams_Submitted
      ,M.Total_no_of_exams_old as Total_Exam_Volume_Old
      ,M.Total_no_of_exams_new as Total_Exam_Volume_New
      ,M.HundredPercentSubmit_old as Submitted_Hundred_Percent_OLD
      ,CASE WHEN M.HundredPercentSubmit_new ='1' THEN 'Y'
	        WHEN M.HundredPercentSubmit_new='0' THEN  'N'
			ELSE m.HundredPercentSubmit_new END as Submitted_Hundred_Percent_NEW
      ,M.SelectedForCms_old as Selected_for_CMS_submission_OLD
      ,CASE WHEN M.[SelectedForCms_new] ='1' THEN 'Y'
	        WHEN M.SelectedForCms_new='0' THEN 'N'
			ELSE M.SelectedForCms_new END as Selected_for_CMS_submission_NEW
			 ,M.EndtoEndReporting_OLD
	  ,CASE WHEN M.EndtoEndReporting_new ='1' THEN 'Y'
			WHEN M.EndtoEndReporting_new='0' THEN 'N'
			ELSE  M.EndtoEndReporting_new END AS EndtoEndReporting_NEW
      ,M.[Performac_Rate] as Performance_rate
      
	  ,M.[Reporting_Rate] as Completeness
	  ,M.[Decile] as Decile,
	  --Change#1
	case when  exists(select 1 from tbl_CI_Measuredata_value md join
		tbl_CI_Source_UniqueKeys su on md.KeyId=su.Key_Id and su.Key_Id=sc.Key_Id  and  md.Measure_Name= case when LEN(M.Measure_Name)=2 then ('0'+M.Measure_Name) 
												        ELSE REPLACE(M.Measure_Name,' ','')
														END) then 'Submited to CMS' 
		ELSE 'Not Submited to CMS' end as CMS_Submission_Status					
	 
	  , Case When M.IsRowEditedByUser =1 then M.ErrorMessage  ELSE 'Row Not Yet Edited' END as ErrorMessage
 
			from tbl_CI_BulkFileUpload_History H 
			  INNER JOIN tbl_CI_BulkFileUploadCmsData M
			            on H.FileId=@FileId
						 and H.IsGpro=0
						 and H.FileId=M.FileId 

			LEFT JOIN tbl_CI_Source_UniqueKeys sc on M.TIN=sc.Tin     --Change#1                               --Change#8: Jira#719
				            AND sc.IsMSetIdActive=1
							AND sc.Npi = M.Npi
							AND sc.CmsYear=M.CmsYear                           
							AND sc.Category_Id=1
								where m.IsRowEditedByUser=1 and (  M.IsValidata=0 or M.IsValidata is null)	
	END
	ELSE
		BEGIN			-- Change@2:
		select A.CmsYear as Reporting_Year,
			A.TIN as TIN,
			A.Npi as NPI,
			A.Improvement_Activitiy as Improvement_Activitiy,
			A.First_Encounter_Date as First_Encouunter_Date,
			A.Last_Encounter_Date as Last_Encounter_Date,
			A.Attestation as Attested,
			A.ErrorMessage as ErrorMessage
		from tbl_CI_BulkFileUploadCmsDataforIA A where A.FileId = @FileId and A.ErrorMessage IS NOT NULL and (  A.IsValidata=0 or A.IsValidata is null)

		END
END

