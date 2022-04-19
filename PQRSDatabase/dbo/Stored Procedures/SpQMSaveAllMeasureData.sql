-- =============================================
-- Author:		Raju G
-- Create date: 4/13/2019
-- Description: used for save all	tin and tin/npi relatead measure data 
-- =============================================
CREATE PROCEDURE [dbo].[SpQMSaveAllMeasureData] 

@TIN varchar(9),
@NPI varchar(10),
@IS_GPRO bit,
@IS_90Days bit,
@CMSYear int,
@UserId int,
@tbl_MeasureRelatedData_Type tbl_MeasureRelatedData_Type READONLY
AS
BEGIN
--if  exists (select * from sys.objects  where type='U' and name='tbl_MeasureRelatedData_Type_temp')
--begin


--drop table tbl_MeasureRelatedData_Type_temp


--end
--select * into tbl_MeasureRelatedData_Type_temp from @tbl_MeasureRelatedData_Type

declare	@SelectedforCMS_Chk varchar(10),
@measure_name varchar(50),

@HundredPercent_Chk_val varchar(10),
@HundredPercent_Chk_2_val varchar(10) ,
@HundredPercent_txt_val varchar(10) ,
@HundredPercent_txt_2_ele varchar(10) ,
@EndtoEndReporting_Chk_val varchar(10);

declare	@SelectedforCMS bit,
@HundredPercent bit,
@HundredPercent_2  bit,
@ExamsCount int ,
@ExamsCount2 int ,
@EndtoEndReporting bit,
@Qmeasure varchar(50),
@physician_id int;

declare @ErrorTable table(Tin varchar(9),Npi varchar(10),MeasureNum varchar(50),CMSYear int,is90days bit, ErrorMessage varchar(max))

DECLARE    MeasureData CURSOR FOR

select 
measure_name
,SelectedforCMS_Chk
,HundredPercent_Chk_val
,HundredPercent_Chk_2_val
,HundredPercent_txt_val
,HundredPercent_txt_2_ele
,EndtoEndReporting_Chk_val
 from @tbl_MeasureRelatedData_Type

OPEN MeasureData

FETCH NEXT FROM  MeasureData INTO @measure_name,@SelectedforCMS_Chk, @HundredPercent_Chk_val ,@HundredPercent_Chk_2_val  ,@HundredPercent_txt_val  ,@HundredPercent_txt_2_ele  ,@EndtoEndReporting_Chk_val 

  WHILE @@FETCH_STATUS = 0
  BEGIN
 -- insert into temp_raju values('measure num['+@measure_name+'] tin['+@TIN+'] started isgpro['+cast(@IS_GPRO as varchar(50))+'] IS90days['+cast(@IS_90Days as varchar(50))+'] ');
	SET	@SelectedforCMS =CASE WHEN @SelectedforCMS_Chk='1' THEN 1
														  WHEN @SelectedforCMS_Chk='0' THEN 0
														  ELSE NULL
														  END;
SET @HundredPercent =CASE WHEN @HundredPercent_Chk_val='1' THEN 1
														  WHEN @HundredPercent_Chk_val='0' THEN 0
														  ELSE NULL
														  END;
SET @HundredPercent_2 =CASE WHEN @HundredPercent_Chk_2_val='1' THEN 1
														  WHEN @HundredPercent_Chk_2_val='0' THEN 0
														  ELSE NULL
														  END;
SET @ExamsCount = CAST(@HundredPercent_txt_val AS INT);
SET @ExamsCount2  = CAST(@HundredPercent_txt_2_ele AS INT);
SET @EndtoEndReporting =CASE WHEN @EndtoEndReporting_Chk_val='1' THEN 1
														  WHEN @EndtoEndReporting_Chk_val='0' THEN 0
														  ELSE NULL
														  END;
  --STEP#1 :CHECK GPRO/NON GPRO 
		BEGIN TRY
		BEGIN TRANSACTION
        IF(@IS_GPRO=1)
		BEGIN
	
		--GPR0
		   --  --STEP#2 : CHECKING IS 90 DAYS OR NOT
				IF(@IS_90Days=1)
				BEGIN
				 --  --STEP#2 : IF MEASURE DATA EXISTS NEED TO UPDATE OTHERWISE NEED TO INSERT
					 if exists(select 1 from tbl_GPRO_TIN_Selected_Measures_90days where Submission_year=@CMSYear
												 and Measure_num=@measure_name
												  and TIN=@Tin)
						 BEGIN
							  	UPDATE tbl_GPRO_TIN_Selected_Measures_90days
								SET 
								TotalCasesReviewed  =@ExamsCount,
								HundredPercentSubmit=@HundredPercent ,
								SelectedForSubmission= @SelectedforCMS,
								isEndToEndReported=@EndtoEndReporting,
								Is_Active			  =	 1 ,
								DateLastSelected      = CASE WHEN @SelectedforCMS_Chk='1' THEN GETDATE() ELSE DateLastSelected END ,
								DateLastUnSelected    = CASE WHEN @SelectedforCMS_Chk='0' THEN GETDATE() ELSE DateLastUnSelected END,
								LastModifiedBy	      = CAST(@UserId as varchar(50))
								WHERE 
										Submission_year=@CMSYear
										and TIN=@Tin
									    and Measure_num=@measure_name
		    
						 END
						 ELSE
						 BEGIN
								INSERT INTO [dbo].[tbl_GPRO_TIN_Selected_Measures_90days]
							    ([Measure_num]
							   ,[Submission_year]
							   ,[TIN]
							   ,[SelectedForSubmission]
							   ,[TotalCasesReviewed]
							   ,[HundredPercentSubmit]
							   ,[DateLastSelected]
							   --,[DateLastUnSelected]
							   ,[LastModifiedBy]
							   ,[Is_Active]
							   ,[Is_90Days]
							  -- ,[UpDatedFrom]
							   ,[isEndToEndReported]
							  -- ,[TotalCasesReviewed_C2]
							   --,[HundredPercentSubmit_C2]
							   )
						 VALUES
							   (
							   @measure_name   
							   ,@CMSYear				
							   ,@Tin
							   ,@SelectedforCMS  
							   ,@ExamsCount  
							   ,@HundredPercent   
							   ,GETDATE()
							 --  ,<DateLastUnSelected, datetime,>
							   ,Cast(@UserId as varchar(50))
							   ,1--<Is_Active, bit,>
							   ,@IS_90Days
							  -- ,<UpDatedFrom, varchar(50),>
							   ,@EndtoEndReporting 
							   --<TotalCasesReviewed_C2, int,>
							  -- ,<HundredPercentSubmit_C2, bit,>
							  )
						 END
				   
				   --STEP#3 AFTER INSERT/UPDATE DONE NEED TO DO PERFORMANCE CAL FOR MEASUIRE WHEN SELECFORCMSSUBMISION=1
				       if(@SelectedforCMS=1)
					   BEGIN
				       EXEC spReCalculateTINperformanceRateFor90DaysandMeasureID @measure_name,@CMSYear,@TIN,1
					   END
				END
				ELSE
				BEGIN
				 --full year
						 if exists(select 1 from tbl_GPRO_TIN_Selected_Measures where Submission_year=@CMSYear
												 and Measure_num=@measure_name
												  and TIN=@Tin)
						 BEGIN
--  insert into temp_raju values('updating-->measure num['+@measure_name+'] started isgpro['+cast(@IS_GPRO as varchar(50))+'] IS90days['+cast(@IS_90Days as varchar(50))+'] ');

							  	UPDATE tbl_GPRO_TIN_Selected_Measures
								SET 
								TotalCasesReviewed  =@ExamsCount,
								HundredPercentSubmit=@HundredPercent ,
								SelectedForSubmission= @SelectedforCMS,
								isEndToEndReported=@EndtoEndReporting,
								TotalCasesReviewed_C2=@ExamsCount2,
								HundredPercentSubmit_C2=@HundredPercent_2,

								Is_Active			  =	 1 ,
								DateLastSelected      = CASE WHEN @SelectedforCMS_Chk='1' THEN GETDATE() ELSE DateLastSelected END ,
								DateLastUnSelected    = CASE WHEN @SelectedforCMS_Chk='0' THEN GETDATE() ELSE DateLastUnSelected END,
								LastModifiedBy	      = CAST(@UserId as varchar(50))
								WHERE 
										Submission_year=@CMSYear
										and TIN=@Tin
									    and Measure_num=@measure_name	
							--insert into temp_raju values(@measure_name);
					
--  insert into temp_raju values('updated-->measure num['+@measure_name+'] started isgpro['+cast(@IS_GPRO as varchar(50))+'] IS90days['+cast(@IS_90Days as varchar(50))+'] ');

						 END
						 ELSE
						 BEGIN
--insert into temp_raju values('inserting-->measure num['+@measure_name+'] started isgpro['+cast(@IS_GPRO as varchar(50))+'] IS90days['+cast(@IS_90Days as varchar(50))+'] ');

								INSERT INTO [dbo].[tbl_GPRO_TIN_Selected_Measures]
							    ([Measure_num]
							   ,[Submission_year]
							   ,[TIN]
							   ,[SelectedForSubmission]
							   ,[TotalCasesReviewed]
							   ,[HundredPercentSubmit]
							   ,[DateLastSelected]
							   --,[DateLastUnSelected]
							   ,[LastModifiedBy]
							   ,[Is_Active]
							   ,[Is_90Days]
							  -- ,[UpDatedFrom]
							   ,[isEndToEndReported]
							   ,[TotalCasesReviewed_C2]
							   ,[HundredPercentSubmit_C2]
							   )
						 VALUES
							   (
							   @measure_name   
							   ,@CMSYear				
							   ,@Tin
							   ,@SelectedforCMS  
							   ,@ExamsCount  
							   ,@HundredPercent   
							   ,GETDATE()
							 --  ,<DateLastUnSelected, datetime,>
							   ,Cast(@UserId as varchar(50))
							   ,1--<Is_Active, bit,>
							   ,@IS_90Days
							  -- ,<UpDatedFrom, varchar(50),>
							   ,@EndtoEndReporting 
							   ,@ExamsCount2--<TotalCasesReviewed_C2, int,>
							   ,@HundredPercent_2-- ,<HundredPercentSubmit_C2, bit,>
							  )
						 END
--insert into temp_raju values('inserted-->measure num['+@measure_name+'] started isgpro['+cast(@IS_GPRO as varchar(50))+'] IS90days['+cast(@IS_90Days as varchar(50))+'] ');

							if(@SelectedforCMS=1)
							BEGIN
							 SET @Qmeasure=	CASE when UPPER(SUBSTRING(@measure_name,1,1))='Q' Then right(@measure_name,len(@measure_name)-1) ELSE @measure_name End 
							  
							  if (UPPER(SUBSTRING(@measure_name,1,1))='Q')
							  Begin
							   UPdate tbl_GPRO_TIN_Selected_Measures
							   SET
							   SelectedForSubmission=0
							   WHERE Submission_year=@CMSYear AND TIN=@TIN AND Measure_num=@Qmeasure   AND  SelectedForSubmission=1
							  end
							END

					   IF(@SelectedforCMS=1)
					   BEGIN
				            EXEC spReCalculateTINperformanceRateForYearandMeasureID @measure_name,@CMSYear,@TIN,0
					   END
				END
		END
		ELSE
		BEGIN
		   --STEP#4  NON GPRO
			--  --STEP#5 : CHECKING IS 90DAYS OR NOT
			    select @physician_id =UserID from tbl_Users where NPI=@NPI
				IF(@IS_90Days=1)
				BEGIN
							 if exists(select 1 from tbl_Physician_Selected_Measures_90days where Submission_year=@CMSYear
												 and TIN=@Tin
												 and NPI=@NPI
												 and Measure_num_ID=@measure_name
												  )
						 BEGIN
					--	  insert into temp_raju values('updating-->measure num['+@measure_name+'] started isgpro['+cast(@IS_GPRO as varchar(50))+'] IS90days['+cast(@IS_90Days as varchar(50))+'] ');

							  	UPDATE tbl_Physician_Selected_Measures_90days
								SET 
								TotalCasesReviewed  =@ExamsCount,
								HundredPercentSubmit=@HundredPercent ,
								SelectedForSubmission= @SelectedforCMS,
								isEndToEndReported=@EndtoEndReporting,
							
								Is_Active			  =	 1 ,
								DateLastSelected      = CASE WHEN @SelectedforCMS_Chk='1' THEN GETDATE() ELSE DateLastSelected END ,
								DateLastUnSelected    = CASE WHEN @SelectedforCMS_Chk='0' THEN GETDATE() ELSE DateLastUnSelected END,
								LastModifiedBy	      = CAST(@UserId as varchar(50))
								WHERE 
										Submission_year=@CMSYear
										and TIN=@Tin
										and NPI=@NPI
										and Measure_num_ID=@measure_name		
		    
						 END
						 ELSE
						 BEGIN
								INSERT INTO [dbo].[tbl_Physician_Selected_Measures_90days]
									   ([NPI]
									   ,[Physician_ID]
									   ,[Measure_num_ID]
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
									  -- ,[UpDatedFrom]
									   ,[isEndToEndReported]
									   --,[TotalCasesReviewed_C2]
									   --,[HundredPercentSubmit_C2]
									   )
								 VALUES
									   (
										@NPI
									   ,@physician_id
									   ,@measure_name   --<Measure_num_ID, varchar(50),>
									   ,@CMSYear
									   ,@TIN
									   ,@SelectedforCMS
									   ,@ExamsCount
									   ,@HundredPercent
									   ,GETDATE()
									  -- ,<DateLastUnSelected, datetime,>
									   ,cast(@UserId as int)
									   ,1
									   ,@IS_90Days
									 --  ,<UpDatedFrom, varchar(50),>
									   ,@EndtoEndReporting
									   --,<TotalCasesReviewed_C2, int,>
									   --,<HundredPercentSubmit_C2, bit,>
									   )
							END
						IF(@SelectedforCMS=1)
						BEGIN
						EXEC spReCalculatePerfomanceRateFor90DaysandMeasureID @measure_name,@TIN,@CMSYear,1,@NPI
						END
				END
				ELSE 
				BEGIN
					  if exists(select 1 from tbl_Physician_Selected_Measures where Submission_year=@CMSYear
												 and TIN=@Tin
												 and NPI=@NPI
												 and Measure_num_ID=@measure_name
												  )
						 BEGIN
							  	UPDATE tbl_Physician_Selected_Measures
								SET 
								TotalCasesReviewed  =@ExamsCount,
								HundredPercentSubmit=@HundredPercent ,
								SelectedForSubmission= @SelectedforCMS,
								isEndToEndReported=@EndtoEndReporting,
								TotalCasesReviewed_C2=@ExamsCount2,
								@HundredPercent_2=@HundredPercent_2,
								Is_Active			  =	 1 ,
								DateLastSelected      = CASE WHEN @SelectedforCMS_Chk='1' THEN GETDATE() ELSE DateLastSelected END ,
								DateLastUnSelected    = CASE WHEN @SelectedforCMS_Chk='0' THEN GETDATE() ELSE DateLastUnSelected END,
								LastModifiedBy	      = CAST(@UserId as varchar(50))
								WHERE 
										Submission_year=@CMSYear
										and TIN=@Tin
										and NPI=@NPI
										and Measure_num_ID=@measure_name
									
						 		
		    
						 END
						 ELSE
						 BEGIN
								INSERT INTO [dbo].[tbl_Physician_Selected_Measures]
									   ([NPI]
									   ,[Physician_ID]
									   ,[Measure_num_ID]
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
									  -- ,[UpDatedFrom]
									   ,[isEndToEndReported]
									   ,[TotalCasesReviewed_C2]
									   ,[HundredPercentSubmit_C2]
									  
									   )
								 VALUES
									   (
										@NPI
									   ,@physician_id
									   ,@measure_name   --<Measure_num_ID, varchar(50),>
									   ,@CMSYear
									   ,@TIN
									   ,@SelectedforCMS
									   ,@ExamsCount
									   ,@HundredPercent
									   ,GETDATE()
									  -- ,<DateLastUnSelected, datetime,>
									   ,cast(@UserId as int)
									   ,1
									   ,@IS_90Days
									 --  ,<UpDatedFrom, varchar(50),>
									   ,@EndtoEndReporting,
									 @ExamsCount2,
									 @HundredPercent_2
									
									   )
							END

								if(@SelectedforCMS=1)
							BEGIN		
								SET @Qmeasure=	CASE when UPPER(SUBSTRING(@measure_name,1,1))='Q' Then right(@measure_name,len(@measure_name)-1) ELSE @measure_name End 
							  if (UPPER(SUBSTRING(@measure_name,1,1))='Q')
							  Begin
							   UPdate tbl_Physician_Selected_Measures
							   SET
							   SelectedForSubmission=0
							   WHERE Submission_year=@CMSYear AND TIN=@TIN AND NPI=@NPI  AND Measure_num_ID=@Qmeasure   AND  SelectedForSubmission=1
							 End
							END  

							IF(@SelectedforCMS=1)
							BEGIN
							EXEC spReCalculatePerfomanceRateForYearandMeasureID @measure_name,@TIN,@CMSYear,0,@NPI
							END
							
				END
		  --STEP#7 : CHECKING IS 90DAYS OR NOT	  

		END


	
		COMMIT TRANSACTION
		 

		 
	 END TRY
	 BEGIN CATCH

	--   insert into temp_raju values('measure num['+@measure_name+'] started isgpro['+cast(@IS_GPRO as varchar(50))+'] IS90days['+cast(@IS_90Days as varchar(50))+'] error['+ERROR_MESSAGE()+'] ');

	    ROLLBACK TRANSACTION
		  INSERT INTO @ErrorTable
		 (CMSYear,
		 Tin,
		 MeasureNum,
		 is90days,
		 Npi,
		 ErrorMessage
		 )
		 VALUES
		 (
		 @CMSYear,
		 @TIN,
		 @measure_name,
		 @IS_90Days,
		 @NPI,
		 ERROR_MESSAGE()
		 )
	 END CATCH


FETCH NEXT FROM  MeasureData INTO @measure_name,@SelectedforCMS_Chk, @HundredPercent_Chk_val ,@HundredPercent_Chk_2_val  ,@HundredPercent_txt_val  ,@HundredPercent_txt_2_ele  ,@EndtoEndReporting_Chk_val 
  END
    CLOSE MeasureData;
  DEALLOCATE MeasureData;
SELECT  CMSYear,Tin,Npi,MeasureNum,ErrorMessage FROM @ErrorTable
END
