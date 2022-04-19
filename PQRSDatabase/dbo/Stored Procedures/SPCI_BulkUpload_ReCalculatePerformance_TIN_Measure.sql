-- =============================================
-- Author:		Harikrishna J
-- Create date: Nov 28,2018
-- Description:	used to calculate performance of TIn and Measure of bulkupload tin-Measure data 
-- Change #1 By: Raju G
-- Change #1: if file contain whole Invalid records then no require peformance calculation
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BulkUpload_ReCalculatePerformance_TIN_Measure]
	-- Add the parameters for the stored procedure here
	@FileId int 
AS
BEGIN
	DECLARE @STATUS INT =0;
	DECLARE @RECORDS_COUNT INT=0;
	DECLARE @VALID_RECORDS_COUNT INT=0;

DECLARE @CmsDataId int, @TIN varchar(9),@Npi varchar(10),@Measure_Name varchar(50),@CmsYear int,
        
	   @Total_no_of_exams_new int,@HundredPercentSubmit_new bit,@SelectedForCms_new bit,
	@UserName varchar(50)

DECLARE @spResult int;
DECLARE @IsPeformancenotcalculateRecordsExists bit;
	 --curser CUR_TinMeasurePerformance startd--------------

 --Change #1

 select @STATUS=STATUS from tbl_CI_BulkFileUpload_History where  FileId=@FileId;
if EXISTS (select * from tbl_CI_BulkFileUpload_History where FileId=@FileId and Status IN (15,16))
BEGIN
print ('Valid Records Exits');
DECLARE CUR_TinMeasurePerformance CURSOR READ_ONLY FOR  
--
SELECT B.CmsDataId
       ,B.[TIN]    
      ,B.[Measure_Name]
      ,B.[CmsYear]    
  FROM [dbo].[tbl_CI_BulkFileUploadCmsData] B inner JOIN tbl_GPRO_TIN_Selected_Measures S 

  ON B.TIN=S.TIN
  where
  S.SelectedForSubmission=1
  AND ISNULL(Is_MeasureDataUpdated,'')=1
  AND B.IsValidata=1
  AND B.FileId=@FileId
   AND ISNULL(Npi,'')=''
  
OPEN CUR_TinMeasurePerformance 

FETCH NEXT FROM CUR_TinMeasurePerformance INTO @CmsDataId,@TIN,@Measure_Name,@CmsYear

WHILE @@FETCH_STATUS = 0   
BEGIN 


 --STEP#1---recalculate Performance for TIN and MEasure
 BEGIN TRY

BEGIN TRANSACTION
 PRINT ('spReCalculateTINperformanceRateForYearandMeasureID executed successfully with measure'+ISNULL(@Measure_Name,'')+', TIN :'+ISNULL(@TIN,'..'))

             EXEC @spResult = spReCalculateTINperformanceRateForYearandMeasureID @Measure_Name,@CmsYear,@TIN,0

						UPDATE [tbl_CI_BulkFileUploadCmsData] 
						 set Is_PerformanceCalculated=1
						 where CmsDataId=@CmsDataId
Commit Transaction
END TRY
BEGIN CATCH

ROLLBACK TRANSACTION 

END CATCH


 --STEP#2---update [[tbl_CI_BulkFileUploadCmsData]] table of performance status





FETCH NEXT FROM CUR_TinMeasurePerformance INTO @CmsDataId,@TIN,@Measure_Name,@CmsYear
END   
CLOSE CUR_TinMeasurePerformance   
DEALLOCATE CUR_TinMeasurePerformance

/*
SET @IsPeformancenotcalculateRecordsExists = CASE WHEN (SELECT TOP 1 COUNT(*) FROM  tbl_CI_BulkFileUploadCmsData WHERE FileId=@FileId ) >0 
		   THEN
				Case WHen (
				SELECT COUNT(*) 
				FROM tbl_CI_BulkFileUploadCmsData WHERE FileId=@FileId AND IsValidata=1  and IsRowEditedByUser=1 and (Is_PerformanceCalculated =0 OR Is_PerformanceCalculated IS NULL))=0 THEN 1 ELSE 0 END
		   ELSE NULL
		   END
		   */
		   SELECT @RECORDS_COUNT= COUNT(*) FROM tbl_CI_BulkFileUploadCmsData WHERE FileId=@FileId;
	
	   SELECT @VALID_RECORDS_COUNT= COUNT(*) FROM tbl_CI_BulkFileUploadCmsData WHERE FileId=@FileId AND Is_PerformanceCalculated=1;


		   

update A 
set
Status= CASE WHEN @VALID_RECORDS_COUNT=0 THEN 19 
              WHEN @VALID_RECORDS_COUNT >0 AND @VALID_RECORDS_COUNT <@RECORDS_COUNT THEN 18
			  WHEN @VALID_RECORDS_COUNT=@RECORDS_COUNT THEN 17 ELSE Status END
from 
tbl_CI_BulkFileUpload_History A 
where FileId=@FileId
END


END
