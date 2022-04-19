-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date:  unknown - modified 26th sept 2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_Physian_Tin_Count] 
	-- Add the parameters for the stored procedure here
	 @strPhysicianNPI varchar(50) = '', 
	 @Tin varchar(50) = '',
	@intYear int = 0
AS
BEGIN
	
	    DECLARE @strCurNPI AS VARCHAR(10)
        DECLARE @strCurTIN AS VARCHAR(10)
		DECLARE @intCurActiveYear AS INT
		DECLARE @TOTALPHYSIANTINCOUNT AS INT
		DECLARE @Username varchar(50)
		DECLARE	@Firstname varchar(50)
		DECLARE @Lastname varchar(50)
		DECLARE @UserId int
		Declare @intCurCMSSubYear as int


		DECLARE CurSubmission_Year CURSOR FOR 
		SELECT Submission_Year FROM tbl_Lookup_Active_Submission_Year 
		WHERE IsActive = 1
		AND  [Submission_year] = (CASE ISNULL(@intYear,0) 
									   WHEN 0 THEN [Submission_year] 
								  ELSE  ISNULL(@intYear,0)
								  END
        )

        ORDER BY submission_year

		OPEN CurSubmission_Year

	    FETCH NEXT FROM CurSubmission_Year INTO @intCurActiveYear
        WHILE @@FETCH_STATUS = 0 

			Begin
			-- Now get  data from tbl_exam for year

			   DECLARE  CurNPI_and_TINS_and_Year CURSOR FOR 
			  select distinct Physician_NPI, Exam_TIN ,CMS_Submission_Year 
			  from tbl_Exam readonly with(nolock) 
			  where CMS_Submission_Year = @intCurActiveYear
              order by Physician_NPI,Exam_TIN,CMS_Submission_Year

			  OPEN CurNPI_and_TINS_and_Year

			   FETCH NEXT FROM CurNPI_and_TINS_and_Year 
			   INTO @strCurNPI,@strCurTIN,@intCurCMSSubYear

			   WHILE @@FETCH_STATUS = 0

			    BEGIN

				        DELETE   FROM   tbl_Physian_Tin_Count 
                        WHERE    NPI = @strCurNPI 
				                 AND TIN = @strCurTIN 
				                 AND CMS_Year = @intCurActiveYear

				  SELECT @Username = UserName,
				         @Firstname = FirstName,
						 @Lastname = LastName,
						 @UserId = UserID
				  FROM tbl_Users where NPI = @strCurNPI

				  -- now query and update table
				  set @TOTALPHYSIANTINCOUNT = 0;
				 SELECT  @TOTALPHYSIANTINCOUNT = COUNT(*) 
				 FROM    tbl_Exam 
                 WHERE   Physician_NPI = @strCurNPI 
				 AND     Exam_TIN = @strCurTIN 
				 AND     CMS_Submission_Year = @intCurActiveYear


				 if @TOTALPHYSIANTINCOUNT > 0
				 Begin

					  IF EXISTS 
					  (
				  
						  SELECT top 1 npi 
						  FROM   tbl_Physian_Tin_Count readonly with(nolock) 
						  WHERE  NPI = @strCurNPI 
								 AND TIN = @strCurTIN 
								 AND CMS_Year = @intCurActiveYear
					  )
						  BEGIN
						   print 'UPDATE  for NPI: ' + @strCurNPI + ' TIN: ' +  @strCurTIN 

							 UPDATE tbl_Physian_Tin_Count
							 SET    TotalCount = @TOTALPHYSIANTINCOUNT
							 WHERE  NPI = @strCurNPI 
									AND TIN = @strCurTIN 
									AND CMS_Year = @intCurActiveYear 
				    
				    
						  END 

					 ELSE

					  BEGIN

					  	print 'else for NPI: ' + @strCurNPI + ' TIN: ' +  @strCurTIN 
							  Insert into tbl_Physian_Tin_Count 
							  (
								 NPI,
								 TIN,
								 DATE_UPDATED,
								 CMS_Year,
								 TotalCount,
								 UserName,
								 FirstName,
								 LastName,
								 UserId
				  
							  )

							  values
							  (
								 @strCurNPI,
								 @strCurTIN,
								 GETDATE(),
								 @intCurActiveYear,
								 @TOTALPHYSIANTINCOUNT,
								 @Username,
								 @Firstname,
								 @Lastname,
								 @UserId
							  )
				  
				       
				    
					  END -- else insert


				 End -- count > 0
				 ELSE 
				 BEGIN
					-- delete
					 DELETE FROM   tbl_Exam 
                     WHERE  Physician_NPI = @strCurNPI 
				             AND Exam_TIN = @strCurTIN 
				             AND CMS_Submission_Year = @intCurActiveYear
				 END
				 
				 FETCH NEXT FROM CurNPI_and_TINS_and_Year
				  INTO @strCurNPI,@strCurTIN,@intCurCMSSubYear
				End
				CLOSE CurNPI_and_TINS_and_Year
			DEALLOCATE CurNPI_and_TINS_and_Year


			   FETCH NEXT FROM CurSubmission_Year 	INTO @intCurActiveYear
			END -- CurSubmission_Year
			
			CLOSE CurSubmission_Year
			DEALLOCATE CurSubmission_Year

END
