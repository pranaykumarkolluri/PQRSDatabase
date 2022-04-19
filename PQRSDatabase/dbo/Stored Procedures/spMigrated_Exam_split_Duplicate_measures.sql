

CREATE PROCEDURE [dbo].[spMigrated_Exam_split_Duplicate_measures]
	
	@tbl_Exam_ExamID int,
	@Import_examID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	if exists(
SELECT Exam_Id,Measure_ID FROM dbo.tbl_Exam_Measure_Data WHERE Exam_Id = @tbl_Exam_ExamID
group by Exam_Id,Measure_ID having COUNT(*) >1 )
Begin

	
 declare @total int
 DECLARE @intFlag INT
 declare @intNew_ExamID int;

IF OBJECT_ID('tempdb..#measures') IS NOT NULL DROP TABLE #measures
CREATE table #measures (measid int not null);
IF OBJECT_ID('tempdb..#measures_Initial') IS NOT NULL DROP TABLE #measures_Initial
CREATE table #measures_Initial (measid int not null);

insert into #measures_Initial
select Exam_Measure_Id from tbl_Exam_Measure_Data where  Exam_Id= @tbl_Exam_ExamID;

select @total = COUNT(*) from tbl_Exam_Measure_Data where  Exam_Id = @tbl_Exam_ExamID;

--select * from #measures_Initial;

-- Now leave First Unique set as it is to @tbl_Exam_ExamID
		insert into #measures
		select A.Exam_Measure_Id from tbl_Exam_Measure_Data A
		where A.Exam_Measure_Id = (select min(B.Exam_Measure_Id)
		from tbl_Exam_Measure_Data B where b.Measure_ID = a.Measure_ID
		--and B.Exam_Id = A.Exam_Id and A.Exam_Id = @tbl_Exam_ExamID
		and B.Exam_Measure_Id in (select measid from #measures_Initial)
		and B.Exam_Measure_Id not in ( select measid from #measures)
		);
--select *, 'first step' as [first] from #measures		
	
-- Now transfer rest to another examid 
SET @intFlag = 1
WHILE (@intFlag <= @total)
	BEGIN
		--1) Generate a exam id	
		
		if exists (select A.Exam_Measure_Id from tbl_Exam_Measure_Data A
		where A.Exam_Measure_Id = (select min(B.Exam_Measure_Id)
		from tbl_Exam_Measure_Data B where b.Measure_ID = a.Measure_ID
		--and B.Exam_Id = A.Exam_Id and A.Exam_Id = @tbl_Exam_ExamID
		and B.Exam_Measure_Id in (select measid from #measures_Initial)
		and B.Exam_Measure_Id not in ( select measid from #measures)
		))
		Begin
		
			--select *, 'step' + CONVERT(varchar(20),@intFlag) as [first] from #measures	
			INSERT INTO [dbo].[tbl_Exam]
			   ([Physician_NPI]
			   ,[Exam_TIN]
			   ,[Patient_ID]
			   ,[Patient_Age]
			   ,[Patient_Gender]
			   ,[Patient_Medicare_Beneficiary]
			   ,[Patient_Medicare_Advantage]
			   ,[Exam_Date]
			   ,[Created_Date]
			   ,[Created_By]
			   ,[Last_Modified_Date]
			   ,[Last_Modified_By]
			   ,[Facility_ID]
			   ,[Exam_Unique_ID]
			   ,[PartnerID]
			   ,[AppID]
			   ,[Transaction_ID]
			   ,[DataSource_Id]
			   ,[CMS_Submission_Year])
			   SELECT [Physician_NPI]
		  ,[Exam_TIN]
		  ,[Patient_ID]
		  ,[Patient_Age]
		  ,[Patient_Gender]
		  ,[Patient_Medicare_Beneficiary]
		  ,[Patient_Medicare_Advantage]
		  ,[Exam_Date]
		  ,[Created_Date]
		  ,[Created_By]
		  ,[Last_Modified_Date]
		  ,[Last_Modified_By]
		  ,[Facility_ID]
		  ,[Exam_Unique_ID]
		  ,[PartnerID]
		  ,[AppID]
		  ,[Transaction_ID]
		  ,[DataSource_Id]
		  ,[CMS_Submission_Year]
	  FROM [dbo].[tbl_Exam] where [Exam_Id] = @tbl_Exam_ExamID;
	
	--declare   
	 -- insert into 
			set @intNew_ExamID = 0;
			set @intNew_ExamID = @@IDENTITY;
			update A 
			set 
			A.Exam_Id = @intNew_ExamID
			--select A.Exam_Measure_Id
			 from tbl_Exam_Measure_Data A
			where A.Exam_Measure_Id = (select min(B.Exam_Measure_Id)
			from tbl_Exam_Measure_Data B where b.Measure_ID = a.Measure_ID
			--and B.Exam_Id = A.Exam_Id and A.Exam_Id = @tbl_Exam_ExamID
			and B.Exam_Measure_Id in (select measid from #measures_Initial)
			and B.Exam_Measure_Id not in ( select measid from #measures)
			);
			
			 INSERT INTO [dbo].[tbl_Exam_MultiMeasures_SplitMap]
			   ([MasterExamId],[ChildExamid])
			   values
			  (@tbl_Exam_ExamID,@intNew_ExamID);
		
				insert into #measures
		select A.Exam_Measure_Id from tbl_Exam_Measure_Data A
		where A.Exam_Measure_Id = (select min(B.Exam_Measure_Id)
		from tbl_Exam_Measure_Data B where b.Measure_ID = a.Measure_ID
		--and B.Exam_Id = A.Exam_Id and A.Exam_Id = @tbl_Exam_ExamID
		and B.Exam_Measure_Id in (select measid from #measures_Initial)
		and B.Exam_Measure_Id not in ( select measid from #measures)
		);
		
		End -- still exists
		
		if exists(select 1 from #measures)
		Begin
		--select @intFlag = COUNT(*) from #measures
		select @intFlag =  @intFlag  + 1
		PRINT @intFlag
		end
		else
		Begin
		select @intFlag =  @intFlag  + 1
		End
	END

END-- Count(*) > 1
--else 
--Begin
--    print 'hello world'
--End

End 
