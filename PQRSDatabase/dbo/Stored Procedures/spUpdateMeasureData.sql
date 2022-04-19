-- =============================================
-- Author:		Prasanth
-- Create date: <Create Date,,>
-- Description:	UpdateMeasureData
--Change #1: Hari on 09/12/2018
--Change #1: added Criteria,Denominator_proc_code in where condition
--Change #2: updated Numerator_response_code in tbl_Exam_Measure_Data table
--Change#3: Hari j,May 3ed 2019
--Change3#: JIRA#694
--Change#4: JIRA#1103
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateMeasureData] 
	(@Exam_Id int,
        @Measure_Num varchar(50),
		@Denominator_proc_code varchar(50),
		@Denominator_Diag_code varchar(50),
		@Last_Mod_Date datetime,
		@Last_Mod_By varchar(50),
		@Numerator_response_value smallint,
		@Status int,
		@CMS_Submission_Year int,
		@Criteria varchar(20),
		@Numerator_response_code varchar(50)      --Change #2
	
		)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @measure_Id as int
	declare @exam_measure_id as int
	declare @Errors as varchar(250);

	DECLARE @Is_DiagCodeAsKey bit;
	DECLARE @Is_NumCodeAsKey bit;
	SET @Is_DiagCodeAsKey=0;
	set @Errors = '';
	set @measure_Id = 0;
	set @exam_measure_id = 0;
	----Change#4
	select @measure_Id= Measure_ID,@Is_DiagCodeAsKey=Is_DiagCodeAsKey,@Is_NumCodeAsKey = Is_NumCodeAsKey from tbl_Lookup_Measure m with(nolock) where  m.CMSYear = @CMS_Submission_Year and m.Measure_num = @Measure_Num
	if (@measure_Id > 0)
	Begin
		
		select @exam_measure_id = Exam_Measure_Id from tbl_Exam_Measure_Data with(nolock)
		where Exam_Id = @Exam_id 
		and Measure_ID = @measure_Id 
		and CMS_Submission_Year = @CMS_Submission_Year
		and isnull(Criteria,'NA')=isnull(@Criteria,'NA')--Change #1:
		and Denominator_proc_code=@Denominator_proc_code
	      and Denominator_Diag_code= case WHEN (@Is_DiagCodeAsKey=1) THEN @Denominator_Diag_code
	                                       ELSE Denominator_Diag_code END ----Change3#
	      and Numerator_Code= case WHEN (@Is_NumCodeAsKey=1) THEN @Numerator_response_code
	                                       ELSE @Numerator_response_code END ----Change#4
		if @exam_measure_id  > 0
			Begin
		
			update tbl_Exam_Measure_Data set 
			Denominator_proc_code=@Denominator_proc_code,
			Denominator_Diag_code=@Denominator_Diag_code,
			Last_Mod_Date=@Last_Mod_Date,
			Last_Mod_By=@Last_Mod_By,
			Numerator_response_value=@Numerator_response_value,
			[Status]=@Status,
			CMS_Submission_Year= @CMS_Submission_Year,
			Criteria=@Criteria,
			Numerator_Code=@Numerator_response_code                      --Change #2
			 where exam_measure_id = @exam_measure_id

			End
		Else 
			Begin
				insert into tbl_Exam_Measure_Data 
				(Exam_Id,Measure_ID,[Denominator_proc_code],[Denominator_Diag_code],[Numerator_response_value],[Status],[Created_Date],[Created_By],[Last_Mod_Date],[Last_Mod_By],[CMS_Submission_Year],Criteria)
				values
				(@Exam_Id,@measure_Id,@Denominator_proc_code,@Denominator_Diag_code,@Numerator_response_value,@Status,@Last_Mod_Date,@Last_Mod_By,@Last_Mod_Date,@Last_Mod_By,@CMS_Submission_Year,@Criteria)

				set @exam_measure_id = @@IDENTITY
		end
	
	End

	set nocount off
	select @exam_measure_id as [Exam_measure_id],@measure_Id as [Measure_id],@Measure_Num as [Measure_Num], @Errors as [Errors]
	return @@Rowcount

END


