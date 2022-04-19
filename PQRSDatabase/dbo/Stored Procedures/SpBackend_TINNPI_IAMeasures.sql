



-- =============================================
-- Author:		Raju
-- Create date: March 12th,2020
-- Description:JIRA#774:
---Before 2019, we were used 'SpBackend_NONGPROTIN_NPI_IA_Measures'
--Change#1: JIRA#914
-- =============================================
CREATE PROCEDURE [dbo].[SpBackend_TINNPI_IAMeasures] @CMSYear INT,
                                                    @UserName  VArchar(50)
 --@AttestedEmailAddress varchar (50)
AS
         BEGIN
             DECLARE @strCurTIN VARCHAR(10);
             DECLARE @strCurNPI VARCHAR(10);
			 DECLARE @Activity VARCHAR(50);
			 DECLARE @StartDate datetime;
			 DECLARE @EndDate datetime;
             DECLARE @ErrorCode AS INT;
             DECLARE @blnGPRO AS BIT;
             DECLARE @Selection_ID INT;
             DECLARE @SCOPEIDENTITY_Selection_ID AS INT;
             BEGIN TRY
                 BEGIN TRANSACTION;
                 DECLARE @tempIAActivities VARCHAR(MAX);
            
   -----------------TIN Cursor STARTS------------------------------


                 DECLARE CurTINs CURSOR
                 FOR

    --STEP #1: Getting Required TIN 
                     SELECT DISTINCT
                            TIN
                     FROM Tbl_Backend_TINNPI_IA WITH (NOLOCK)
                     WHERE CMSYear = @CMSYear and Npi is not null and Npi !='' and Is_Done=0;
                 OPEN CurTINs;
                 FETCH NEXT FROM CurTINs INTO @strCurTIN;
                 WHILE @@FETCH_STATUS = 0
                     BEGIN
                         PRINT 'IA:TIN Cursor Started with  TIN: '+CAST(@strCurTIN AS VARCHAR(10));

    --STEP #1.1: FIND Whether TIN GPRO or Not?
                         SET @blnGPRO = 0;			
							--Check tin gpro status
                         EXEC sp_getTIN_GPRO
                              @strCurTIN;
                        IF EXISTS( SELECT is_GPRO
    FROM tbl_TIN_GPRO
    WHERE TIN = @strCurTIN
          AND is_GPRO = 1)--Converting  GPRO to non GPRO
                             BEGIN
                                 EXEC spUpdate_GPROtoNonGPRO_ViceVersa
                                      @strCurTIN,
                                      0,
                                      @CMSYear,
                                      '',
                                      @ErrorCode = @ErrorCode OUTPUT;
                             END;
                         PRINT 'CODE IA:N 103 TIN Cursor Ends with  TIN: '+CAST(@strCurTIN AS VARCHAR(10));
                         FETCH NEXT FROM CurTINs INTO @strCurTIN;
     -----------------TIN Cursor END------------------------------
                     END;
                 CLOSE CurTINs;
                 DEALLOCATE CurTINs;


	
-----------------TIN,NPI------------------------------

                 SET @strCurTIN = '';
                 DECLARE CurTINNPIMeasures CURSOR
                 FOR

    --STEP #2: Getting Required TIN ,NPI,MeasureNumber data
                     SELECT DISTINCT
                            TIN,
                            NPI
                     FROM Tbl_Backend_TINNPI_IA WITH (NOLOCK)
                     WHERE Is_Done = 0
                           AND CMSYear = @CMSYear
						   and Npi is not null
						    and Npi !='';
                 OPEN CurTINNPIMeasures;
                 FETCH NEXT FROM CurTINNPIMeasures INTO @strCurTIN, @strCurNPI;
                 WHILE @@FETCH_STATUS = 0
                     BEGIN
                         PRINT 'CODE IA:N 104 TIN-NPI-Measure Cursor Started with  TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' NPI: '+CAST(@strCurNPI AS VARCHAR(50));
                         IF EXISTS
(
    SELECT is_GPRO
    FROM tbl_TIN_GPRO
    WHERE TIN = @strCurTIN
          AND is_GPRO = 0
)--For NON GPRO TIN



                             BEGIN
                                 PRINT 'CODE IA:N 105 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' is NON GPRO TIN'; 
  --STEP:#3 insert new record in tbl_IA_User_Selected_Categories
                                 INSERT INTO [dbo].[tbl_IA_User_Selected_Categories]
												([Activity],
												 [ActivityWeighing],
												 [UpdatedBy],
												 [UpdatedDateTime],
												 [CMSYear]
												)
																				 VALUES
												(NULL, --<Activity, varchar(5000),> 
												 NULL, --<ActivityWeighing, varchar(5000),> 
												@UserName, --<UpdatedBy, varchar(50),> 
												 GETDATE(), --<UpdatedDateTime, datetime,> 
												 @CMSYear--<CMSYear, int,>
												);
								SELECT @SCOPEIDENTITY_Selection_ID = SCOPE_IDENTITY();	
  --STEP:#4 insert Measures In tbl_IA_User_Selected based on SCOPE_IDENTITY and Tbl_Backend_TINNPI_IAMeasures							 

                                 INSERT INTO [dbo].[tbl_IA_User_Selected]
								([SelectedID],
								 [SelectedActivity],
								 [StartDate],
								 [EndDate],
								 [UpdatedBy],
								 [UpdatedDateTime],
								 [CMSYear]
								)
                                        SELECT @SCOPEIDENTITY_Selection_ID,
                                               A.Activity,
                                              A.Start_Date,
                                              A.End_Date,
                                                @UserName,
                                               GETDATE(),
                                               @CMSYear
											   from  Tbl_Backend_TINNPI_IA A where Tin=@strCurTIN and Npi=@strCurNPI and Npi is not null and Npi !=''
											          and CMSYear=@CMSYear and Is_Done=0
--Change#1
                                 DELETE FROM tbl_IA_User_Selected_Categories  where ID in (select SelectedID from tbl_IA_Users
                                 WHERE TIN = @strCurTIN
                                       AND NPI = @strCurNPI
                                       AND CMSYear = @CMSYear);

--STEP#6 INSERT TIN NPI data into tbl_IA_Users
												 INSERT INTO [dbo].[tbl_IA_Users]
											([SelectedID],
											 [NPI],
											 [TIN],
											 [Updatedby],
											 [UpdatedDateTime],
											 [CMSYear]
											)
																			 VALUES
											(@SCOPEIDENTITY_Selection_ID,
											 @strCurNPI,
											 @strCurTIN,
											 @UserName, --<UpdatedBy, varchar(50),> 
											 GETDATE(), --<UpdatedDateTime, datetime,> 
											 @CMSYear--<CMSYear, int,>  
											);	
											Set @tempIAActivities='';
											     SELECT @tempIAActivities = COALESCE(@tempIAActivities+', ', '')+Activity
                 FROM Tbl_Backend_TINNPI_IA where Tin=@strCurTIN and Npi=@strCurNPI and Npi is not null and Npi !='' and Is_Done=0									 							 				   

  --STEP #7: INSERT TBL_AUDIT_SELECT_GPRO_MEASURES_BACKEND
                                 INSERT INTO [TBL_AUDIT_SELECT_IA_NON_GPRO_MEASURES_BACKEND]
								([TIN],
								 NPI,
								 [Measure_num],
								 [Created_datetime]
								)
																 VALUES
								(@strCurTIN,
								 @strCurNPI,
								 @tempIAActivities,
								 GETDATE()
								);
                                 PRINT 'CODE IA:N 112 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' NPI'+CAST(@strCurNPI AS VARCHAR(10))+' are inserted into the TBL_AUDIT_SELECT_IA_NON_GPRO_MEASURES_BACKEND for Audit'; 

 

	 --STEP #8: Update the [IS_Done]=1 for the table [Tbl_Backend_TINNPI_IA] 


                                 UPDATE [dbo].[Tbl_Backend_TINNPI_IA]
                                   SET
                                       Is_Done = 1-- <IsDone, bit,>
                                 WHERE TIN = @strCurTIN
                                       AND NPI = @strCurNPI
                                       AND CMSYear = @CMSYear;
                                 PRINT 'CODE IA:N 113 TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' NPI'+CAST(@strCurNPI AS VARCHAR(10))+' are Updated into the Tbl_Backend_TINNPI_IA for Audit';
                             END--ENDs IF(@blnGPRO=1);
                             ELSE --For NON GPRO TIN


                             BEGIN
                                 PRINT 'CODE IA:N 114 TIN '+CAST(@strCurTIN AS VARCHAR(10))+' is   GPRO ';
                             END;
                         PRINT 'CODE IA:N 115 TIN-NPI-Measure Cursor Ends with  TIN: '+CAST(@strCurTIN AS VARCHAR(10));
                         FETCH NEXT FROM CurTINNPIMeasures INTO @strCurTIN, @strCurNPI;
                     END;
                 CLOSE CurTINNPIMeasures;
                 DEALLOCATE CurTINNPIMeasures;

    -----------------TIN,NPI,MEASURE Cursor Ends------------------------------




                 COMMIT TRANSACTION;
             END TRY
             BEGIN CATCH
                 IF @@TRANCOUNT > 0
                     ROLLBACK TRANSACTION;
                 DECLARE @ErrorNumber INT= ERROR_NUMBER();
                 DECLARE @ErrorLine INT= ERROR_LINE();
                 DECLARE @ErrorMessage NVARCHAR(4000)= ERROR_MESSAGE();
                 DECLARE @ErrorSeverity INT= ERROR_SEVERITY();
                 DECLARE @ErrorState INT= ERROR_STATE();
                 PRINT 'Actual error number: '+CAST(@ErrorNumber AS VARCHAR(10));
                 PRINT 'Actual line number: '+CAST(@ErrorLine AS VARCHAR(10));
                 PRINT 'CODE IA:N 116 Error AT TIN: '+CAST(@strCurTIN AS VARCHAR(10))+' NPI: '+CAST(@strCurNPI AS VARCHAR(10));
                 RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
             END CATCH;
         END;






