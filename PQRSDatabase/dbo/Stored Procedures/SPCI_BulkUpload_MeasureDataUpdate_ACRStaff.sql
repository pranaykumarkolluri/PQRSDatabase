
-- =============================================
-- Author:		Harikrishna Jubburu
-- Create date: Nov 28,2018
-- Description:	Used to update the bulkupload measure data into "tbl_Physician_Selected_Measures" or "tbl_GPRO_TIN_Selected_Measures"
                       --@IsGPORO=1 for update tbl_GPRO_TIN_Selected_Measures
                         --- @IsGPORO=0-- for update tbl_Physician_Selected_Measures
--Change #1 Description: EndtoEndReporting added . By Raju G
--Change #2 : JIRA#1012 By Sai, 16th Aug,2021 -- Adding performance Calculation SP's
-- =============================================
CREATE  PROCEDURE [dbo].[SPCI_BulkUpload_MeasureDataUpdate_ACRStaff]
	@IsGPORO bit ,
	@FileId int
	--@FacilityUserName varchar(50),
	--@CMS_Submission_Year int,
	--@isUserValidationRequired bit--user related validation required or not dicided based on this parameter

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @STATUS INT =0;
DECLARE @_CMSYEAR INT =0;
select @STATUS=STATUS,@_CMSYEAR=CmsYear from tbl_CI_BulkFileUpload_History where  FileId=@FileId

 
  DECLARE @NONQMES TABLE(MES VARCHAR(50));
INSERT INTO @NONQMES 
SELECT   right(Measure_num,len(Measure_num)-1) FROM tbl_Lookup_Measure WHERE Measure_num LIKE '%Q%' AND CMSYear=@_CMSYEAR
BEGIN



--update tbl_CI_BulkFileUpload_History set IsProcessing=1 where FileId=@FileId 
DECLARE @CmsDataId int, @TIN varchar(9),@Npi varchar(10),@Measure_Name varchar(50),@CmsYear int,
        
	   @Total_no_of_exams_new int,@HundredPercentSubmit_new bit,@SelectedForCms_new bit,
	@UserName varchar(50),@EndtoEndReporting_new bit;

	--Step#: fetch the username for TIN or TIN/NPI validation
	DECLARE @FacilityUserName varchar(50);
  SELECT DISTINCT @FacilityUserName=Createdby from [tbl_CI_BulkFileUploadCmsData] where FileId=@FileId 

---STEP # Remove unwanted spaces of user edited rows

IF(@STATUS=11)
BEGIN
      UPDATE [tbl_CI_BulkFileUploadCmsData]
  
   SET 
    SelectedForCms_new =RTRIM(LTRIM(SelectedForCms_new)),
    HundredPercentSubmit_new =RTRIM(LTRIM(HundredPercentSubmit_new)),
    Total_no_of_exams_new =RTRIM(LTRIM(Total_no_of_exams_new))

     WHERE FileId=@FileId AND (ISNULL(Total_no_of_exams_new,'')<>''
  OR ISNULL(HundredPercentSubmit_new,'')<>''
  OR ISNULL(SelectedForCms_new,'')<>'')



  --Step#: Get editable rows from particular file
   UPDATE [tbl_CI_BulkFileUploadCmsData]
  
   SET  [IsRowEditedByUser] =CASE 
	                           WHEN (ISNULL(SelectedForCms_new,'')<>'' ) then 1
						   WHEN (ISNULL(HundredPercentSubmit_new,'')<>'' ) then 1
                                  WHEN (ISNULL(Total_no_of_exams_new,'')<>'' ) then 1
								  WHEN (ISNULL(EndtoEndReporting_new,'')<>'' ) then 1
						   ELSE 0
					
						   END 
   WHERE FileId=@FileId

      if not exists(select 1 from [tbl_CI_BulkFileUploadCmsData] where IsRowEditedByUser=1 and FileId=@FileId)
   begin
         update tbl_CI_BulkFileUpload_History 
		 set 
		 Status=21 --uneditied file
		 where FileId=@FileId
   end 
     --Step#: change value as boolean of editable row

	   UPDATE [tbl_CI_BulkFileUploadCmsData]
  
   SET  SelectedForCms_new =CASE 
	                           WHEN (UPPER(SelectedForCms_new) ='YES') OR
						       (UPPER(SelectedForCms_new) ='Y') OR
							  (SelectedForCms_new ='1')  THEN '1'
						WHEN	  (UPPER(SelectedForCms_new) ='NO') OR
							  (UPPER(SelectedForCms_new) ='N') OR
						       (SelectedForCms_new ='0') then '0'
						  
						   ELSE '0'				
						   END ,
   HundredPercentSubmit_new =CASE 
	                           WHEN (UPPER(HundredPercentSubmit_new) ='YES') OR
						       (UPPER(HundredPercentSubmit_new) ='Y') OR
							  (HundredPercentSubmit_new ='1')  THEN '1'
						WHEN	  (UPPER(HundredPercentSubmit_new) ='NO') OR
							  (UPPER(HundredPercentSubmit_new) ='N') OR
						       (HundredPercentSubmit_new ='0') then '0'
						  
						   ELSE '0'			
				   END ,
   EndtoEndReporting_new =Case WHEN  (UPPER(EndtoEndReporting_new)='YES') OR
								 (UPPER(EndtoEndReporting_new)='Y') OR
								 (UPPER(EndtoEndReporting_new)='1') then '1'
								 WHEN  (UPPER(EndtoEndReporting_new)='NO') OR
								 (UPPER(EndtoEndReporting_new)='N') OR
								 (UPPER(EndtoEndReporting_new)='0') then '0' 
								 ELSE '0'
								 END
--,
--Total_no_of_exams_new =CASE 
--	                           WHEN (UPPER(SelectedForCms_new) ='YES') OR
--						       (UPPER(SelectedForCms_new) ='Y') OR
--							  (SelectedForCms_new ='1')  THEN '1'
--						WHEN	  (UPPER(SelectedForCms_new) ='NO') OR
--							  (UPPER(SelectedForCms_new) ='N') OR
--						       (SelectedForCms_new ='0') then '0'
						  
--						   ELSE SelectedForCms_new				
--						   END 
   WHERE FileId=@FileId and [IsRowEditedByUser]=1


   --Step#: CHECk editable rows are vaild or not
   /*
	   UPDATE M
  
  
        SET  M.ErrorMessage =CASE 
							WHEN (((M.Total_no_of_exams_new IS NULL OR M.Total_no_of_exams_new='') 
							AND (M.HundredPercentSubmit_new IS NULL OR M.HundredPercentSubmit_new='')) 
							OR (( ISNULL(TRY_PARSE(M.Total_no_of_exams_new AS INT),0)>0 
							AND ( M.HundredPercentSubmit_new='1')) 
							AND ISNULL(CONVERT(BIT,M.HundredPercentSubmit_new),0)=1 ) )
							THEN 'Please Enter the value Either Total_no_of_exams_new or HundredPercentSubmit_new' 
				  			WHEN  M.Total_no_of_exams_new IS NOT NULL AND M.Total_no_of_exams_new <> '' 
							AND (isnull(TRY_PARSE(M.Total_no_of_exams_new as int),0) >0) 
							and (isnull(TRY_PARSE(M.Total_no_of_exams_new as int),0) < isnull(TRY_PARSE(M.NoofExamsSubmitted as int),0))  
							THEN 'Cases reviewed value ('+CONVERT(varchar(50), isnull(m.Total_no_of_exams_new,''))+') for measure number # :'+isnull(M.Measure_Name,'')+' cannot be less than submitted exams ('+CONVERT(varchar(50), isnull(m.NoofExamsSubmitted,''))+') in application for the year '
							When isnull(TRY_PARSE(M.Total_no_of_exams_new as int),0) =0 and  M.HundredPercentSubmit_new <>'1' 
							then  'Please Enter the value Either Total_no_of_exams_new or HundredPercentSubmit_new'

							WHEN M.HundredPercentSubmit_new  <> '1' AND isnull(TRY_PARSE(M.Total_no_of_exams_new as int),0) =0 THEN 'Please Enter the value Either Total_no_of_exams_new or HundredPercentSubmit_new' 
							WHEN    M.HundredPercentSubmit_new <> '0' AND M.HundredPercentSubmit_new <> '1' THEN 'Invalid Entry in HundredPercentSubmit_new Field'
							WHEN   M.SelectedForCms_new <> '0' AND M.SelectedForCms_new <> '1' THEN 'Invalid Entry in SelectedForCms_new Field'
							WHEN   M.EndtoEndReporting_new <> '0' AND M.EndtoEndReporting_new <> '1' THEN 'Invalid Entry in EndtoEndReporting_new'
							WHEN  M.Total_no_of_exams_new <> '' and  M.Total_no_of_exams_new is not null and ISNUMERIC(M.Total_no_of_exams_new) <> 1 then 'Invalid Entry at Total_no_of_exams_new.' 
							WHEN ((B.IsGpro=1)AND ((SELECT COUNT(*) FROM tbl_TIN_Aggregation_Year t where 
													 t.Exam_TIN=M.TIN AND t.CMS_Submission_Year=B.CmsYear and t.Measure_Num=LTRIM(RTRIM(M.Measure_Name)) ) < 1) ) THEN 'Invalid TIN,YEAR,CMS Year Combination in NRDR Database'
							WHEN ((B.IsGpro=0)AND ((SELECT COUNT(*) FROM tbl_Physician_Aggregation_Year t where 
													 t.Exam_TIN=M.TIN AND t.Physician_NPI=M.Npi and t.CMS_Submission_Year=B.CmsYear and t.Measure_Num=LTRIM(RTRIM(M.Measure_Name)) ) < 1) ) THEN 'Invalid TIN,YEAR,CMS Year Combination in NRDR Database'
							ELSE null
				   END 
      from [tbl_CI_BulkFileUploadCmsData] M inner join 
	       tbl_CI_BulkFileUpload_History B on  M.FileId=@FileId and M.FileId=B.FileId and M.IsRowEditedByUser=1
   */

    UPDATE M
  
  
        SET  M.ErrorMessage =CASE 
							--WHEN (((M.Total_no_of_exams_new IS NULL OR M.Total_no_of_exams_new='') 
							--AND (M.HundredPercentSubmit_new IS NULL OR M.HundredPercentSubmit_new='')) and M.SelectedForCms_new is null and M.EndtoEndReporting_new is null)
							--then 'Please Enter the value Either Total_no_of_exams_new or HundredPercentSubmit_new or SelectedForCms_new or EndtoEndReporting_new' 
							when (( ISNULL(TRY_PARSE(M.Total_no_of_exams_new AS INT),0)>0 
							AND ( M.HundredPercentSubmit_new='1')) 
							AND ISNULL(CONVERT(BIT,M.HundredPercentSubmit_new),0)=1 ) 
							
							THEN 'Please Enter the value Either Total_no_of_exams_new or HundredPercentSubmit_new' 
				  			WHEN  M.Total_no_of_exams_new IS NOT NULL AND M.Total_no_of_exams_new <> '' 
							AND (isnull(TRY_PARSE(M.Total_no_of_exams_new as int),0) >0) 
							and (isnull(TRY_PARSE(M.Total_no_of_exams_new as int),0) < isnull(TRY_PARSE(M.NoofExamsSubmitted as int),0))  
							THEN 'Cases reviewed value ('+CONVERT(varchar(50), isnull(m.Total_no_of_exams_new,''))+') for measure number # :'+isnull(M.Measure_Name,'')+' cannot be less than submitted exams ('+CONVERT(varchar(50), isnull(m.NoofExamsSubmitted,''))+') in application for the year '
							When isnull(TRY_PARSE(M.Total_no_of_exams_new as int),0) =0 and  M.HundredPercentSubmit_new <>'1'  and (m.SelectedForCms_new is  null and m.EndtoEndReporting_new is   null)
							then  'Please Enter the value Either Total_no_of_exams_new or HundredPercentSubmit_new'

							WHEN M.HundredPercentSubmit_new  <> '1' AND isnull(TRY_PARSE(M.Total_no_of_exams_new as int),0) =0 and (m.SelectedForCms_new is  null and m.EndtoEndReporting_new is   null)
								THEN 'Please Enter the value Either Total_no_of_exams_new or HundredPercentSubmit_new' 
							WHEN    M.HundredPercentSubmit_new <> '0' AND M.HundredPercentSubmit_new <> '1' and  M.HundredPercentSubmit_new is not null THEN 'Invalid Entry in HundredPercentSubmit_new Field'
							WHEN   M.SelectedForCms_new <> '0' AND M.SelectedForCms_new <> '1' and M.SelectedForCms_new is not null THEN 'Invalid Entry in SelectedForCms_new Field'
							WHEN   M.EndtoEndReporting_new <> '0' AND M.EndtoEndReporting_new <> '1' and M.EndtoEndReporting_new is not  null THEN 'Invalid Entry in EndtoEndReporting_new'
							WHEN  M.Total_no_of_exams_new <> '' and  M.Total_no_of_exams_new is not null and ISNUMERIC(M.Total_no_of_exams_new) <> 1 then 'Invalid Entry at Total_no_of_exams_new' 
							--when isnull(TRY_PARSE(M.Total_no_of_exams_new as int),0) >0 and m.HundredPercentSubmit_new is null and m.HundredPercentSubmit_new='1' 
							--THEN 'Please Enter the value Either Total_no_of_exams_new or HundredPercentSubmit_new'
							WHEN ((B.IsGpro=1)AND ((SELECT COUNT(*) FROM tbl_TIN_Aggregation_Year t where 
													 t.Exam_TIN=M.TIN AND t.CMS_Submission_Year=B.CmsYear and t.Measure_Num=LTRIM(RTRIM(M.Measure_Name)) ) < 1) ) THEN 'Invalid TIN,YEAR,CMS Year Combination in NRDR Database'
							WHEN ((B.IsGpro=0)AND ((SELECT COUNT(*) FROM tbl_Physician_Aggregation_Year t where 
													 t.Exam_TIN=M.TIN AND t.Physician_NPI=M.Npi and t.CMS_Submission_Year=B.CmsYear and t.Measure_Num=LTRIM(RTRIM(M.Measure_Name)) ) < 1) ) THEN 'Invalid TIN,YEAR,CMS Year Combination in NRDR Database'
							ELSE null
				   END 

		

      from [tbl_CI_BulkFileUploadCmsData] M inner join 
	       tbl_CI_BulkFileUpload_History B on  M.FileId=@FileId and M.FileId=B.FileId and M.IsRowEditedByUser=1
 --  WHERE FileId=@FileId  and [IsRowEditedByUser]=1  


   
   --Step#:update invalid boolean value

	   UPDATE [tbl_CI_BulkFileUploadCmsData]
  
   SET  IsValidata = CASE WHEN  ISNULL(ErrorMessage,'') ='' THEN 1
                      ELSE 0
				  END

   WHERE FileId=@FileId 
   and [IsRowEditedByUser]=1 


  
   
      --STEP: need to do TIN or TIN/NPI is matching to the user or not (need to maintain boolean wheather this validation required or not?)
   ----start---
   
   --STEP#: get user Related TINS
declare @tbl_Tins table(

Tin varchar(9),
IS_GPRO bit
);
INSERT INTO @tbl_Tins
select distinct  Tin=C.TIN ,is_GPRO=T.is_GPRO from  tbl_CI_BulkFileUploadCmsData

 C Inner join tbl_TIN_GPRO T on C.FileId=@FileId and C.TIN=T.TIN 



  UPDATE F
  
   SET  F.ErrorMessage = 'TIN is not authorized for this User ['+@FacilityUserName+']'  
   from
   [tbl_CI_BulkFileUploadCmsData] F left join @tbl_Tins T on F.TIN=T.Tin
    WHERE F.FileId=@FileId 
   and F.[IsRowEditedByUser]=1 
   and F.IsValidata=1
   and T.Tin is null
   --and TIN not in(select DISTINCT A.Tin from @tbl_Tins A inner join tbl_CI_BulkFileUploadCmsData B on B.FileId=@FileId and A.Tin=B.TIN)



IF(@IsGPORO=0)--check tin and npi validation
BEGIN

  --STEP#Check entered TIN/TIN_NPI are user related
  
  --TODO: need to write curser
  DECLARE @CUR_TIN varchar(9);
DECLARE @CUR_NPI varchar(11);
--curser CUR_BulkCmsData startd

DECLARE CUR_BulkCmsData CURSOR READ_ONLY FOR  
--
SELECT DISTINCT TIN,Npi from tbl_CI_BulkFileUploadCmsData 
   WHERE FileId=@FileId 
   and [IsRowEditedByUser]=1
   and ISNULL(IsValidata,0)=0  

OPEN CUR_BulkCmsData   

FETCH NEXT FROM CUR_BulkCmsData INTO @CUR_TIN,@CUR_NPI

WHILE @@FETCH_STATUS = 0   
BEGIN 
PRINT ('inside curser with USERNAME :')
--PRINT ('inside curser with USERNAME :'+ISNULL(@CUR_UserName,'..'))

IF NOT EXISTS(Select * from NRDR..PHYSICIAN_TIN_VW where TIN=@CUR_TIN and NPI=@CUR_NPI)
BEGIN

  UPDATE [tbl_CI_BulkFileUploadCmsData]
  
   SET  ErrorMessage = 'TIN/NPI is not authorized for this User ['+@FacilityUserName+']'  ,
        IsValidata=0
   WHERE FileId=@FileId 
   and [IsRowEditedByUser]=1 
   and IsValidata=1
  and TIN=@CUR_TIN
  and Npi=@CUR_NPI
END


FETCH NEXT FROM CUR_BulkCmsData INTO @CUR_TIN,@CUR_NPI
END   
CLOSE CUR_BulkCmsData   
DEALLOCATE CUR_BulkCmsData


--curser CUR_BulkCmsData Ended
END
--Qmeasure Validation  start
 DECLARE @CUR_MEASURE varchar(9);
DECLARE @CUR_SELECTCMS varchar(5);
DECLARE @CUR_CMSYEAR INT;
DECLARE @CUR_QMEASURE VARCHAR(5);
;DECLARE QMEASURE_cUR CURSOR READ_ONLY FOR  


SELECT  TIN,Npi,Measure_Name,SelectedForCms_new

 FROM
			tbl_CI_BulkFileUploadCmsData B WHERE B.FileId=@FileId
												AND B.CmsYear=@_CMSYEAR
											   	 AND b.Measure_Name LIKE '%Q%'	
												 AND B.SelectedForCms_new='1'
												 and B.IsRowEditedByUser=1
												 AND B.IsValidata=1
												 

OPEN QMEASURE_cUR   
										 
FETCH NEXT FROM QMEASURE_cUR INTO @CUR_TIN,@CUR_NPI,@CUR_MEASURE,@CUR_SELECTCMS

WHILE @@FETCH_STATUS = 0   
BEGIN 

--for Gpro


print('Q cursor');
							 SET @CUR_QMEASURE=	CASE when UPPER(SUBSTRING(@CUR_MEASURE,1,1))='Q' Then right(@CUR_MEASURE,len(@CUR_MEASURE)-1) ELSE @CUR_MEASURE End 
					
							  IF EXISTS(SELECT 1 FROM tbl_CI_BulkFileUploadCmsData WHERE     
																													Cmsyear=@_CMSYEAR
																												    AND TIN=@CUR_TIN 
																											        AND isnull(Npi,'')=  isnull(@CUR_NPI,'')
																													AND Measure_Name =@CUR_QMEASURE
																													AND SelectedForCms_new='1'
																													and IsRowEditedByUser=1
																													AND IsValidata=1
																													AND FileId=@FileId)
							BEGIN
						print('Q cursor error');
							       UPDATE  tbl_CI_BulkFileUploadCmsData 
								   SET IsValidata=0,
								    ErrorMessage='ENTER  either the '+@CUR_QMEASURE+' or '+@CUR_MEASURE+' measure; you may not select both'
									WHERE     
																													Cmsyear=@_CMSYEAR
																												    AND TIN=@CUR_TIN 
																											        AND isnull(Npi,'')=  isnull(@CUR_NPI,'')
																													AND Measure_Name in (@CUR_QMEASURE, @CUR_MEASURE) 
																													AND SelectedForCms_new='1'
																													AND IsValidata=1
								                                                                                    and IsRowEditedByUser=1
								                                                                                    AND FileId=@FileId

							 END


FETCH NEXT FROM QMEASURE_cUR INTO @CUR_TIN,@CUR_NPI,@CUR_MEASURE,@CUR_SELECTCMS
END
CLOSE QMEASURE_cUR   
DEALLOCATE QMEASURE_cUR
--Qmeasure validation end.
 DECLARE @RECORDS_COUNT INT;
 DECLARE @VALIDRECORDS_COUNT INT=0;

  SELECT @RECORDS_COUNT=COUNT(*) FROM tbl_CI_BulkFileUploadCmsData WHERE FileId=@FileId
  SELECT @VALIDRECORDS_COUNT=COUNT(*) FROM tbl_CI_BulkFileUploadCmsData WHERE FileId=@FileId AND IsValidata=1;


  /*
  12	ValidationSuccessful
13	ValidationFailed
14	PartiallySuccessful
  */
  UPDATE tbl_CI_BulkFileUpload_History
  
  SET Status = CASE WHEN @VALIDRECORDS_COUNT=0 THEN 13
					WHEN @VALIDRECORDS_COUNT=@RECORDS_COUNT THEN 12
					WHEN @VALIDRECORDS_COUNT>0 AND @VALIDRECORDS_COUNT <@RECORDS_COUNT  THEN 14
					ELSE Status
					END,
 IsPartiallyValidation = CASE WHEN @VALIDRECORDS_COUNT>0 AND @VALIDRECORDS_COUNT <@RECORDS_COUNT  THEN 1
					ELSE 0  END
   WHERE FileId=@FileId and Status !=21

END  
   ---end----- 
  



  --STEP#1---Check user request 


  
IF(@IsGPORO=1 AND EXISTS(SELECT 1 FROM tbl_CI_BulkFileUpload_History WHERE Status IN (12,14) AND FileId=@FileId))
BEGIN

  UPDATE G
   SET 
      G.[SelectedForSubmission] = CASE 
	                           WHEN ISNULL(c.SelectedForCms_new,'')<>'' THEN c.SelectedForCms_new
						   ELSE [SelectedForSubmission] 
						   END
      ,G.[TotalCasesReviewed] = CASE 
								WHEN ISNULL(TRY_PARSE(C.Total_no_of_exams_new as int),0) =0 AND C.HundredPercentSubmit_new ='1' THEN 0
	                           WHEN ISNULL(c.Total_no_of_exams_new,'')<>'' THEN c.Total_no_of_exams_new
						   ELSE [TotalCasesReviewed]
						   END
      ,G.[HundredPercentSubmit] = CASE 
								WHEN ISNULL(TRY_PARSE(C.Total_no_of_exams_new as int),0) >0 AND C.HundredPercentSubmit_new IS NULL THEN 0
	                           WHEN ISNULL(c.HundredPercentSubmit_new,'')<>'' THEN c.HundredPercentSubmit_new
						   ELSE [HundredPercentSubmit]
						   END
      ,G.[DateLastSelected] =  CASE 
	                           WHEN (ISNULL(c.SelectedForCms_new,'')<>'' AND c.SelectedForCms_new='1') THEN GETDATE()
						   ELSE [DateLastSelected]
						   END
      ,G.[DateLastUnSelected] =  CASE 
	                           WHEN (ISNULL(c.SelectedForCms_new,'')<>'' AND c.SelectedForCms_new='0') THEN GETDATE()
						   ELSE [DateLastUnSelected]
						   END
       
    ,G.[LastModifiedBy] =@UserName-- <LastModifiedBy, varchar(50),>  
      ,G.[UpDatedFrom] = 'BulkUploadUpdate'
	  ,G.isEndToEndReported= c.EndtoEndReporting_new
FROM [dbo].[tbl_GPRO_TIN_Selected_Measures] G JOIN tbl_CI_BulkFileUploadCmsData c
on g.TIN=c.TIN and g.Measure_num=c.Measure_Name and g.Submission_year=c.CmsYear
and c.IsRowEditedByUser=1
AND (c.Npi IS NULL OR c.Npi ='')
AND c.FileId=@FileId
and c.IsValidata=1

update c
set c.Is_MeasureDataUpdated=1
FROM [dbo].[tbl_GPRO_TIN_Selected_Measures] G JOIN tbl_CI_BulkFileUploadCmsData c
on g.TIN=c.TIN and g.Measure_num=c.Measure_Name and g.Submission_year=c.CmsYear
and c.IsRowEditedByUser=1
AND (c.Npi IS NULL OR c.Npi ='')
AND c.FileId=@FileId
and c.IsValidata=1

-------INSERT
	INSERT INTO [dbo].[tbl_GPRO_TIN_Selected_Measures]
           ([Measure_num]
           ,[Submission_year]
           ,[TIN]
           ,[SelectedForSubmission]
           ,[TotalCasesReviewed]
           ,[HundredPercentSubmit]
           ,[DateLastSelected]
          -- ,[DateLastUnSelected]
          ,[LastModifiedBy]
           ,[Is_Active]
           ,[Is_90Days]
           ,[UpDatedFrom]
		   ,isEndToEndReported)

SELECT 
      A.[Measure_Name]
      ,A.[CmsYear]
	 ,A.[TIN]    
	  ,CONVERT(Bit,A.[SelectedForCms_new]) as [SelectedForCms_new]
       ,CONVERT(int,A.[Total_no_of_exams_new]) as [Total_no_of_exams_new]
      --,[HundredPercentSubmit_old]
      ,CONVERT(Bit, A.[HundredPercentSubmit_new]) as [HundredPercentSubmit_new]
	 ,GETDATE()     
      ,A.[Createdby]
	 ,1
	 ,0
     ,'BulkUploadInsert'
	 ,CONVERT(Bit,A.EndtoEndReporting_new) as EndtoEndReporting_new
  FROM [dbo].[tbl_CI_BulkFileUploadCmsData] A 
  where A.FileId=@FileId
  AND A.IsValidata=1
  AND A.IsRowEditedByUser=1
  AND (A.Npi IS NULL OR A.Npi ='')
  AND (A.Is_MeasureDataUpdated=0 OR A.Is_MeasureDataUpdated is null)

  /*
  15	Posted	
16	PostedPartially	
  */

---update that row as invalid with database execution issue
 --PRINT ('ERROR in Insert/Upload using measure'+ISNULL(@Measure_Name,'')+', TIN :'+ISNULL(@TIN,'..'))

 --UPDATE [tbl_CI_BulkFileUploadCmsData]
  
 --  SET  IsValidata =0,
 --  ErrorMessage='BulkUpload Insert/Upload Issue'
   
 --  WHERE FileId=@FileId 
 --AND CmsDataId=@CmsDataId
 --AND  FileId=@FileId

 
  /*Qmeasure data updating*/
   
 UPDATE  P
				  SET 
 
				 P.SelectedForSubmission = CASE WHEN  B.SelectedForCms_new ='1'  THEN 1 
												WHEN  B.SelectedForCms_new ='0' THEN 0
												when B.SelectedForCms_new is null 
												and 
												exists(select 1 from tbl_CI_BulkFileUploadCmsData where 
																										CmsYear=p.Submission_year 
																										and TIN=p.TIN
																										and Measure_Name=p.Measure_num
																										
																										) 
																										then 0
																									

					ELSE 	p.SelectedForSubmission END
					from
					tbl_GPRO_TIN_Selected_Measures P
					LEFT JOIN
					tbl_CI_BulkFileUploadCmsData B 
							on  B.FileId=@FileId
								AND   (b.Measure_Name like '%Q%'  OR b.Measure_Name  IN (SELECT MES  FROM @NONQMES))												   
								and B.Measure_Name=P.Measure_num
								and B.CmsYear=P.Submission_year													  
								and B.TIN=P.TIN	
								and b.IsValidata=1 	
								and IsRowEditedByUser=1											
													    
				 WHERE 
					(P.Measure_num like '%Q%'  OR P.Measure_num  IN (SELECT MES  FROM @NONQMES))											 													 
												AND P.Submission_year=@_CMSYEAR
												and p.TIN in (select distinct tin from tbl_CI_BulkFileUploadCmsData  
																			where
																				fileId=@FileId
																				and
																				(Measure_Name like '%Q%'  OR Measure_Name  IN (SELECT MES  FROM @NONQMES)))
END
 IF(@IsGPORO=0 AND EXISTS(SELECT 1 FROM tbl_CI_BulkFileUpload_History WHERE Status IN (12,14) AND FileId=@FileId))--non gpro related  code
BEGIN
print('NonGpro')

 UPDATE G
   SET 
      G.[SelectedForSubmission] = CASE 
	                           WHEN ISNULL(c.SelectedForCms_new,'')<>'' THEN c.SelectedForCms_new
						   ELSE [SelectedForSubmission] 
						   END
      ,G.[TotalCasesReviewed] = CASE 
								WHEN ISNULL(TRY_PARSE(C.Total_no_of_exams_new as int),0) =0 AND C.HundredPercentSubmit_new ='1' THEN 0
	                           WHEN ISNULL(c.Total_no_of_exams_new,'')<>'' THEN c.Total_no_of_exams_new
						   ELSE [TotalCasesReviewed]
						   END
      ,G.[HundredPercentSubmit] = CASE 
								WHEN ISNULL(TRY_PARSE(C.Total_no_of_exams_new as int),0) >0 AND C.HundredPercentSubmit_new IS NULL THEN 0
	                           WHEN ISNULL(c.HundredPercentSubmit_new,'')<>'' THEN c.HundredPercentSubmit_new
						   ELSE [HundredPercentSubmit]
						   END
      ,G.[DateLastSelected] =  CASE 
	                           WHEN (ISNULL(c.SelectedForCms_new,'')<>'' AND c.SelectedForCms_new=1) THEN GETDATE()
						   ELSE [DateLastSelected]
						   END
      ,G.[DateLastUnSelected] =  CASE 
	                           WHEN (ISNULL(c.SelectedForCms_new,'')<>'' AND c.SelectedForCms_new=1) THEN GETDATE()
						   ELSE [DateLastUnSelected]
						   END
       
    ,G.[LastModifiedBy] =@UserName-- <LastModifiedBy, varchar(50),>  
      ,G.[UpDatedFrom] = 'BulkUploadUpdate'
	  ,G.isEndToEndReported= c.EndtoEndReporting_new
FROM [dbo].tbl_Physician_Selected_Measures G JOIN tbl_CI_BulkFileUploadCmsData c
on g.TIN=c.TIN 
and g.NPI=c.Npi 
and g.Measure_num_ID=c.Measure_Name
and g.Submission_year=c.CmsYear
and c.IsRowEditedByUser=1
AND  c.Npi <>''
AND c.FileId=@FileId
and c.IsValidata=1

update c
set c.Is_MeasureDataUpdated=1
FROM [dbo].tbl_Physician_Selected_Measures G JOIN tbl_CI_BulkFileUploadCmsData c
on g.TIN=c.TIN 
and g.NPI=c.Npi 
and g.Measure_num_ID=c.Measure_Name
and g.Submission_year=c.CmsYear
and c.IsRowEditedByUser=1
AND  c.Npi <>''
AND c.FileId=@FileId
and c.IsValidata=1

-------INSERT
	INSERT INTO [dbo].tbl_Physician_Selected_Measures
           ([Measure_num_ID]
           ,[Submission_year]
           ,[TIN]
		   ,NPI
           ,[SelectedForSubmission]
           ,[TotalCasesReviewed]
           ,[HundredPercentSubmit]
           ,[DateLastSelected]
          -- ,[DateLastUnSelected]
          ,[LastModifiedBy]
           ,[Is_Active]
           ,[Is_90Days]
           ,[UpDatedFrom]
		   ,isEndToEndReported
		   ,Physician_ID)

SELECT 
      A.[Measure_Name]
      ,A.[CmsYear]
	 ,A.[TIN]    
	 ,A.Npi
	  ,CONVERT(Bit,A.[SelectedForCms_new]) as [SelectedForCms_new]
       ,CONVERT(int,A.[Total_no_of_exams_new]) as [Total_no_of_exams_new]
      --,[HundredPercentSubmit_old]
      ,CONVERT(Bit, A.[HundredPercentSubmit_new]) as [HundredPercentSubmit_new]
	 ,GETDATE()     
      ,A.[Createdby]
	 ,1
	 ,0
     ,'BulkUploadInsert'
	 ,CONVERT(Bit,A.EndtoEndReporting_new) as EndtoEndReporting_new
	 ,(select  UserID from tbl_Users where NPI=A.Npi)
  FROM [dbo].[tbl_CI_BulkFileUploadCmsData] A 
  where A.FileId=@FileId
  AND A.IsValidata=1
  AND A.IsRowEditedByUser=1
AND  A.Npi <>''
  AND (A.Is_MeasureDataUpdated=0 OR A.Is_MeasureDataUpdated is null)

   update  P
  set 
    P.SelectedForSubmission = CASE WHEN  B.SelectedForCms_new ='1'  THEN 1
	                               WHEN  B.SelectedForCms_new ='0' THEN 0
												when B.SelectedForCms_new is null 
												and 
												exists(select 1 from tbl_CI_BulkFileUploadCmsData where 
																										CmsYear=p.Submission_year 
																										and TIN=p.TIN
																										and NPI=p.NPI
																										and Measure_Name=p.Measure_num_ID
																										) 
		         																						then 0 else p.SelectedForSubmission end      
  from
  tbl_Physician_Selected_Measures P
   LEFT JOIN
  tbl_CI_BulkFileUploadCmsData B 
   on  B.FileId=@FileId
AND   (b.Measure_Name like '%Q%'  OR b.Measure_Name  IN (SELECT MES  FROM @NONQMES))												   
													   and B.CmsYear=P.Submission_year
													   and B.Measure_Name=P.Measure_num_ID
													   and B.TIN=P.TIN	
													   and B.Npi=p.NPI	
													  and b.IsValidata=1 	
													  and b.IsRowEditedByUser=1												   
													  WHERE 
													  	(P.Measure_num_ID like '%Q%'  OR P.Measure_num_ID  IN (SELECT MES  FROM @NONQMES))											 													 
												AND P.Submission_year=@_CMSYEAR
												and p.TIN in (select distinct tin from tbl_CI_BulkFileUploadCmsData  
																			where
																				fileId=@FileId
																				and
																				(Measure_Name like '%Q%'  OR Measure_Name  IN (SELECT MES  FROM @NONQMES)))
END

---STEP:Update [tbl_CI_BulkFileUpload_History]
UPDATE [dbo].[tbl_CI_BulkFileUpload_History]
   SET
      [TotalEditedExcelRecordsCount] = (SELECT COUNT(*) from tbl_CI_BulkFileUploadCmsData where FileId=@FileId and IsRowEditedByUser=1)
      ,[ValidExcelRecords] = (SELECT COUNT(*) from tbl_CI_BulkFileUploadCmsData where FileId=@FileId and IsValidata=1)
      ,[InvalidExcelRecords] =(SELECT COUNT(*) from tbl_CI_BulkFileUploadCmsData where FileId=@FileId and ISNULL(ErrorMessage ,'') <>'' and ISNULL(IsValidata,0)=0)
      ,[TotalExcelRecords] = (SELECT COUNT(*) from tbl_CI_BulkFileUploadCmsData where FileId=@FileId)
   
	
	,Status			= CASE  When Status =13 then Status  WHEN Status =14 THEN 16 ELSE 15 END,
 IsPartiallyPosted = CASE  WHEN Status =14 THEN 1 ELSE 0 END
 WHERE  FileId=@FileId AND Status IN (12,14) and Status !=21

 ---STEP:Need to call performance related SP's
 --Change#2
  if(@IsGPORO = 1)
	 BEGIN
	 EXEC [dbo].[SPCI_BulkUpload_ReCalculatePerformance_TIN_Measure] @FileId
	 END
	ELSE
	 BEGIN
	 EXEC [dbo].[SPCI_BulkUpload_ReCalculatePerformance_TIN_NPI_Measure] @FileId
	 END
	 
END
END
