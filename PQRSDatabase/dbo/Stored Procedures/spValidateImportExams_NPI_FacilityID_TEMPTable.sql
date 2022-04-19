










-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 17-Jul-20014
-- Description:	Objective of this procedure is to trigger validation of imported Exams data
-- Step#1 validate data per table i.e exams, exam, exam_measure, exam_measure_ext

-- Jan 24, 2018 - King changed logic to validate facility id
-- =============================================
CREATE PROCEDURE [dbo].[spValidateImportExams_NPI_FacilityID_TEMPTable] 
	
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @ExamsID int, 
@Transaction_ID nvarchar(50),
@Transaction_DateTime varchar(80),
@Num_of_exams_Included nvarchar(50),@Import_Facility_ID varchar(50),	
@PartnerId varchar(80),@Appid varchar(80),@Prev_Transction_ID varchar(80),@RawData_Id varchar(80);

Declare @message varchar(max);
Declare @messageJSON varchar(max);
Declare @ParentNode varchar(max);
Declare @blnExamDataExists bit;
Declare @intExamsCount int;
Declare @intCorrectExamCount int;
Declare @intInCorrectExamCount int;

Declare @intSuccessExamCount int
Declare @intPartialSuccessExamCount int
Declare @intValidationFailedExamCount int

Declare @intCorrectEXAMSCount int;
Declare @intInCorrectEXAMSCount int;

Declare @intSuccessEXAMSCount int
Declare @intPartialSuccessEXAMSCount int
Declare @intValidationFailedEXAMSCount int

Declare @dteImportDate datetime
Declare @strImportIPAddress varchar(50)
declare @No_of_Errors int
declare @blnKeyOk int;
declare @x as varchar(10)

IF OBJECT_ID('tempdb..#Exams') IS NOT NULL DROP TABLE #Exams
CREATE table #Exams (ExamsID int not null)


---find distinct FacilityIDs 

DECLARE @LoopValue int =0;
IF OBJECT_ID('tempdb..#FacilityIDs') IS NOT NULL DROP TABLE #FacilityIDs
CREATE table #FacilityIDs (FacilityID varchar(50))

--find NPI and FacilityID combination
IF OBJECT_ID('tempdb..#NPIFacilityIDs') IS NOT NULL DROP TABLE #NPIFacilityIDs
CREATE table #NPIFacilityIDs (NPI varchar(10),FacilityID varchar(50))



--select * from #FacilityIDs



SET DATEFORMAT MDY;

DECLARE Cursor_Imports CURSOR FOR 
select top 5000 ExamsID,Transaction_ID,Transaction_DateTime,Num_of_exams_Included,PartnerId,Appid,Prev_Transction_ID,facility_id,RawData_Id
	from tbl_Import_Exams with(nolock) where Import_Status = 1

OPEN Cursor_Imports

FETCH NEXT FROM Cursor_Imports 
INTO @ExamsID, @Transaction_ID,@Transaction_DateTime,@Num_of_exams_Included,@PartnerId,@Appid,@Prev_Transction_ID,@Import_Facility_ID,@RawData_Id

WHILE @@FETCH_STATUS = 0
BEGIN
   set @message = '';
   set @messageJSON = ''
   set @No_of_Errors = 0;
   set @blnKeyOk = 1;
   --set @ParentNode = '[Parent Data-->PartnerID: ' + isnull(@PartnerId,'missing') + '\TransactionID: ' + isnull(@Transaction_ID,'missing') + '\Trans Datetime:' + isnull(@Transaction_DateTime,'missing')
   set @ParentNode = '';
   


 SET  @LoopValue=@LoopValue+1;


 if(@LoopValue=1)--------redefined code start
 BEGIN
 print('loop value is 1:-----------')
 insert into #FacilityIDs
select distinct ID from [nrdr]..facility readonly with (nolock) where id in (select distinct top 5000  facility_id from tbl_Import_Exams where Import_Status=1 and Facility_Id is not null)




declare @curFacilityIDs varchar(50)

declare CUR_FacilityID CURSOR FOR
select   FacilityID from #FacilityIDs 

open CUR_FacilityID

FETCH NEXT FROM CUR_FacilityID
 into @curFacilityIDs 

 
 WHILE @@FETCH_STATUS = 0
 BEGIN
 

 insert into #NPIFacilityIDs
select distinct @curFacilityIDs, nupp.npi from [NRDR]..physician p with (nolock)
                              inner join [NRDR]..nrdr_user_physician_profile nupp with (nolock) on (nupp.npi = p.npi)
                              inner join [NRDR]..aspnet_Users au with (nolock) on (au.UserId = nupp.UserId)
                              where nupp.npi <> '' and  p.facility_id = @curFacilityIDs 
						 and 
						p.NPI COLLATE  DATABASE_DEFAULT  in(

						select distinct Import_Physician_NPI  COLLATE  DATABASE_DEFAULT from tbl_Import_Exam where Import_ExamsID in(
select distinct top 5000  ExamsID 
-- COLLATE  DATABASE_DEFAULT 
 from tbl_Import_Exams order by ExamsID desc)
 
					--select NPI COLLATE  DATABASE_DEFAULT  from #NPIs
						)





 FETCH NEXT FROM CUR_FacilityID
 into @curFacilityIDs 
 END

 CLOSE CUR_FacilityID;
 DEALLOCATE CUR_FacilityID;

 END------redefined code end

    if (@Transaction_ID is null) or (ISNULL(@Transaction_ID,'') = '')
    Begin
    set @message = @message + 'P2001:Missing Transaction_ID' + CHAR(10) ;
    set @No_of_Errors = @No_of_Errors +1;
    set @blnKeyOk = 0;
    End
    
   if  (@Transaction_DateTime is not null) 
   Begin
   set @Transaction_DateTime = LTRIM(rtrim(@Transaction_DateTime));
   End
 
    if (@Transaction_DateTime is null) or (ISNULL(@Transaction_DateTime,'') = '')
		Begin
		set @message = @message + 'P2011:Missing Transaction_DateTime' + CHAR(10) ;
		set @No_of_Errors = @No_of_Errors +1;
		End
	else if ISDATE(@Transaction_DateTime)= 0
			Begin
				set @message = @message + 'P2012:Transaction_DateTime is not a valid date time in format mm/dd/yyyy' + CHAR(10) ;
				set @No_of_Errors = @No_of_Errors +1;
			End
		else if (ISDATE(@Transaction_DateTime)= 1 and (convert(datetime,convert(varchar(20),@Transaction_DateTime,101)) > getdate()) )
		Begin				
				set @message = @message + 'P2013:Transaction_DateTime (' + @Transaction_DateTime + ')is future dated. Tested format mm/dd/yyyy' + CHAR(10) ;
				set @No_of_Errors = @No_of_Errors +1;
		end
  
    if (@Num_of_exams_Included is null) or (ISNULL(@Num_of_exams_Included,'') = '')
      Begin
		set @message = @message + 'P2021:Missing Num_of_Exam_Included' + CHAR(10) ;
		set @No_of_Errors = @No_of_Errors +1;
       End
    Else if dbo.IsInteger(@Num_of_exams_Included) = 0
    --Else if ISNUMERIC(@Num_of_exams_Included) = 0
      Begin
			 set @message = @message + 'P2022:Entered value for Num_of_Exam_Included is not an integer' + CHAR(10) ;
			 set @No_of_Errors = @No_of_Errors +1;
      End
    
     if (@PartnerId is null) or (ISNULL(@PartnerId,'') = '')
    Begin
    set @message = @message + 'P2031:Missing PartnerID' + CHAR(10) ;
    set @No_of_Errors = @No_of_Errors +1;
    set @blnKeyOk = 0;
    End
    
     if (@Appid is null) or (ISNULL(@Appid,'') = '')
    Begin
    set @message = @message + 'P2041:Missing AppID' + CHAR(10) ;
    set @No_of_Errors = @No_of_Errors +1;
    set @blnKeyOk = 0;
    End
    
     if (@Import_Facility_ID is null) or (ISNULL(@Import_Facility_ID,'') = '')
    Begin
		set @message = @message + 'P2051:Missing Facility_ID' + CHAR(10) ;
		set @No_of_Errors = @No_of_Errors +1;
   End
   ELSE IF (dbo.IsInteger(@Import_Facility_ID) <> 1)
	   BEGIN 
			set @message = @message + 'P2052:Facility_ID: ' + ISNULL(@Import_Facility_ID,'') + ' not invalid it must be integer.' + CHAR(10) ;
			set @No_of_Errors = @No_of_Errors +1;
	   END
   ELSE 
   BEGIN

   /* Jan 24, 2018 - King change the logic to query NRDR directly to validate the facility id instead of
                     saving the facility ids into a table variable and then do the comparison
	*/
	/*
			declare @FacilityList table (Facility_id int)      
			set @x  = '0'
			select @x = cast(ISNULL(@Import_Facility_ID,'0')  as int)
			insert @FacilityList (Facility_id)
			exec NRDR..sp_getListOfFacilities @x
			
			if not exists(select top 1 * from @FacilityList where Facility_id = @x)
	*/
			set @x  = '0'
			select @x = cast(ISNULL(@Import_Facility_ID,'0')  as int)
			--if not exists(select top 1 * from [nrdr]..facility readonly with (nolock) where id = @x)
			if not exists(select top 1 * from #FacilityIDs readonly with (nolock) where FacilityID = @x)
			
			Begin
			 set @message = @message + 'P2053:Facility_ID: ' + ISNULL(@Import_Facility_ID,'') + ' not listed or invalid.' + CHAR(10) ;
			set @No_of_Errors = @No_of_Errors +1;
			End
			
   END 
    
    --transaction_id, partnerID and AppID
    
    if (ISNULL(@Transaction_ID,'') <> '') and (ISNULL(@Appid ,'') <> '') 
        and (ISNULL(@PartnerId,'') <> '') and (@blnKeyOk = 1)
    Begin
		if exists ( select  * from tbl_Import_Exams where Transaction_ID = @Transaction_ID and Appid  = @Appid and 
		PartnerId  = @PartnerId and (ExamsID <> @ExamsID) and (ExamsID < @ExamsID) )
		begin
		 set @message = @message + 'P2003:Transaction_ID must be unique. Transaction_ID [' + ISNULL(@Transaction_ID,'') +'] has been submitted in a previous transaction by AppID [' + ISNULL(@Appid ,'')+ '],PartnerID [' + ISNULL(@PartnerId,'') + '].' + CHAR(10) ;
    set @No_of_Errors = @No_of_Errors +1;
		end
    End
     if (ISNULL(@Transaction_ID,'') <> '')
     Begin
				select  @message = @message + 'P2004: Transaction_ID must be unique. Transaction_ID [' + ISNULL(@Transaction_ID,'') + '] is submitted multiple times in same file.' + CHAR(10),
				@No_of_Errors = @No_of_Errors +1
				from tbl_Import_Exams 
				where ExamsID = @ExamsID and Transaction_ID = @Transaction_ID 
				group by ExamsID,Transaction_ID
				having Count(Transaction_ID) > 1
     End
    
     if ((@Prev_Transction_ID is not null) AND (ISNULL(@Prev_Transction_ID,'') <> ''))
    Begin
		if not exists ( select top 1 * from tbl_Import_Exams where Transaction_ID = @Prev_Transction_ID 
			and Appid = @Appid and PartnerId = @PartnerId)
			Begin
			set @message = @message + 'P2062:Invalid Prev_Transction_ID. No Transaction with Transaction_ID [' +ISNULL(@Prev_Transction_ID,'') + '] received till now.' + CHAR(10) ;
			set @No_of_Errors = @No_of_Errors +1;
			End
    
    End
    
    
		set @blnExamDataExists = 1;
		set @intExamsCount = 0;
		set @intCorrectExamCount =0;
		set @intInCorrectExamCount =0;
		set @intSuccessExamCount =0;
		set @intPartialSuccessExamCount =0;
		set @intValidationFailedExamCount =0;
		
		if not exists ( select top 1 * from tbl_Import_Exam where Import_ExamsID = @ExamsID)
			Begin
				set @message = @message + 'P2071:Missing Exam Object Information.' + CHAR(10) ;
				set @blnExamDataExists = 0
				set @No_of_Errors = @No_of_Errors +1;
			End
		else 
			Begin
				select @intExamsCount = COUNT(*) from tbl_Import_Exam where Import_ExamsID = @ExamsID
			 
				IF dbo.IsInteger(@Num_of_exams_Included) = 1
					Begin			
						 if( @intExamsCount <>  convert(int,@Num_of_exams_Included)) 
						 Begin
						 set @message = @message + 'P2072:Data in Num_of_Exam_Included [' + @Num_of_exams_Included + '] does not match with Exams received [' + CONVERT(varchar(10),@intExamsCount) +'].' + CHAR(10) ;
						 set @No_of_Errors = @No_of_Errors +1;
						 End
					End
				--Else
				--	Begin
				--		set @message = @message + 'P2073:Data in Num_of_Exam_Included (' + @Num_of_exams_Included + ') is not a valid integer. '  + CHAR(10) ;
				--		 set @No_of_Errors = @No_of_Errors +1;
					
				--	End
			 
			End
    
		  if (@blnExamDataExists = 1)
			Begin
				
				exec dbo.spValidateImportExam @ExamsID,@Transaction_ID, @ParentNode, @Import_Facility_ID	 
				--Now Check for exam error count			
				
					select  @intCorrectExamCount = case  when (( Error_Codes_Desc  is null) and ( ([Status]  = 3 ) or ([Status] = 4))) then (@intCorrectExamCount + 1) else @intCorrectExamCount end,
						@intInCorrectExamCount = case  when (( Error_Codes_Desc  is not null) or (([Status]  <> 3 )and ([Status]  <> 4 ))) then (@intInCorrectExamCount + 1) else @intInCorrectExamCount end,
						@intSuccessExamCount = case [Status] when 3 then (@intSuccessExamCount + 1) else @intSuccessExamCount end,
						@intPartialSuccessExamCount = case [Status] when 4 then (@intPartialSuccessExamCount + 1) else @intPartialSuccessExamCount end,
						@intValidationFailedExamCount = case [Status] when 5 then (@intValidationFailedExamCount + 1) else @intValidationFailedExamCount end
						from tbl_Import_Exam where Import_ExamsID = @ExamsID 
				
			End 
			
			
		    
    if (isnull(@message,'') <> '')
    Begin
			
--Declare @dteImportDate datetime
--Declare @strImportIPAddress varchar(50)

		select @dteImportDate = ImportDate , @strImportIPAddress = isnull(ImportIPAddress,'missing') from tbl_Import_Raw where ImportID = @RawData_Id
		set @messageJSON = @message;
		--set @message = 'Errors In Import File exams Set from IP Address:' + @strImportIPAddress + ' ,imported time:' + convert(varchar(24),@dteImportDate)  + @ParentNode + CHAR(10) +  @message;
		set @message = 'Errors In Transaction ID [' + ISNULL(@Transaction_ID,'')  +']' + @ParentNode + CHAR(10) +  @message;
		--@ParentNode
		
		update tbl_Import_Exams set		
		Error_Codes_Desc =   @message,
		Error_Codes_JSON = @messageJSON,
		Correct_ExamCount = @intCorrectExamCount,
		InCorrect_ExamCount = @intInCorrectExamCount
		,Import_Status = 5
		,No_of_Errors = @No_of_Errors 
		where ExamsID  = @ExamsID
		
		PRINT '-------- Exam Report --------';
		 Print @message;
		 PRINT '-------- End Report --------';
    end
    else 
		Begin
						--select 						 
						--  @intCorrectExamCount as 'Correct_ExamCount',
						--@intInCorrectExamCount as 'InCorrect_ExamCount',
						--case when (@intCorrectExamCount  = 0 ) then 5
						--when (@intCorrectExamCount  > 0  and @intInCorrectExamCount > 0)or (@intPartialSuccessExamCount > 0) then 4
						--when (@intCorrectExamCount  > 0 and (@intPartialSuccessExamCount > 0)) then 4
						--when (@intCorrectExamCount  > 0 and (@intPartialSuccessExamCount = 0)) then 3 
						--end as 'Import_Status'
		
			update tbl_Import_Exams set		
			Error_Codes_Desc  = null ,
			Error_Codes_JSON  = null,
			Correct_ExamCount = @intCorrectExamCount,
			InCorrect_ExamCount = @intInCorrectExamCount
			,Import_Status =case when (@intCorrectExamCount  = 0 ) then 5
						when (@intCorrectExamCount  > 0  and @intInCorrectExamCount > 0)or (@intPartialSuccessExamCount > 0) then 4
						when (@intCorrectExamCount  > 0 and (@intPartialSuccessExamCount > 0)) then 4
						when (@intCorrectExamCount  > 0 and (@intPartialSuccessExamCount = 0)) then 3 
						end
			,No_of_Errors = @No_of_Errors 
			where ExamsID  = @ExamsID
		End
  
    insert into #Exams values (@ExamsID);
    
    FETCH NEXT FROM Cursor_Imports 
    INTO @ExamsID, @Transaction_ID,@Transaction_DateTime,@Num_of_exams_Included,@PartnerId,@Appid,@Prev_Transction_ID,@Import_Facility_ID,@RawData_Id
END 
CLOSE Cursor_Imports;
DEALLOCATE Cursor_Imports;

DECLARE Cursor_RawData CURSOR FOR 
		select distinct RawData_Id from tbl_Import_Exams e inner join #Exams on e.ExamsID = #Exams.ExamsID

		OPEN Cursor_RawData

		FETCH NEXT FROM Cursor_RawData 
		INTO @RawData_Id
		WHILE @@FETCH_STATUS = 0
		BEGIN

		 --select * from tbl_Import_Raw where tbl_Import_Raw.ImportID = CONVERT(int,@RawData_Id);
		set @intCorrectEXAMSCount =0;
		set @intInCorrectEXAMSCount =0;
		set @intSuccessEXAMSCount =0;
		set @intPartialSuccessEXAMSCount =0;
		set @intValidationFailedEXAMSCount =0;
				select  @intCorrectEXAMSCount = case  when (( Error_Codes_Desc  is null) and ((Import_Status  = 3)or (Import_Status  = 4)) ) then (@intCorrectEXAMSCount + 1) else @intCorrectEXAMSCount end,
						@intInCorrectEXAMSCount = case  when (( Error_Codes_Desc  is not null) or ((Import_Status  <> 3) and (Import_Status  <> 4))) then (@intInCorrectEXAMSCount + 1) else @intInCorrectEXAMSCount end,
						@intSuccessEXAMSCount = case Import_Status when 3 then (@intSuccessEXAMSCount + 1) else @intSuccessEXAMSCount end,
						@intPartialSuccessEXAMSCount = case Import_Status when 4 then (@intPartialSuccessEXAMSCount + 1) else @intPartialSuccessEXAMSCount end,
						@intValidationFailedEXAMSCount = case Import_Status when 5 then (@intValidationFailedEXAMSCount + 1) else @intValidationFailedEXAMSCount end
						from tbl_Import_Exams where RawData_Id = @RawData_Id 
						
			 
			
			update 	dbo.tbl_Import_Raw 
			set [Status] = case when ((@intCorrectEXAMSCount = 0)	and (@intValidationFailedEXAMSCount > 0)) then 9 
			 else 2
			end,
			Correct_ExamsCount = @intCorrectEXAMSCount,
			InCorrect_ExamsCount = @intInCorrectEXAMSCount,
			Data_Status = case when (@intCorrectEXAMSCount  = 0 ) then 5
						when (@intCorrectEXAMSCount  > 0  and (@intInCorrectEXAMSCount > 0)or (@intPartialSuccessEXAMSCount > 0)) then 4
						when (@intCorrectEXAMSCount  > 0 and (@intPartialSuccessEXAMSCount > 0)) then 4
						when (@intCorrectEXAMSCount  > 0 and (@intPartialSuccessEXAMSCount = 0)) then 3 
						end
			where ImportID = CONVERT(int,@RawData_Id)			

		 
		 FETCH NEXT FROM Cursor_RawData 
			INTO @RawData_Id
		END 
		CLOSE Cursor_RawData;
		DEALLOCATE Cursor_RawData


	
END









