-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BulkUpload_FileProcess_Details]
	-- Add the parameters for the stored procedure here
@UserId varchar(50),
@CmsYear int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.


	select  
  case  WHEN b.Status=11 then 'Received'
		
		    WHEN B.Status=7 AND b.IsPartallyCMSSumitted=1 THEN  'Partially Successful'
			 WHEN B.Status=7 THEN 'Complete'
		  WHEN B.Status=13 Or B.Status=20 THEN 'Failed'
		   WHEN B.Status=21 THEN 'UnEdited File'
		 WHEN B.Status = 24 THEN 'Action Required'
		 WHEN B.Status IS NOT NULL THEN 'Processing'
		 END  AS CmsStatusDetails,
	B.CreatedDate,
	C.Category_Name as CategoryName,
	B.FileName,
	B.InvalidExcelRecords,
	B.TotalEditedExcelRecordsCount,
	B.ValidExcelRecords,
	B.TotalExcelRecords,
	
	B.FileId,
	B.CmsYear,
	C.Category_Name,
	B.CompleteDate,
	CASE WHEN b.Status=11 then 'Received'
	     WHEN B.Status=7 AND b.IsPartallyCMSSumitted=1 THEN  'Partially Successful'
		 WHEN B.Status=7 THEN 'Successful'
		 WHEN B.Status=20 or B.Status=19 or B.Status=13 THEN 'CMS Submission Failed'
		 WHEN B.Status = 24 THEN 'File Pre-Validation Failed'
		 WHEN B.Status IS NOT NULL THEN 'Processing'
		 END AS  [Message]
     

	from tbl_CI_BulkFileUpload_History B
	
	inner join tbl_CI_lookup_Categories C on B.CategoryId=C.Category_Id 
	
		 where CreatedBy=@UserId and CmsYear =@CmsYear


--1	Processing	CMS BatchUpload Started
--2	MeasureDataProcessing	Selected measures data insert/update  into selected measures tables based on GPRO/NONGPRO
--3	MeasureDataCompleted	Selected measures data insert/update  into selected measures tables based on GPRO/NONGPRO
--4	PerformanceCalculationProcessing	Selected measures data  Performace Calculation and insert  into selected Aggregation tables based on GPRO/NONGPRO
--5	PerformanceCalculationCompleted	Selected measures data  Performace Calculation and insert  into selected Aggregation tables based on GPRO/NONGPRO
--6	BatchCMSSubmissionStarted	File related TIN/NPI measure data submitted to cms through api call
--7	BatchCMSSubmissionCompleted	File related TIN/NPI measure data submitted to cms through api call
--8	MeasureDataNotYetStarted	Initial State of measure data
--9	PerformanceCalculationNotYetStarted	Initial State of Performace Calculation of Batch Upload Data
--10	BatchCMSSubmissionNotYetStarted	Initial State of TIN/NPI data going to CMS Call
--11	ACR Staff wil process	NULL

END


