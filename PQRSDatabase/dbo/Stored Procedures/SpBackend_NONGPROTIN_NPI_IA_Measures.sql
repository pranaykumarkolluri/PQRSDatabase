
-- =============================================
-- Author:		Hari j
-- Create date: <Create Date,,>
-- Description:	This is used to INSERT/UPDATE tbl_GPRO_TIN_Selected_Measures based on Backend Data

--exec SpBackend_NONGPROTIN_NPI_IA_Measures 2017,427,'hariTINNPIbackend@gmail.com'

--change#1:hari j ,Mar 14th,2019
--change#1: remove the finalize functionality 
-- =============================================
CREATE PROCEDURE [dbo].[SpBackend_NONGPROTIN_NPI_IA_Measures]
 @CMSYear int,
 @UserID int
 --@AttestedEmailAddress varchar (50)
AS
BEGIN

    declare @strCurTIN varchar(10)
      declare @strCurNPI varchar(10)

    Declare @ErrorCode as int 
    DECLARE @blnGPRO	as bit;
     DECLARE @Selection_ID int;
   
    DECLARE @SCOPEIDENTITY_Selection_ID as int;



BEGIN TRY
    BEGIN TRANSACTION; 


   -----------------TIN Cursor STARTS------------------------------
    DECLARE @tempIAActivities VARCHAR(MAX)
SELECT @tempIAActivities = COALESCE(@tempIAActivities+', ' ,'') + SelectedActivity
FROM TBL_SELECT_LOOKUP_IA_MEASURES_BACKEND

    declare CurTINs CURSOR FOR

    --STEP #1: Getting Required TIN 
    select DISTINCT TIN from TBL_SELECT_NON_GPRO_MEASURES_BACKEND  WITH(NOLOCK)
    OPEN CurTINs

    FETCH NEXT FROM CurTINs INTO @strCurTIN

    WHILE @@FETCH_STATUS=0

    BEGIN
     PRINT 'IA:TIN Cursor Started with  TIN: ' + CAST(@strCurTIN AS VARCHAR(10));

    --STEP #1.1: FIND Whether TIN GPRO or Not?
      set @blnGPRO = 0;			
							--Check tin gpro status
							exec sp_getTIN_GPRO @strCurTIN
							select top 1  @blnGPRO =  is_GPRO from 
							tbl_TIN_GPRO where ltrim(rtrim(TIN)) = ltrim(rtrim(@strCurTIN))

----start 2017 Year logic------------ --change#1:
 --   --STEP #2:FIND Whether TIN Finalized or Not?
 --   IF NOT EXISTS(select * from  tbl_TINConvertion_Lock B  
 --   Where B.TIN=@strCurTIN and B.CMSYear=@CMSYear and b.NPI is not null 
 --   and (B.isGpro=0 and B.isGpro=@blnGPRO) and (B.isACIFinalize =1 or B.isIAFinalize=1 or B.isQMFinalize=1))
	--BEGIN
	-- -- @ErrorCode=2 NO TIN INFORMATION FOUND IN NRDR DATABASE
	-- -- @ErrorCode=0 GETTING ERROR WHILE UPDATING THE TIN IN NRDR DATABASE
	-- -- @ErrorCode=3 GETTING ERROR WHILE UPDATING THE TIN IN PQRS DATABASE

	-- --STEP #2.1: if TIN not finalized please Convert TIN to GPRO
	--   PRINT 'CODE IA:N 101 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' not finalized yet so we will converting the TIN to NON GPRO' 
 --      exec spUpdate_GPROtoNonGPRO_ViceVersa @strCurTIN,0,@CMSYear,'', @ErrorCode=@ErrorCode OUTPUT
	--END
	--else
	--BEGIN
	--  PRINT 'CODE IA:N 102 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' is already  finalized, so we will not convert the TIN to NON GPRO' 
	--END

----end 2017 Year logic------------ --change#1:

----start 2018 Year logic------------ --change#1:
if(@blnGPRO=1)--Converting  GPRO to non GPRO
BEGIN
exec spUpdate_GPROtoNonGPRO_ViceVersa @strCurTIN,0,@CMSYear,'', @ErrorCode=@ErrorCode OUTPUT
END
----end 2018 Year logic------------ --change#1:

	PRINT 'CODE IA:N 103 TIN Cursor Ends with  TIN: ' + CAST(@strCurTIN AS VARCHAR(10))

    FETCH NEXT FROM CurTINs INTO @strCurTIN
     -----------------TIN Cursor END------------------------------
    END

    CLOSE CurTINs;
    DEALLOCATE CurTINs;


	
-----------------TIN,NPI------------------------------

SET @strCurTIN=''

     declare CurTINs_CurNPIss_CurMeasures_CurExamCount CURSOR FOR

    --STEP #5: Getting Required TIN ,NPI,MeasureNumber and TotalCasesReviewed count data
   select DISTINCT TIN,NPI from TBL_SELECT_NON_GPRO_MEASURES_BACKEND  WITH(NOLOCK)

    WHERE (IsProcessDone_IA=0 or IsProcessDone_IA is null)
    
    OPEN CurTINs_CurNPIss_CurMeasures_CurExamCount

    
    FETCH NEXT FROM CurTINs_CurNPIss_CurMeasures_CurExamCount INTO @strCurTIN,@strCurNPI

    WHILE @@FETCH_STATUS=0

    BEGIN
     PRINT 'CODE IA:N 104 TIN-NPI-Measure Cursor Started with  TIN: ' 
	+ CAST(@strCurTIN AS VARCHAR(10))+' NPI: ' + CAST(@strCurNPI AS VARCHAR(50))	;
	  
	   set @blnGPRO = 0;			
							
							select top 1  @blnGPRO =  is_GPRO from 
							tbl_TIN_GPRO where ltrim(rtrim(TIN)) = ltrim(rtrim(@strCurTIN))
	  
	  
	  IF(@blnGPRO=0)--For NON GPRO TIN

 

   BEGIN
 
	   PRINT 'CODE IA:N 105 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' is NON GPRO TIN'; 

----start 2017 Year logic------------ --change#1:
--     --STEP #4: Attested the TIN
--	IF NOT EXISTS(select * from [tbl_CMS_Attestation_Year] where [PhysicianNPI]=ltrim(rtrim(@strCurNPI)) and CMSAttestYear=@CMSYear)
--	BEGIN
--	-- INSERT
--	PRINT 'CODE IA:N 106 NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) +' is inserting into the [tbl_CMS_Attestation_Year] for Attestation'; 

	
	
--INSERT INTO [dbo].[tbl_CMS_Attestation_Year]
--           ([CMSAttestYear]
--           ,[PhysicianNPI]
--           ,[IsAttested]
--           ,[Attestation_Agree_Time]
--          -- ,[Attestation_Disagree_Time]
--           ,[AttestedBy]
--           ,[Email])
--     VALUES
--           ( @CMSYear--<CMSAttestYear, int,>
--           ,@strCurNPI--<PhysicianNPI, varchar(50),>
--           ,1--<IsAttested, bit,>
--           ,GETDATE()--<Attestation_Agree_Time, datetime,>
--          -- ,<Attestation_Disagree_Time, datetime,>
--           ,@UserID--<AttestedBy, int,>
--           ,@AttestedEmailAddress--<Email, varchar(100),>
--		 )

--	END
----end 2017 Year logic------------ --change#1:
	 
--IA related Measures INSERT/UPDATE starts------------------

--STEP# first  find any record exist or not in tbl_IA_Users
IF EXISTS(select SelectedID from tbl_IA_Users where TIN=ltrim(rtrim(@strCurTIN)) and NPI=ltrim(rtrim(@strCurNPI)) and CMSYear=@CMSYear)
	BEGIN
	SET @Selection_ID=0;
	--  find select id from tbl_IA_Users
	SET @Selection_ID=(select DISTINCT SelectedID from tbl_IA_Users where TIN=ltrim(rtrim(@strCurTIN))  and NPI=ltrim(rtrim(@strCurNPI)) and CMSYear=@CMSYear)
	-- GET SELECTION_ID
	PRINT 'CODE IA:107 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +'  Selection_ID '+ CAST(@Selection_ID AS VARCHAR(10)) + ' from  the tbl_IA_Users';

	if(@Selection_ID>0)
	  begin
	  INSERT INTO [dbo].[tbl_IA_User_Selected]
           ([SelectedID]
           ,[SelectedActivity]
           ,[StartDate]
           ,[EndDate]
           ,[UpdatedBy]
           ,[UpdatedDateTime]
           ,[CMSYear])
     SELECT @Selection_ID, SelectedActivity,
	StartDate,
	EndDate,
	CAST(@UserID as varchar(10)),
	GETDATE(),
	@CMSYear	
	FROM TBL_SELECT_LOOKUP_IA_MEASURES_BACKEND

	PRINT 'CODE IA:N 108 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI'+ CAST(@strCurNPI AS VARCHAR(10)) +' are inserted into the tbl_IA_User_Selected for CMS'; 

 
  end

END

ELSE
BEGIN
--STEP# :first insert new record in tbl_IA_User_Selected_Categories
INSERT INTO [dbo].[tbl_IA_User_Selected_Categories]
           ([Activity]
           ,[ActivityWeighing]
           ,[UpdatedBy]
           ,[UpdatedDateTime]
           ,[CMSYear])
     VALUES
           (NULL--<Activity, varchar(5000),>
           ,NULL--<ActivityWeighing, varchar(5000),>
           ,CAST(@UserID as varchar(10))--<UpdatedBy, varchar(50),>
           ,GETDATE()--<UpdatedDateTime, datetime,>
           ,@CMSYear--<CMSYear, int,>
		 )

 
SELECT @SCOPEIDENTITY_Selection_ID= SCOPE_IDENTITY() 
PRINT 'CODE IA:N 109 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI'+ CAST(@strCurNPI AS VARCHAR(10)) +' SCOPEIDENTITY_Selection_ID'+ CAST(@SCOPEIDENTITY_Selection_ID AS VARCHAR(10)) +' are inserted into the tbl_IA_User_Selected_Categories for CMS'; 

IF(ISNULL(@SCOPEIDENTITY_Selection_ID,0)>0)

BEGIN


--STEP# Get TIN related NPIS
  --STEP# INSERT TIN and TIN related NPIS into tbl_IA_Users
  INSERT INTO [dbo].[tbl_IA_Users]
           ([SelectedID]
           ,[NPI]
           ,[TIN]
           ,[Updatedby]
           ,[UpdatedDateTime]
           ,[CMSYear])
  VALUES(
  @SCOPEIDENTITY_Selection_ID,
  @strCurNPI,
  @strCurTIN
  ,CAST(@UserID as varchar(10))--<UpdatedBy, varchar(50),>
 ,GETDATE()--<UpdatedDateTime, datetime,>
 ,@CMSYear--<CMSYear, int,>  
 )
  
  PRINT 'CODE IA:N 110 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI'+ CAST(@strCurNPI AS VARCHAR(10)) +' are inserted into the tbl_IA_Users for CMS'; 

 
  --STEP# INSERT SELECTED Activities  into tbl_IA_User_Selected 


   INSERT INTO [dbo].[tbl_IA_User_Selected]
           ([SelectedID]
           ,[SelectedActivity]
           ,[StartDate]
           ,[EndDate]
           ,[UpdatedBy]
           ,[UpdatedDateTime]
           ,[CMSYear])
     SELECT @SCOPEIDENTITY_Selection_ID, 
	SelectedActivity,
	StartDate,
	EndDate,
	CAST(@UserID as varchar(10)),
	GETDATE(),
	@CMSYear	
	FROM TBL_SELECT_LOOKUP_IA_MEASURES_BACKEND

PRINT 'CODE IA:N 111 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI'+ CAST(@strCurNPI AS VARCHAR(10)) +' are inserted into the tbl_IA_User_Selected for CMS'; 

 
END
END
--IA related Measures INSERT/UPDATE END------------------
 
  --STEP #7: INSERT TBL_AUDIT_SELECT_GPRO_MEASURES_BACKEND
  INSERT INTO [TBL_AUDIT_SELECT_IA_NON_GPRO_MEASURES_BACKEND]
           ([TIN]
		 ,NPI
           ,[Measure_num]
           ,[Created_datetime])
     VALUES
           (@strCurTIN
		 ,@strCurNPI
           ,@tempIAActivities
           ,GETDATE())

 PRINT 'CODE IA:N 112 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI'+ CAST(@strCurNPI AS VARCHAR(10)) +' are inserted into the TBL_AUDIT_SELECT_IA_NON_GPRO_MEASURES_BACKEND for Audit'; 

 

	 --STEP #8: Update the [IsProcessDone]=1 for the table [TBL_SELECT_NON_GPRO_MEASURES_BACKEND] 
	 

	 UPDATE [dbo].[TBL_SELECT_NON_GPRO_MEASURES_BACKEND]
   SET [IsProcessDone_IA] =1-- <IsProcessDone_IA, bit,>
 WHERE TIN=@strCurTIN
 and NPI=@strCurNPI

  PRINT 'CODE IA:N 113 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI'+ CAST(@strCurNPI AS VARCHAR(10)) +' are Updated into the TBL_SELECT_NON_GPRO_MEASURES_BACKEND for Audit'; 





  END--ENDs IF(@blnGPRO=1)

  ELSE --For NON GPRO TIN


  BEGIN
  PRINT 'CODE IA:N 114 TIN ' + CAST(@strCurTIN AS VARCHAR(10)) +' is   GPRO ';
  END
   PRINT 'CODE IA:N 115 TIN-NPI-Measure Cursor Ends with  TIN: ' 
   + CAST(@strCurTIN AS VARCHAR(10));


	
	FETCH NEXT FROM CurTINs_CurNPIss_CurMeasures_CurExamCount INTO @strCurTIN,@strCurNPI
    END

    CLOSE CurTINs_CurNPIss_CurMeasures_CurExamCount;
    DEALLOCATE CurTINs_CurNPIss_CurMeasures_CurExamCount;

    -----------------TIN,NPI,MEASURE Cursor Ends------------------------------


   

   COMMIT TRANSACTION;
  END TRY
   BEGIN CATCH
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
 
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
 
    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
  PRINT 'CODE IA:N 116 Error AT TIN: ' + CAST(@strCurTIN AS VARCHAR(10))+' NPI: ' + CAST(@strCurNPI AS VARCHAR(10))
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH

  
END



