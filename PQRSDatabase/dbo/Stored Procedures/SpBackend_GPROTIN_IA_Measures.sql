
-- =============================================
-- Author:		Hari j
-- Create date: <Create Date,,>
-- Description:	This is used to INSERT/UPDATE tbl_GPRO_TIN_Selected_Measures based on Backend Data

--exec SpBackend_GPROTIN_Measures 2017,1,'haribackend@gmail.com'
--change#1:hari j ,Mar 14th,2019
--change#1: remove the finalize functionality 
-- =============================================
CREATE PROCEDURE [dbo].[SpBackend_GPROTIN_IA_Measures]
 @CMSYear int,
 @UserID int
 --@AttestedEmailAddress varchar (50) --change#1
AS
BEGIN

    declare @strCurTIN varchar(10);
    DECLARE @Selection_ID int;
    Declare @ErrorCode as int ;
    DECLARE @blnGPRO	as bit;
    DECLARE @SCOPEIDENTITY_Selection_ID as int;
   declare @TINSofNPI table (
NPI varchar(50),
FirstName varchar(50),
LastName varchar(50),
TIN varchar(10),
is_GPRO  bit)

   -----------------TIN Cursor STARTS------------------------------
   DECLARE @tempIAActivities VARCHAR(MAX)
SELECT @tempIAActivities = COALESCE(@tempIAActivities+', ' ,'') + SelectedActivity
FROM TBL_SELECT_LOOKUP_IA_MEASURES_BACKEND

    declare CurTINs CURSOR FOR

    --STEP #1: Getting Required TIN 
    select DISTINCT TIN from TBL_SELECT_GPRO_MEASURES_BACKEND  WITH(NOLOCK)


    WHERE TIN not in(select DISTINCT TIN from TBL_AUDIT_SELECT_IA_GPRO_MEASURES_BACKEND)
    
    OPEN CurTINs

    
    FETCH NEXT FROM CurTINs INTO @strCurTIN

    WHILE @@FETCH_STATUS=0

    BEGIN
     PRINT 'TIN Cursor Started with  TIN: ' + CAST(@strCurTIN AS VARCHAR(10));
BEGIN TRY
    BEGIN TRANSACTION;
     --STEP #1.1: FIND Whether TIN GPRO or Not?
      set @blnGPRO = 0;			
							--Check tin gpro status
							exec sp_getTIN_GPRO @strCurTIN
							select top 1  @blnGPRO =  is_GPRO from 
							tbl_TIN_GPRO where ltrim(rtrim(TIN)) = ltrim(rtrim(@strCurTIN))

  

----START 2017 Year logic--------------change#1:
 --   --STEP #2:FIND Whether TIN Finalized or Not?
 --   IF NOT EXISTS(select * from  tbl_TINConvertion_Lock B  
 --   Where B.TIN=@strCurTIN and B.CMSYear=@CMSYear and b.NPI is null 
 --   and (B.isGpro=1 and B.isGpro=@blnGPRO) and (B.isACIFinalize =1 or B.isIAFinalize=1 or B.isQMFinalize=1))
	--BEGIN
	-- --@ErrorCode=2 NO TIN INFORMATION FOUND IN NRDR DATABASE
	-- --@ErrorCode=0 GETTING ERROR WHILE UPDATING THE TIN IN NRDR DATABASE
	-- -- @ErrorCode=3 GETTING ERROR WHILE UPDATING THE TIN IN PQRS DATABASE

	-- --STEP #2.1: if TIN not finalized please Convert TIN to GPRO
	--   PRINT 'CODE IA:101 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' not finalized yet so we will converting the TIN to GPRO' 
 --   exec spUpdate_GPROtoNonGPRO_ViceVersa @strCurTIN,1,@CMSYear,'', @ErrorCode=@ErrorCode OUTPUT
	--END
	--ELSE
	--BEGIN
	-- PRINT 'CODE IA:102 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' was already finalized so we will not convert the TIN to GPRO'
	--SET @ErrorCode=4
	--END

----END 2017 Year logic--------------change#1:

----START 2018 Year logic--------------change#1:
SET @ErrorCode=4
 IF(@blnGPRO=0)---Converting non GPRO to GPRO
    BEGIN
    PRINT 'CODE:101 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' ' 
    exec spUpdate_GPROtoNonGPRO_ViceVersa @strCurTIN,1,@CMSYear,'', @ErrorCode=@ErrorCode OUTPUT

    END
----END 2018 Year logic------------


   IF(@ErrorCode=4)
   BEGIN
   
    
                          
IF(@blnGPRO=1)--For GPRO TIN
BEGIN
 PRINT 'CODE IA:103 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' is GPRO TIN'; 

  ----START 2017 Year logic--------------change#1:
 --    --STEP #4: Attested the TIN
	--IF NOT EXISTS(select * from [tbl_GPRO_TIN_EmailAddresses] where GPROTIN=ltrim(rtrim(@strCurTIN)) and Tin_CMSAttestYear=@CMSYear)
	--BEGIN
	---- INSERT
	--PRINT 'CODE IA:104 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' is inserting into the tbl_GPRO_TIN_EmailAddresses for Attestation'; 

	--INSERT INTO [dbo].[tbl_GPRO_TIN_EmailAddresses]
 --          ([GPROTIN]
 --          ,[GPROTIN_EmailAddress]
 --          ,[CreatedBy]
 --          ,[CreatedDate]
 --          ,[Tin_CMSAttestYear]
 --          ,[IsAttested]
 --          ,[Attestation_Agree_Time]          
 --          ,[AttestedBy]
 --         )
 --    VALUES
 --          (@strCurTIN
 --          ,@AttestedEmailAddress
 --          ,CONVERT(varchar(10),@UserID)
 --          ,GETDATE()
 --          ,@CMSYear
 --          ,1
 --          ,GETDATE()      
 --          ,@UserID
 --          )

	--END
----END 2017 Year logic--------------change#1:


--IA related Measures INSERT/UPDATE starts------------------
--STEP# first  find any record exist or not in tbl_IA_Users
IF EXISTS(select SelectedID from tbl_IA_Users where TIN=ltrim(rtrim(@strCurTIN)) and CMSYear=@CMSYear)
	BEGIN
	SET @Selection_ID=0;
	--  find select id from tbl_IA_Users
	--SET @Selection_ID=(select DISTINCT SelectedID from tbl_IA_Users where TIN=ltrim(rtrim(@strCurTIN)) and CMSYear=@CMSYear)
	-- GET SELECTION_ID
	--PRINT 'CODE IA:105 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +'  Selection_ID '+ CAST(@Selection_ID AS VARCHAR(10)) + ' from  the tbl_IA_Users';
	  DECLARE @tempIASelectedIds VARCHAR(MAX)
SELECT @tempIASelectedIds = COALESCE(@tempIASelectedIds+', ' ,'') + Convert(varchar(100),SelectedID)
from tbl_IA_Users where TIN=ltrim(rtrim(@strCurTIN)) and CMSYear=@CMSYear
PRINT 'CODE IA:105 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +'  Selection_IDs '+ CAST(@tempIASelectedIds AS VARCHAR(10)) + ' from  the tbl_IA_Users';
	
	  INSERT INTO [dbo].[tbl_IA_User_Selected]
           ([SelectedID]
           ,[SelectedActivity]
           ,[StartDate]
           ,[EndDate]
		   
           ,[UpdatedBy]
           ,[UpdatedDateTime]
           ,[CMSYear]
		   )
     SELECT B.SelectedID, A.SelectedActivity,
	A.StartDate,
	A.EndDate,
	CAST(@UserID as varchar(10)),
	GETDATE(),
	@CMSYear
	
	FROM TBL_SELECT_LOOKUP_IA_MEASURES_BACKEND A, tbl_IA_Users B where B.TIN=ltrim(rtrim(@strCurTIN)) and B.CMSYear=@CMSYear


	PRINT 'CODE IA: 106 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' is inserted into the tbl_IA_User_Selected for CMS'; 

  

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

 PRINT 'CODE IA: 107 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' SCOPEIDENTITY_Selection_ID'+ CAST(@SCOPEIDENTITY_Selection_ID AS VARCHAR(10)) +' are inserted into the tbl_IA_User_Selected_Categories for CMS'; 


IF(ISNULL(@SCOPEIDENTITY_Selection_ID,0)>0)

BEGIN


--STEP# Get TIN related NPIS
  INSERT INTO @TINSofNPI
  EXEC [sp_getNPIsOfTin] @strCurTIN



  --STEP# INSERT TIN and TIN related NPIS into tbl_IA_Users
  INSERT INTO [dbo].[tbl_IA_Users]
           ([SelectedID]
           ,[NPI]
           ,[TIN]
           ,[Updatedby]
           ,[UpdatedDateTime]
           ,[CMSYear]
		   ,IsGpro)
  SELECT DISTINCT
  @SCOPEIDENTITY_Selection_ID,
  NPI,
  @strCurTIN
  ,CAST(@UserID as varchar(10))--<UpdatedBy, varchar(50),>
 ,GETDATE()--<UpdatedDateTime, datetime,>
 ,@CMSYear--<CMSYear, int,>  
 ,@blnGPRO
  from @TINSofNPI where NPI is not null
  PRINT 'CODE IA: 108 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' is inserted into the tbl_IA_Users for CMS'; 

  --STEP# INSERT SELECTED Activities  into tbl_IA_User_Selected 


   INSERT INTO [dbo].[tbl_IA_User_Selected]
           ([SelectedID]
           ,[SelectedActivity]
           ,[StartDate]
           ,[EndDate]
           ,[UpdatedBy]
           ,[UpdatedDateTime]
           ,[CMSYear]
		   ,[attest])
     SELECT @SCOPEIDENTITY_Selection_ID, 
	SelectedActivity,
	StartDate,
	EndDate,
	CAST(@UserID as varchar(10)),
	GETDATE(),
	@CMSYear
	,1	
	FROM TBL_SELECT_LOOKUP_IA_MEASURES_BACKEND


PRINT 'CODE IA: 109 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' is inserted into the tbl_IA_User_Selected for CMS'; 


END
END
--IA related Measures INSERT/UPDATE END------------------

  INSERT INTO [TBL_AUDIT_SELECT_IA_GPRO_MEASURES_BACKEND]
           ([TIN]
           ,[Measure_num]
           ,[Created_datetime])
     VALUES
           (@strCurTIN
           ,@tempIAActivities
           ,GETDATE())
PRINT 'CODE IA: 110 TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' are inserted into the [TBL_AUDIT_SELECT_IA_GPRO_MEASURES_BACKEND] for Audit'; 

 
  END--ENDs IF(@blnGPRO=1)

  ELSE --For NON GPRO TIN


  BEGIN
  PRINT 'CODE IA:111 TIN ' + CAST(@strCurTIN AS VARCHAR(10)) +' is  NON GPRO ';
  END
   
END--GPRO Convertion  Ends IF(@ErrorCode=4)

ELSE

BEGIN
 PRINT 'CODE IA:112 Getting Error While Converting GPRO: TIN' + CAST(@strCurTIN AS VARCHAR(10)) +' and GPRO Error Code'+ CAST(@ErrorCode AS VARCHAR(10));
END

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
    PRINT 'CODE IA:113 Error AT TIN: ' + CAST(@strCurTIN AS VARCHAR(10))
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH

  PRINT 'CODE IA:114 TIN Cursor Ends with  TIN: ' + CAST(@strCurTIN AS VARCHAR(10))

    FETCH NEXT FROM CurTINs INTO @strCurTIN
     -----------------TIN Cursor END------------------------------
    END

    CLOSE CurTINs;
    DEALLOCATE CurTINs;
END




