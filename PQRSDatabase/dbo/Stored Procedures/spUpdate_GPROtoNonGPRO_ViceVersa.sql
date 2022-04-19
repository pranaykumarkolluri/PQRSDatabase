-- =============================================
-- Author:		<Hari>
-- Create date: <28-dec-17>
-- Description:	<update the GPRO to NonGPRO and ViceVersa in Nrdr and pqrs database>
-- status codes: 1: nrdr updates successfully
--status codes: 0: nrdr update failed
--status codes: 2: NO TIN INFORMATION FOUND IN NRDR DATABASE
--status codes: 3: GETTING ERROR WHILE UPDATING THE TIN IN PQRS DATABASE
--status codes: 4: PQRS updates successfully
--Change#1 By:Raju G
--Change#1: JIRA-785 
-- =============================================
CREATE PROCEDURE [dbo].[spUpdate_GPROtoNonGPRO_ViceVersa]
	-- Add the parameters for the stored procedure here
	@TIN varchar(9),
	@IS_GPRO bit,
	@CMSYear int,
	@userid varchar(50),
	@ErrorCode as int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	
	--SET NOCOUNT ON;
	
    -- SET @ErrorCode = 0 
	declare @Username Varchar(256);
	
		declare @SelectedId int;
		declare @GenSelectedId int;
	exec NRDR..spUpdate_GPROtoNonGPRO_ViceVersa @TIN,@IS_GPRO, @ErrorCode=@ErrorCode OUTPUT

	--set @ErrorCode=2 --for testing else block
	BEGIN TRY
	
	--set @ErrorCode=1/0; --for testing catch block
	if(@ErrorCode=1)
	begin
	--Step #1 update tbl_TIN_GPRO
		exec sp_getTIN_GPRO @TIN
	--IF EXISTS(SELECT TOP (1) * FROM tbl_TIN_GPRO WHERE TIN=@TIN)
 --    BEGIN

	--UPDATE tbl_TIN_GPRO with(TABLOCKX)
	--SET is_GPRO=@IS_GPRO
	--   WHERE TIN=@TIN

	--END
	--ELSE

	--BEGIN
	----INSERT INTO tbl_TIN_GPRO
	----VALUES(@TIN,@IS_GPRO)
	--exec sp_getTIN_GPRO @TIN
	--END

	--step #2 update tbl_Physician_TIN


	--Step #3 update tbl_TIN_GPRO_to_NonGPRO_ViceVersa
	IF EXISTS(SELECT TOP (1) * FROM tbl_TIN_GPRO_to_NonGPRO_ViceVersa WHERE TIN=@TIN and CMSYear=@CMSYear)
     BEGIN

	UPDATE tbl_TIN_GPRO_to_NonGPRO_ViceVersa with(TABLOCKX)
	SET [Moved_to_GPRO]=(case when @IS_GPRO=1 then 1 else 0 end),
	  [Moved_to_NonGPRO]=(case when @IS_GPRO=0 then 1 else 0 end),
       [Last_Mod_By]=@userid,
       [Last_Mod_Date]=GETDATE()
	   WHERE TIN=@TIN and CMSYear=@CMSYear

	END
	ELSE

	BEGIN
	INSERT INTO tbl_TIN_GPRO_to_NonGPRO_ViceVersa([CMSYear]
           ,[TIN]
           ,[is_GPRO]
           ,[Moved_to_GPRO]
           ,[Moved_to_NonGPRO]
           ,[Last_Mod_By]
           ,[Last_Mod_Date])
	VALUES(@CMSYear,@TIN,@IS_GPRO,
	case when @IS_GPRO=1 then 1 else 0 end,
	case when @IS_GPRO=0 then 0 else 1 end,
	@userid,
	GETDATE()
	)
	END
	
	--Step #4 update tbl_Physician_Selected_Measures 

	IF EXISTS(SELECT TOP (1) * FROM tbl_Physician_Selected_Measures WHERE TIN=@TIN and Submission_year=@CMSYear)
     BEGIN

	UPDATE tbl_Physician_Selected_Measures with(TABLOCKX)
	SET Is_Active=(case when @IS_GPRO=0 then 1 else 0 end),	
       [LastModifiedBy]=@userid
	   WHERE TIN=@TIN and Submission_year=@CMSYear

	END
	--Step #5 update tbl_GPRO_TIN_Selected_Measures

    IF EXISTS(SELECT TOP (1) * FROM tbl_GPRO_TIN_Selected_Measures WHERE TIN=@TIN and Submission_year=@CMSYear)
     BEGIN

	UPDATE tbl_GPRO_TIN_Selected_Measures with(TABLOCKX)
	SET Is_Active=(case when @IS_GPRO=1 then 1 else 0 end),	
       [LastModifiedBy]=@userid
	   WHERE TIN=@TIN and Submission_year=@CMSYear

	END

	IF EXISTS(SELECT TOP (1) * FROM tbl_Physician_Selected_Measures_90days WHERE TIN=@TIN and Submission_year=@CMSYear)
     BEGIN

	UPDATE tbl_Physician_Selected_Measures_90days with(TABLOCKX)
	SET Is_Active=(case when @IS_GPRO=0 then 1 else 0 end),	
       [LastModifiedBy]=@userid
	   WHERE TIN=@TIN and Submission_year=@CMSYear

	END


	IF EXISTS(SELECT TOP (1) * FROM tbl_GPRO_TIN_Selected_Measures_90days WHERE TIN=@TIN and Submission_year=@CMSYear)
     BEGIN

	UPDATE tbl_GPRO_TIN_Selected_Measures_90days with(TABLOCKX)
	SET Is_Active=(case when @IS_GPRO=1 then 1 else 0 end),	
       [LastModifiedBy]=@userid
	   WHERE TIN=@TIN and Submission_year=@CMSYear

	END
	

	---Step #6 we will update the Tin locking mechanism.
	UPDATE tbl_TINConvertion_Lock with(TABLOCKX)
	SET isIAFinalize=0,
	isACIFinalize=0,
	isQMFinalize=0,
	isLock=0
	   WHERE TIN=@TIN and CMSYear=@CMSYear


	---Step #7 we will update the Tin locking mechanism.

	UPDATE tbl_CMS_Finalization with(TABLOCKX)
	SET isFinalize=0,isGpro=@IS_GPRO
	   WHERE TIN=@TIN and Finalize_Year=@CMSYear


	   ---Step #8 we will update the Tin locking mechanism.

	UPDATE tbl_CMS_IA_Finalization with(TABLOCKX)
	SET isFinalize=0,isGpro=@IS_GPRO
	   WHERE TIN=@TIN and Finalize_Year=@CMSYear

	   ---Step #9 we will update the Tin locking mechanism.

	UPDATE tbl_CMS_ACI_Finalization with(TABLOCKX)
	SET isFinalize=0,isGpro=@IS_GPRO
	   WHERE TIN=@TIN and Finalize_Year=@CMSYear

	   --Step #10 Delete the ACI Measures Data while Converting the TIN NonGpro to Gpro


	   if(@IS_GPRO=1 and @CMSYear<2020)
	   begin
	   declare @SelectionIds table(sel_Id int)
	   insert into @SelectionIds
	   select Selected_Id from tbl_ACI_Users  where tin=@TIN and CMSYear=@CMSYear

	   delete from tbl_ACI_Users where Selected_Id in(select sel_Id from @SelectionIds)
	    delete from tbl_User_Selected_ACI_Measures where Selected_Id in(select sel_Id from @SelectionIds)
		end
		-- jira 785 started


								BEGIN TRY

									Begin Transaction

										if(@IS_GPRO=1 AND @CMSYear>=2020 )
										BEGIN   
										
										select @Username=UserName from tbl_Users where UserID=@userid
										   declare @PIMeasureList table(	
											Measure varchar(Max),
											StartDate datetime ,
											EndDate datetime,
											[Numerator] [int] NULL,
											[Denominator] [int] NULL,
											[Attestion] [bit] NULL
											)

											


									 IF((select COUNT(distinct ACI_Id)  from tbl_ACI_Users where  CMSYear=@CMSYear and TIN=@TIN ) >1)

									BEGIN
    
										  -- declare @SelectionIds table(sel_Id int)
										   delete from @SelectionIds
										   insert into @SelectionIds
										   select Selected_Id from tbl_ACI_Users  where tin=@TIN and CMSYear=@CMSYear

										   delete from tbl_ACI_Users where Selected_Id in(select sel_Id from @SelectionIds)
											delete from tbl_User_Selected_ACI_Measures where Selected_Id in(select sel_Id from @SelectionIds) 


									END
									ELSE
									BEGIN
		
															insert into @PIMeasureList
															select
																 B.Selected_MeasureIds,
																 Min(B.Start_Date) as Start_Date ,
																 Max(B.End_Date) as End_Date,
																 Min(B.Numerator) as Numerator,
																 Max(B.Denominator) as Denominator,
																 Convert(bit,
																  Max( Convert(int,B.Attestion)	)) as Attestion

																		  from tbl_ACI_Users A 
																				INNER JOIN 
																		   tbl_User_Selected_ACI_Measures B on A.Selected_Id=B.Selected_Id
																			and A.TIN=@TIN and A.NPI is not null and A.IsGpro=0 and B.CMSYear=@CMSYear
																			group by B.Selected_MeasureIds


									delete @PIMeasureList from @PIMeasureList aa  INNER JOIN tbl_User_Selected_ACI_Measures B on aa.Measure=b.Selected_MeasureIds
									join tbl_ACI_Users A on B.Selected_Id=A.Selected_Id
									 and A.TIN=@TIN and A.NPI is null and A.IsGpro=1  and a.CMSYear =@CMSYear


									select @SelectedId=Selected_Id from tbl_ACI_Users where TIN=@TIN and IsGpro=1 and CMSYear=@CMSYear

									IF(@SelectedId>0)
									BEGIN

											INSERT INTO [dbo].[tbl_User_Selected_ACI_Measures]
													   ([Selected_MeasureIds]
													   ,[Updated_By]
													   ,[Updated_Datetime]
													   ,[Start_Date]
													   ,[End_Date]
													   ,[Selected_Id]
													   ,[CMSYear]
													   ,[Numerator]
													   ,[Denominator]
													   ,[Attestion])

													   select Measure,	   
													   @Username,
													   GETDATE(),
													   StartDate,
													   EndDate,
														@SelectedId  ,
													   @CMSYear,
													   Numerator,
													   Denominator,
													   Attestion
														from @PIMeasureList

									END
									ELSE 
									BEGIN
      
											INSERT INTO [dbo].[tbl_ACI_User_Measure_Type]
													   ([ACI_Id]
													   ,[Updated_By]
													   ,[Updated_Datetime])
												 VALUES
													   (1,          
														@Username,
													   GETDate())

													   set @GenSelectedId=SCOPE_IDENTITY()

		   
											INSERT INTO [dbo].[tbl_User_Selected_ACI_Measures]
													   ([Selected_MeasureIds]
													   ,[Updated_By]
													   ,[Updated_Datetime]
													   ,[Start_Date]
													   ,[End_Date]
													   ,[Selected_Id]
													   ,[CMSYear]
													   ,[Numerator]
													   ,[Denominator]
													   ,[Attestion])

													   select Measure,	   
													   @Username,
													   GETDATE(),
													   StartDate,
													   EndDate,
														@GenSelectedId  ,
													   @CMSYear,
													   Numerator,
													   Denominator,
													   Attestion
														from @PIMeasureList

												INSERT INTO [dbo].[tbl_ACI_Users]
													   ([Selected_Id]
													   ,[ACI_Id]
													   ,[IsGpro]
													   ,[TIN]
           
													   ,[Updated_By]
													   ,[Updated_Datetime]
													   ,[CMSYear])

													   select @GenSelectedId,
													   1,
													   1,
													   @TIN,
													   @Username,
													   GETDate(),
													   @CMSYear

									END

									END


									END
									Commit Transaction
									END TRY
									BEGIN CATCH

									Rollback Transaction
							END CATCH



		-- jira 785 ended
		
--JIRA 798 code commented.
/*		
	if(@IS_GPRO=1 AND @CMSYear>=2020 )
	BEGIN   
	set @SelectedId=0;
	set @GenSelectedId=0;
	select @Username=UserName from tbl_Users where UserID=@userid
	   declare @ActivitiesList table(	
		Activity varchar(256),
		StartDate datetime ,
		EndDate datetime
		)


		insert into @ActivitiesList
select B.SelectedActivity,Min(B.StartDate) as StartDate,Max(B.EndDate) as EndDate from tbl_IA_Users A INNER JOIN tbl_IA_User_Selected B on A.SelectedID=B.SelectedID
where A.TIN=@TIN and A.NPI is not null and A.IsGpro=0
group by B.SelectedActivity


delete @ActivitiesList from @ActivitiesList aa  INNER JOIN tbl_IA_User_Selected B on aa.Activity=b.SelectedActivity
join tbl_IA_Users A on B.SelectedID=A.SelectedID
 where A.TIN=@TIN and A.NPI is null and A.IsGpro=1


select @SelectedId=SelectedID from tbl_IA_Users where TIN=@TIN and NPI is null

IF(@SelectedId>0)
BEGIN
INSERT INTO [dbo].[tbl_IA_User_Selected]
           ([SelectedID]
           ,[SelectedActivity]
           ,[StartDate]
           ,[EndDate]
           ,[UpdatedBy]
           ,[UpdatedDateTime]
           ,[CMSYear])
		   select @SelectedId,	   
		   Activity,
		   StartDate,
		   EndDate,
		   @Username,
		   GETDate(),
		   @CMSYear
		    from @ActivitiesList

END
ELSE 
BEGIN
      
INSERT INTO [dbo].[tbl_IA_User_Selected_Categories]
           ([Activity]
           ,[ActivityWeighing]
           ,[UpdatedBy]
           ,[UpdatedDateTime]
           ,[CMSYear])
     VALUES
           (NULL,
           NULL,
            @Username,
		   GETDate(),
           @CMSYear)

		   set @GenSelectedId=SCOPE_IDENTITY()

		   
INSERT INTO [dbo].[tbl_IA_User_Selected]
           ([SelectedID]
           ,[SelectedActivity]
           ,[StartDate]
           ,[EndDate]
           ,[UpdatedBy]
           ,[UpdatedDateTime]
           ,[CMSYear])
     select @GenSelectedId,	   
		   Activity,
		   StartDate,
		   EndDate,
		   @Username,
		   GETDate(),
		   @CMSYear
		    from @ActivitiesList

			INSERT INTO [dbo].[tbl_IA_Users]
           ([SelectedID]
           ,[IsGpro]
           ,[NPI]
           ,[TIN]
           ,[Updatedby]
           ,[UpdatedDateTime]
           ,[CMSYear])

		   select @GenSelectedId,
		   1,
		   NULL,
		   @TIN,
		   @Username,
		   GETDate(),
		   @CMSYear

			END
			
END

*/

	SELECT @ErrorCode=4-- Convertion successfully
	end --if(@ErrorCode=1)

	
	else 
	begin
	--@ErrorCode=2 NO TIN INFORMATION FOUND IN NRDR DATABASE
	--@ErrorCode=0 GETTING ERROR WHILE UPDATING THE TIN IN NRDR DATABASE
	SET @ErrorCode=@ErrorCode
	
	end

	END TRY
	--ERROR CODE
	BEGIN CATCH
	SELECT @ErrorCode=3-- GETTING ERROR WHILE UPDATING THE TIN IN PQRS DATABASE
	END CATCH
	
	

SELECT @ErrorCode 
	


    
END

