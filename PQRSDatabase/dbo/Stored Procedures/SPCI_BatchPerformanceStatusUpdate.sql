-- =============================================
-- Author:		Raju G
-- Create date: july 7,2019
-- Description:	Batch files data  performance calculation status  is updating in Batch tables.
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BatchPerformanceStatusUpdate]
@IsGpro bit,
@IsBatchCalculation bit,
@strCurTIN varchar(9),
@strCurNPI varchar(10),
@intCurActiveYear int,
@strMeasure_num varchar(50),
@Batch_MaxFileId int output
AS
BEGIN

IF OBJECT_ID('tempdb..#BatchSubmissionData') IS NOT NULL
DROP TABLE #BatchSubmissionData;
CREATE TABLE #BatchSubmissionData(TIN varchar(9),Npi varchar(10),Measure_Name varchar(50),CmsYear int,FileId int);
declare @RECORDS_COUNT int=0;
declare @VALID_RECORDS_COUNT int=0;


IF(@IsGpro=1)
BEGIN
     IF(@IsBatchCalculation=1)
								BEGIN
									
								delete from #BatchSubmissionData

							     insert into 
								 #BatchSubmissionData(TIN,Measure_Name,FileId)
								 select 
								 M.TIN,M.Measure_Name,M.FileId from 	
                                 tbl_CI_BulkFileUpload_History B
							     inner join
								 tbl_CI_BulkFileUploadCmsData M on B.fileId=M.fileId
								 inner join tbl_TIN_Aggregation_Year T on M.TIN = T.Exam_TIN and t.CMS_Submission_Year=@intCurActiveYear and M.Measure_Name= t.Measure_Num								 
								 where TIN=@strCurTIN  and Measure_Name=@strMeasure_num and B.CmsYear=@intCurActiveYear 								
								 group by M.TIN,M.Measure_Name,M.FileId

								 
								 	
							     Update 
								 M
								 set 
								  M.Is_PerformanceCalculated=1
								 from
                                 tbl_CI_BulkFileUpload_History B with(nolock)
							     inner join
								 tbl_CI_BulkFileUploadCmsData M with(nolock) on B.fileId=M.fileId and B.Status in(15,16)
								 inner join tbl_TIN_Aggregation_Year T  with(nolock)  on M.TIN = T.Exam_TIN and t.CMS_Submission_Year=@intCurActiveYear and M.Measure_Name= t.Measure_Num								 
								
								
							     Update 
								 M
								 set 
								  M.Is_PerformanceCalculated=1
								 from
                                 tbl_CI_BulkFileUpload_History B with(nolock)
							     inner join
								 tbl_CI_BulkFileUploadCmsData M with(nolock) on B.fileId=M.fileId and B.Status in(15,16)
								 inner join tbl_Physician_Aggregation_Year  P with(nolock) on
																				 M.TIN = P.Exam_TIN 
																				 and M.Npi=P.Physician_NPI
																				 and P.CMS_Submission_Year=@intCurActiveYear 
																				 and M.Measure_Name= P.Measure_Num								 
																
								
								 
								 Update M 
								 set M.Is_PerformanceCalculated=1
								 from tbl_CI_BulkFileUploadCmsData M inner join
								 #BatchSubmissionData B on 
													M.CmsYear=M.CmsYear 
													and B.TIN=M.TIN 
													and B.Measure_Name=M.Measure_Name
								Update H 
							    set H.Status=18  --Partially performace calculated
								from tbl_CI_BulkFileUpload_History H 
								where FileId in (select distinct fileId from  #BatchSubmissionData)

								


								END 
END
ELSE
BEGIN


	   --BatchFiles Start
                              if(@IsBatchCalculation=1)
								BEGIN
									
								delete from #BatchSubmissionData

							     insert into 
								 #BatchSubmissionData(TIN,Npi,Measure_Name,CmsYear,FileId)
								 select 
								 M.TIN,M.Npi,M.Measure_Name,M.CmsYear,M.FileId from 	
                                 tbl_CI_BulkFileUpload_History B
							     inner join
								 tbl_CI_BulkFileUploadCmsData M on B.fileId=M.fileId and B.Status in(15,16) and B.isGpro=0								 
								 where TIN=@strCurTIN and Npi=@strCurNPI and Measure_Name=@strMeasure_num and B.CmsYear=@intCurActiveYear 								
								 group by M.TIN,M.Npi,M.Measure_Name,M.CmsYear,M.FileId
								 
								 
								 Update M 
								 set M.Is_PerformanceCalculated=1
								 from tbl_CI_BulkFileUploadCmsData M inner join
								 #BatchSubmissionData B on 
													M.CmsYear=M.CmsYear 
													and B.TIN=M.TIN 
													and B.Npi=M.Npi 
													and B.Measure_Name=M.Measure_Name
								Update H 
							    set H.Status=18  --Partially performace calculated
								from tbl_CI_BulkFileUpload_History H 
								where FileId in (select distinct fileId from  #BatchSubmissionData)
								END
								END
						Select @Batch_MaxFileId= MAX(FileId) from #BatchSubmissionData		

END
