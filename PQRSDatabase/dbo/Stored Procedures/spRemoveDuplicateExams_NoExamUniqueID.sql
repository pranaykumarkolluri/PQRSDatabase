
-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 2017-Feb-01
-- Description:	Used to delete any duplicate records created
--Change #1: Hari j on 8th,Jan,2018
--Change #1:JIRA#622
--Change #2: Hari j on 10th,Jan,2018
--Change #2:JIRA#622--add hysician npi
-- =============================================
CREATE PROCEDURE [dbo].[spRemoveDuplicateExams_NoExamUniqueID]   
 -- Add the parameters for the stored procedure here  
   @intYear int =  0  
   
AS  
BEGIN  
   
declare @physician_npi as varchar(30)  
declare @exam_tin as varchar(30)  
declare @patient_id as varchar(50)  
declare @patient_age as int  
Declare @patient_gender as varchar(50)  
declare @exam_date as datetime  
declare @measure_id as int  
declare @denominator_proc_code as varchar(50)  
declare @denominator_diag_code as varchar(50)  
declare @numerator_response_value as varchar(50)  
--declare @exam_unique_id  as varchar(100)  
  
declare @intExamId as int  
declare @intMeasureID as int  
DECLARE @dupExams TABLE (ExamID int)  

DECLARE @Conditional_Exam_ID as int  
  
IF OBJECT_ID('tempdb..#tmp_dup') IS NOT NULL  
    DROP TABLE #tmp_dup  
  
  
  select physician_npi, exam_tin, patient_id, patient_age, patient_gender, exam_date, measure_id,  
  denominator_proc_code, denominator_diag_code, numerator_response_value--, exam_unique_id  
  into #tmp_dup  
  from vw_exam_data with(nolock)  
  
--  Where exam_TIN = '208251783' 
    
  group by physician_npi, exam_tin, patient_id, patient_age, patient_gender, exam_date, measure_id,  
  denominator, denominator_proc_code, denominator_diag_code, numerator_response_value, --exam_unique_id, 
  facility_id  
  having count(*) > 1 and  YEAR(Exam_Date) = case  @intYear when 0 then  YEAR(Exam_Date)  else  @intYear end  
  
  
declare curDuplicate cursor for  
 select  physician_npi, exam_tin, patient_id, patient_age, patient_gender, exam_date, measure_id,  
 denominator_proc_code, denominator_diag_code, numerator_response_value--, exam_unique_id   
 from #tmp_dup  
  
 OPEN curDuplicate    
 FETCH NEXT FROM curDuplicate INTO @physician_npi, @exam_tin,@patient_id  
 ,@patient_age, @patient_gender, @exam_date, @measure_id  
 ,@denominator_proc_code, @denominator_diag_code, @numerator_response_value--, @exam_unique_id    
  
WHILE @@FETCH_STATUS = 0    
BEGIN    
PRINT('CURSUR STARED')  
--Change #1 --starts  
  
  
--If 'Exam_last_modified_date' value exists for one of the 2 records, then this record should be kept, and the other one should be deleted  
     ---If both the duplicate records have 'Exam_last_modified_date', then the record with most recent date should be kept, and the other record should be deleted.  
IF((select COUNT(*) from vw_exam_data   
      where exam_tin = @exam_tin 
         and  physician_npi= @physician_npi  --Change #2
        and patient_id = @patient_id   
        and patient_age = @patient_age   
        and patient_gender = @patient_gender  
        and exam_date = @exam_date  
        and measure_id = @measure_id  
        and denominator_proc_code = @denominator_proc_code   
        and denominator_diag_code = @denominator_diag_code  
        and numerator_response_value = @numerator_response_value  
       -- and exam_unique_id = @exam_unique_id  
        and  YEAR(Exam_Date) = case  @intYear when 0 then  YEAR(Exam_Date)  else  @intYear end  
  
        AND ISNULL(Exam_Last_Modified_Date,'')<>'')  >=1  )  
  
BEGIN  
PRINT('Exam Date not  NUll')  
SELECT TOP 1  @Conditional_Exam_ID=examid From  
      vw_exam_data   
      where exam_tin = @exam_tin  
       and  physician_npi= @physician_npi  --Change #2 
        and patient_id = @patient_id   
        and patient_age = @patient_age   
        and patient_gender = @patient_gender  
        and exam_date = @exam_date  
        and measure_id = @measure_id  
        and denominator_proc_code = @denominator_proc_code   
        and denominator_diag_code = @denominator_diag_code  
        and numerator_response_value = @numerator_response_value  
       -- and exam_unique_id = @exam_unique_id  
        and  YEAR(Exam_Date) = case  @intYear when 0 then  YEAR(Exam_Date)  else  @intYear end  
       AND Exam_Last_Modified_Date=(  
         
         
       SELECT MAX(Exam_Last_Modified_Date)  
         
       from vw_exam_data   
      where exam_tin = @exam_tin   
       and  physician_npi= @physician_npi  --Change #2
        and patient_id = @patient_id   
        and patient_age = @patient_age   
        and patient_gender = @patient_gender  
        and exam_date = @exam_date  
        and measure_id = @measure_id  
        and denominator_proc_code = @denominator_proc_code   
        and denominator_diag_code = @denominator_diag_code  
        and numerator_response_value = @numerator_response_value  
     --   and exam_unique_id = @exam_unique_id  
        and  YEAR(Exam_Date) = case  @intYear when 0 then  YEAR(Exam_Date)  else  @intYear end  
       )                       
     ORDER BY ExamId desc  
  
END  
---CONDITION:If 'Exam_last_modified_date' is NULL, then the record with Max(Exam_Id) should be kept, and the others should be deleted  
   
ELSE  
BEGIN  
  
PRINT('Exam Date  NUll')  
SELECT TOP 1  @Conditional_Exam_ID=examid From  
     (select distinct top 100 percent  examid from vw_exam_data   
      where exam_tin = @exam_tin   
       and  physician_npi= @physician_npi  --Change #2
        and patient_id = @patient_id   
        and patient_age = @patient_age   
        and patient_gender = @patient_gender  
        and exam_date = @exam_date  
        and measure_id = @measure_id  
        and denominator_proc_code = @denominator_proc_code   
        and denominator_diag_code = @denominator_diag_code  
        and numerator_response_value = @numerator_response_value  
     --   and exam_unique_id = @exam_unique_id  
        and  YEAR(Exam_Date) = case  @intYear when 0 then  YEAR(Exam_Date)  else  @intYear end  
          
      ORDER BY ExamId DESC) x                       
     ORDER BY ExamId desc  
   
  
END  
--Change #1 --Ends  
  -- Get each duplicate and work  
  
       DECLARE db_cursor CURSOR FOR    
  
     SELECT @Conditional_Exam_ID  
  
     OPEN db_cursor    
     FETCH NEXT FROM db_cursor INTO @intExamId    
  
     WHILE @@FETCH_STATUS = 0    
     BEGIN    
        select  @intExamId as 'MaxExamId'  
		Insert into ExamId_MaxExamIds (ExamID) Select @intExamId -- Change made by Haritha; 01/08/2019 to collect all max exam ids
        -- pump into a temp table  
        --delete from @dupExams  
        -- ok  
        insert into @dupExams  
        select ExamId from vw_Exam_Data   
        where physician_npi = @physician_npi  
        and exam_tin = @exam_tin   
        and patient_id = @patient_id   
        and patient_age = @patient_age   
        and patient_gender = @patient_gender  
        and exam_date = @exam_date  
        and measure_id = @measure_id  
        and denominator_proc_code = @denominator_proc_code   
        and denominator_diag_code = @denominator_diag_code  
        and numerator_response_value = @numerator_response_value  
      --  and exam_unique_id = @exam_unique_id  
        and  ExamId <> @intExamId    
        and  YEAR(Exam_Date) = case  @intYear when 0 then  YEAR(Exam_Date)  else  @intYear end  
  
         
  
          
  
         FETCH NEXT FROM db_cursor INTO @intExamId    
     END    
  
     CLOSE db_cursor    
     DEALLOCATE db_cursor  
  
  
  -- end of each duplicate record  
  
  
  FETCH NEXT FROM curDuplicate INTO @physician_npi, @exam_tin,@patient_id  
  ,@patient_age, @patient_gender, @exam_date, @measure_id  
  ,@denominator_proc_code, @denominator_diag_code, @numerator_response_value--, @exam_unique_id    
End  
  
CLOSE curDuplicate    
DEALLOCATE curDuplicate  
  
   if exists (select top 1 * from @dupExams)  
   Begin  
   insert into tbl_DuplicateExam_IDs  
   select EXAMID,getdate(),'' from @dupExams  
  
  Insert into ExamId_DupExams Select Examid From @dupExams  -- Change made by Haritha; 01/08/2019 to collect all exam ids being deleted
       -- delete from table_extension   
        delete from tbl_Exam_Measure_Data_Extension where Exam_Measure_Data_ID in (  
         select Exam_Measure_Id from tbl_Exam_Measure_Data where exam_id in (  
          select EXAMID from @dupExams 
          )  
        )  
        -- delete from table_measure  
        delete  from tbl_Exam_Measure_Data   
       where exam_id in (select EXAMID from @dupExams         
       )  
       -- delete from table_exam  
       delete from tbl_Exam where Exam_Id   
       in (select EXAMID from @dupExams)  
  
   End  
  
END  



