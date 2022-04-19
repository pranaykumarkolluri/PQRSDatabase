
-- =============================================
-- Author:		Raju & Hari
-- Create date: sep-07-12
-- Description:	 update numerator_response value from tbl_file_rawdata
-- =============================================
CREATE PROCEDURE  [dbo].[SpUpdateNumertorValueFromTblFile_Rawdata]
	-- Add the parameters for the stored procedure here

	 @startdate datetime,
	 @enddate datetime
	AS

BEGIN
    
	--exam_date, TIN, NPI, Patient_ID, Measure_num and CPT_code

	declare @PhysicianNPI as varchar(50);
	declare @Exam_Date datetime
	declare @ExamTIN as varchar(10);
	declare @Patient_Id varchar(500);

	declare @Measure_Num varchar(50);
	declare @FileId int;

	declare @CPT_Code varchar(50);

	declare @Num_Code varchar(50);

	declare @isuccess bit;
	declare @No_of_Errors int;
	declare @message varchar(max);
	declare @recordid int;
	declare @ExamMeasureId int;

	declare @new_newmeric_response_value smallint;



	--CURSER STARTS
	declare File_Rawdata CURSOR FOR
	    
    --STEP #1: Getting Required RAW DATA to UPDATE 
   select 
  
   Physician_Group_TIN,
   Physician_NPI,
   Patient_ID,

   fileid,
   Measure_Number,
   CPT_Code,
   Exam_Date_Time,
   record_id,
   Numerator_Response_value
     from tbl_File_rawdata 
	where
	--add new columm for <>'Completed'
	 ( ISNULL(Physician_Group_TIN,'') <>'' AND 
	ISNULL(Physician_NPI,'') <>'' AND 
	ISNULL(Patient_ID,'') <>'' AND 
	ISNULL(Measure_Number,'') <>'' AND 
	ISNULL(Exam_Date_Time,'') <>'' AND 
	ISNULL(fileid,'') <>'' AND
	ISNULL(Record_Status,'') <> 'Completed' AND
	ISNULL(Record_Status,'') <> 'NotFound' 
	)
	order by  fileid,record_id
    
    OPEN File_Rawdata

    
     FETCH NEXT FROM File_Rawdata INTO  @ExamTIN, @PhysicianNPI,@Patient_Id,@FileId,@Measure_Num,@CPT_Code,@Exam_Date,@recordid,@Num_Code

    WHILE @@FETCH_STATUS=0

    BEGIN


     -----------------INSide Cursor STARTS------------------------------

	 set @isuccess=0;
	 SET @message = '' ;
     SET @No_of_Errors = 0 ;
        set @isuccess=1
     SET @ExamMeasureId=0;
	 set @enddate= DATEADD(day,1,getdate());

	select @ExamMeasureId= MD.Exam_Measure_Id,@new_newmeric_response_value =N.Numerator_response_Value	 


	 from tbl_Exam e   with(nolock) 
	  inner join tbl_Exam_Measure_Data MD   with(nolock) on md.Exam_Id = e.Exam_Id and md.CMS_Submission_Year = e.CMS_Submission_Year 
	  inner join tbl_Lookup_Measure m   with(nolock) on m.Measure_ID = md.Measure_ID and m.CMSYear = md.CMS_Submission_Year and  m.CMSYear = 2018
	  inner join tbl_lookup_Numerator_Code N on M.Measure_ID=N.Measure_ID
	  where e.CMS_Submission_Year = 2018
	  and e.Exam_Date = @Exam_Date
	  and e.Exam_TIN = @ExamTIN
	  and e.Physician_NPI =@PhysicianNPI
	--  and ((e.Patient_ID = 'n+bFEm7reCG8TNltIa3zKg==' )  or (e.Patient_ID = 'n+bFEm7reCG8TNltIa3zKg==' ) )
	-- and Rtrim((LTRIM(e.Patient_ID)) = Rtrim((LTRIM(@Patient_Id))
	 and ltrim(rtrim(e.Patient_ID))=ltrim(rtrim(@Patient_Id))
	  and (md.Denominator_proc_code = @CPT_Code)
	  and (m.Measure_num = @Measure_Num)
	
	  AND MD.Numerator_response_value=0
   AND N.Numerator_Code=@Num_Code	
	  AND 
        (1= CASE 
     WHEN ((ISNULL(MD.Last_Mod_Date,'')='')AND  MD.Created_Date BETWEEN  @startdate and @enddate) THEN 1
     WHEN (MD.Last_Mod_Date BETWEEN  @startdate and @enddate) THEN 1
	ELSE 0 END )
	AND E.[File_ID]=@FileId
	--select @ExamMeasureId
	IF( ISNULL(@ExamMeasureId,0) >0)
	BEGIN

	-- print ('Existed fileid['+Convert(varchar(50),@fileid)+'] exam_measureid['+Convert(varchar(50),@ExamMeasureId)+'] tin['+@ExamTIN+'] npi['+@PhysicianNPI+']  numericcode['+@Num_Code+']  examdate['+Convert(varchar(50),@Exam_Date)+'] patientid['+@Patient_Id+'] cptcode['+@CPT_Code+']' )
		 print ('Existed fileid['+Convert(varchar(50),@fileid)+'] exam_measureid['+Convert(varchar(50),@ExamMeasureId)+'] ')

		 update tbl_Exam_Measure_Data set Numerator_response_Value= @new_newmeric_response_value,
		 Numerator_Code=@Num_Code
		  where Exam_Measure_Id=@ExamMeasureId

		  update  tbl_File_rawdata set Record_Status='Completed' where record_id=@recordid
				END

	ELSE

	BEGIN

		 print ('not existed fileid['+Convert(varchar(50),@fileid)+'] tin['+@ExamTIN+'] npi['+@PhysicianNPI+']  numericcode['+@Num_Code+']  examdate['+Convert(varchar(50),@Exam_Date)+'] patientid['+@Patient_Id+'] cptcode['+@CPT_Code+']' )
	 update  tbl_File_rawdata set Record_Status='NotFound' where record_id=@recordid
	--	print('')	

	END

--print @fileid
 FETCH NEXT FROM File_Rawdata  INTO @ExamTIN, @PhysicianNPI,@Patient_Id,@FileId,@Measure_Num,@CPT_Code,@Exam_Date,@recordid,@Num_Code
  END
  
   
CLOSE File_Rawdata;
DEALLOCATE File_Rawdata;

END
