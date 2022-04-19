-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 17-jul-2014
-- Description:	Used to validate Measure Data Extension Data
-- =============================================
CREATE PROCEDURE [dbo].[spValidateImportExamMeasureDataExtension] 
	-- Add the parameters for the stored procedure here
	@Measure_Data_ID int 
AS
BEGIN

	SET NOCOUNT ON;
Declare @Import_Measure_Data_Ext_ID int,
 @Import_Measure_Data_ID int,
  @Import_Measure_Extension_Num varchar(50),
  @Import_Measure_Extension_Reponse_Code varchar(50)
Declare @message varchar(max);
Declare @messageJSON varchar(max);

Declare @validMeasureNum varchar(10),
@validMeasureExtNum varchar(10);

DECLARE @CMSYEAR INT;
DECLARE @IMPORT_EXAM_ID INT;

declare @No_of_Errors int
declare @invalidCodes varchar(1000)

DECLARE Cursor_Imp_Mes_Data_Ext CURSOR FOR 
select 
 Import_Measure_Data_Ext_ID,
  Import_Measure_Data_ID,
   Import_Measure_Extension_Num,
   Import_Measure_Extension_Reponse_Code    
 from dbo.tbl_Import_Measure_Data_Extension
   where Import_Measure_Data_ID = @Measure_Data_ID

OPEN Cursor_Imp_Mes_Data_Ext

FETCH NEXT FROM Cursor_Imp_Mes_Data_Ext 
INTO @Import_Measure_Data_Ext_ID,
	 @Import_Measure_Data_ID,
	 @Import_Measure_Extension_Num ,
	 @Import_Measure_Extension_Reponse_Code 

WHILE @@FETCH_STATUS = 0
BEGIN
   set @message = '';
   set @messageJSON = '';
    set @No_of_Errors = 0;
   set @validMeasureNum = '';
   set  @validMeasureExtNum = '';
   
     select @validMeasureNum = Import_Measure_num,@IMPORT_EXAM_ID= Import_ExamID from tbl_Import_Exam_Measure_Data
			  where Import_Exam_MeasureID = @Import_Measure_Data_ID

SELECT @CMSYEAR =YEAR(Import_Exam_DateTime)
                                           FROM tbl_Import_Exam WHERE  Import_examID=@IMPORT_EXAM_ID;

IF EXISTS (select 1 from tbl_Lookup_Measure en
                                 join tbl_Lookup_Measure_Extension e on en.Measure_ID = e.Measure_ID and en.Measure_num=@validMeasureNum and en.CMSYear=@CMSYEAR
                                 join tbl_Lookup_Measure_Extension_values m on e.Measure_Ext_Id = m.Measure_Ext_Id
                                 join tbl_Lookup_Active_Submission_Year y on en.CMSYear = y.Submission_Year and y.IsActive=1
                          )
BEGIN
    if ( ISNULL(@Import_Measure_Extension_Num,'') <> '')

		Begin			
			  
			   select @validMeasureExtNum = Other_Question_Num from tbl_Lookup_Measure_Extension
				where Other_Question_Num = @Import_Measure_Extension_Num and Measure_Id in (
					select top 1 Measure_ID from tbl_Lookup_Measure where Measure_num = @validMeasureNum			  
				)
			  
			  if  (ISNULL(@validMeasureExtNum,'') = '')
				Begin
					set @message = @message + 'P5002:Invalid Measure_Extension_Num:[ ' + ISNULL(@validMeasureExtNum,'') +'] entered for  Measure_Num [' + @validMeasureNum + '].' + CHAR(10) ;
					set @No_of_Errors = @No_of_Errors +1;
				End
			  Else 
				Begin
					select  @message = @message + 'P5004: Measure_Extension_Num must be unique. Measure_Extension_Num [' + ISNULL(@validMeasureExtNum,'') + '] is submitted multiple times in Measure_Num [' + ISNULL(@validMeasureNum,'')+ '].' + CHAR(10),
						@No_of_Errors = @No_of_Errors +1
						from tbl_Import_Measure_Data_Extension
						where Import_Measure_Data_ID = @Import_Measure_Data_ID and ISNULL(Import_Measure_Extension_Num,'') = ISNULL(@Import_Measure_Extension_Num,'') 
						group by Import_Measure_Data_ID,Import_Measure_Extension_Num
						having Count(Import_Measure_Extension_Num) > 1
				End
		End
	    
  
    
    if (@Import_Measure_Extension_Reponse_Code is null) or (ISNULL(@Import_Measure_Extension_Reponse_Code,'') = '')
		Begin
			set @message = @message + 'P5011:Missing Response_Value' + CHAR(10) ;
			set @No_of_Errors = @No_of_Errors +1;
		End
	Else
		Begin
			set @invalidCodes = ''
			select @invalidCodes = @invalidCodes + case @invalidCodes when '' then '' else ',' end + ltrim(rtrim(isnull(Item,''))) from dbo.Split_IgnoreParantheses(@Import_Measure_Extension_Reponse_Code,',')
			where ltrim(rtrim(isnull(Item,''))) not in (select ltrim(rtrim(isnull(Measure_Ext_Response_Code,''))) from  tbl_Lookup_Measure_Extension_values
						where Measure_Ext_Id in (
							select top 1 Measure_Ext_Id from tbl_Lookup_Measure_Extension where Other_Question_Num = 1
							and Measure_ID in (select top 1 Measure_ID from tbl_Lookup_Measure where Measure_num = (
							select top 1 Import_Measure_num from dbo.tbl_Import_Exam_Measure_Data where  Import_Exam_MeasureID = @Measure_Data_ID) )
						)
			)
			 if  (ISNULL(@invalidCodes,'') <> '')
			 Begin
			 set @message = @message + 'P5012:Invalid Response_Value [' + ISNULL(@invalidCodes,'') +']' + ' submitted in [' + ltrim(rtrim(isnull(@Import_Measure_Extension_Reponse_Code,''))) + '].' + CHAR(10) ;
			set @No_of_Errors = @No_of_Errors +1;
			 End
		End    
     
END    
    if (isnull(@message,'') <> '')
    Begin
    set @messageJSON = @message;
    set @message = 'P5013:Errors In Measure_Data_Extension ' + ISNULL(@Import_Measure_Extension_Num,'')+ ' under Measure_Num: ' + @validMeasureNum  + '. '+ CHAR(10) +  @message;
    
		update tbl_Import_Measure_Data_Extension set		
		Error_Codes_Desc =  @message
		,Error_Codes_JSON = @messageJSON
		,[Status] = 5 -- ValidationFailed		
		where  Import_Measure_Data_Ext_ID = @Import_Measure_Data_Ext_ID
		PRINT '-------- Exam Report --------';
		 Print @message;
		 PRINT '-------- End Report --------';
		 
    end
    else 
    Begin
    update tbl_Import_Measure_Data_Extension set		
		Error_Codes_Desc =  null
		,Error_Codes_JSON = null
		,[Status] = 3 -- successfull			
		where  Import_Measure_Data_Ext_ID = @Import_Measure_Data_Ext_ID
    end
   
    
    
    
    FETCH NEXT FROM Cursor_Imp_Mes_Data_Ext 
    INTO @Import_Measure_Data_Ext_ID,
	@Import_Measure_Data_ID,
	@Import_Measure_Extension_Num ,
	@Import_Measure_Extension_Reponse_Code 
END 
CLOSE Cursor_Imp_Mes_Data_Ext;
DEALLOCATE Cursor_Imp_Mes_Data_Ext;
	
END


