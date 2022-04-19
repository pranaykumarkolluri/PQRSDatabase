
-- =============================================
-- Author:		Hari J
-- Create date: <Create Date,,>
-- Description: it will work for Finalize/Undo Finalize based on @isFinalize for GPROTIN side
--exec SpBackend_GPROTIN_Measures_Finalize 2017,0,427,'hariTINFINALIZE@gmail.com'
-- =============================================
CREATE PROCEDURE [dbo].[SpBackend_GPROTIN_Measures_Finalize]
	-- Add the parameters for the stored procedure here
   @CMSYear int  ,
    @isFinalize	as bit ,--@isFinalize=1 for Finalization and -@isFinalize=0 for Undo Finalization
     @UserID int,
 @FinalizeEmailAddress varchar (50)
AS
BEGIN
	

   declare @strCurTIN varchar(10)
 
   DECLARE @blnGPRO as bit;

   -----------------TIN Cursor STARTS------------------------------

    declare CurTINs CURSOR FOR

    --STEP #1: Getting Required TIN 
    select DISTINCT TIN from TBL_SELECT_GPRO_MEASURES_BACKEND  WITH(NOLOCK)
    
    OPEN CurTINs

    
    FETCH NEXT FROM CurTINs INTO @strCurTIN

    WHILE @@FETCH_STATUS=0

    BEGIN
     PRINT 'TIN Cursor Started with  TIN: ' + CAST(@strCurTIN AS VARCHAR(10));
	  --STEP #2: Check TIN is GPRO or NOT 
	 set @blnGPRO = 0;		
	                          --Check tin gpro status
							exec sp_getTIN_GPRO @strCurTIN
							select top 1  @blnGPRO =  is_GPRO from 
							tbl_TIN_GPRO where ltrim(rtrim(TIN)) = ltrim(rtrim(@strCurTIN))

IF(@blnGPRO=1)--finalize functionality applicable for GPRO TINS only 
BEGIN

	IF(@isFinalize=1)
	BEGIN
     PRINT 'CODE:F201 - Finalization For TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) ;
	
	  --STEP #3: NISERT/UPDATE table tbl_CMS_Finalization

	 IF NOT EXISTS(select * from tbl_CMS_Finalization  where TIN=@strCurTIN and Finalize_Year=@CMSYear and( NPI is null or NPI =''))
	BEGIN
	  PRINT 'CODE:F202 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' was not finalized so we will inserting into tbl_CMS_Finalization';
	

	 INSERT INTO [dbo].[tbl_CMS_Finalization]
           ([isGpro]
           ,[TIN]
          -- ,[NPI]
         ,[FinalizeEmail]
           ,[isFinalize]
           ,[FinalizeAgreeTime]
          -- ,[FinalizeDisagreeTime]
          ,[CreatedBy]
           ,[CreatedDate]
         --  ,[UpdatedBy]
        --   ,[UpdatedDate]
           ,[Finalize_Year])
     VALUES
           (@blnGPRO
           ,@strCurTIN
         --  ,<NPI, varchar(10),>
         , @FinalizeEmailAddress--<FinalizeEmail, varchar(50),>??
           ,1--<isFinalize, bit,>
           ,GETDATE()--<FinalizeAgreeTime, datetime,>
          -- ,<FinalizeDisagreeTime, datetime,>
           ,@UserID --<CreatedBy, int,>
           ,GETDATE()--<CreatedDate, datetime,>
           --,<UpdatedBy, int,>
          -- ,<UpdatedDate, datetime,>
           ,@CMSYear--<Finalize_Year, int,>
		 )
	END
	ELSE

	BEGIN
	 PRINT 'CODE:F203 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' was  finalized so we will updating into tbl_CMS_Finalization for Finalization'
	

	UPDATE [tbl_CMS_Finalization]
     SET 
     [isFinalize] =1-- <isFinalize, bit,>
     ,[FinalizeAgreeTime] = GETDATE()--<FinalizeAgreeTime, datetime,>
     -- ,[FinalizeDisagreeTime] = <FinalizeDisagreeTime, datetime,>     
      ,[UpdatedBy] =@UserID   -- <UpdatedBy, int,>
      ,[UpdatedDate] =GETDATE()-- <UpdatedDate, datetime,>
      
     WHERE  TIN=@strCurTIN and Finalize_Year=@CMSYear and( NPI is null or NPI ='')

	--STEP #4: NISERT/UPDATE table tbl_TINConvertion_Lock

	  if not exists(select Id from tbl_TINConvertion_Lock  where TIN=@strCurTIN and CMSYear=@CMSYear and isGpro=1 and Npi is null)
		begin 
		 PRINT 'CODE:F204 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' value insert into tbl_TINConvertion_Lock for Locking'
		insert into
		 tbl_TINConvertion_Lock
		(TIN,
		isGpro,
		CMSYear,
		isQMFinalize,
		isLock,
		CreatedBy,
		CreatedDate)
		values
		(
		@strCurTIN,
		1,
		@CMSYear,
		@isFinalize,
		1,
		@UserID,
		GETDATE()
		)	
		end
		else
		begin

		 PRINT 'CODE:F205 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' value updating into tbl_TINConvertion_Lock for Locking'
		update tbl_TINConvertion_Lock
		 set 	
		 isQMFinalize=@isFinalize,
		 LastModifiedBy=@UserID,
		 LastModifiedDate=GETDATE()
		where TIN=@strCurTIN and CMSYear=@CMSYear and isGpro=1 and Npi is null
		end




	END
	END -- ends IF(@isFinalize=1)
	ELSE--undo finalize functionality

	BEGIN
	 PRINT 'CODE:F206 - UNDO Finalization For TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) ;

	   --STEP #3: NISERT/UPDATE table tbl_CMS_Finalization
	 IF NOT EXISTS(select * from tbl_CMS_Finalization where TIN=@strCurTIN and Finalize_Year=@CMSYear and( NPI is null or NPI =''))
	BEGIN
	   PRINT 'CODE:F 207 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' was not UNDO finalized so we will inserting into tbl_CMS_Finalization';
	


	 INSERT INTO [dbo].[tbl_CMS_Finalization]
           ([isGpro]
           ,[TIN]
          -- ,[NPI]
         ,[FinalizeEmail]
           ,[isFinalize]
          -- ,[FinalizeAgreeTime]
         ,[FinalizeDisagreeTime]
         ,[CreatedBy]
           ,[CreatedDate]
         --  ,[UpdatedBy]
        --   ,[UpdatedDate]
           ,[Finalize_Year])
     VALUES
           (@blnGPRO
           ,@strCurTIN
         --  ,<NPI, varchar(10),>
          , @FinalizeEmailAddress --<FinalizeEmail, varchar(50),>??
           ,0--<isFinalize, bit,>
          -- ,GETDATE()--<FinalizeAgreeTime, datetime,>
           ,GETDATE()--<FinalizeDisagreeTime, datetime,>
           ,@UserID --<CreatedBy, int,>
           ,GETDATE()--<CreatedDate, datetime,>
           --,<UpdatedBy, int,>
          -- ,<UpdatedDate, datetime,>
           ,@CMSYear--<Finalize_Year, int,>
		 )
	END
	ELSE

	BEGIN
  PRINT 'CODE:F 208 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' was UNDO finalized so we will updating into tbl_CMS_Finalization';

	UPDATE [tbl_CMS_Finalization]
   SET 
     [isFinalize] =0-- <isFinalize, bit,>
     -- ,[FinalizeAgreeTime] = <FinalizeAgreeTime, datetime,>
    ,[FinalizeDisagreeTime] = GETDATE()--<FinalizeDisagreeTime, datetime,>     
    ,[UpdatedBy] =@UserID  -- <UpdatedBy, int,>
     ,[UpdatedDate] =GETDATE()-- <UpdatedDate, datetime,>
      
    WHERE  TIN=@strCurTIN and Finalize_Year=@CMSYear and( NPI is null or NPI ='')


    --STEP #4: NISERT/UPDATE table tbl_TINConvertion_Lock

	  if not exists(select Id from tbl_TINConvertion_Lock  where TIN=@strCurTIN and CMSYear=@CMSYear and isGpro=1 and Npi is null)
		begin 
		 PRINT 'CODE:F209 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' value insert into tbl_TINConvertion_Lock for Locking'
		insert into
		 tbl_TINConvertion_Lock
		(TIN,
		isGpro,
		CMSYear,
		isQMFinalize,
		isLock,
		CreatedBy,
		CreatedDate)
		values
		(
		@strCurTIN,
		1,
		@CMSYear,
		0,
		0,
		@UserID,
		GETDATE()
		)	
		end
		else
		begin

		 PRINT 'CODE:F210 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' value updating into tbl_TINConvertion_Lock for Locking'
		update tbl_TINConvertion_Lock
		 set 	
		 isQMFinalize=0,
		 LastModifiedBy=@UserID,
		 LastModifiedDate=GETDATE()
		where TIN=@strCurTIN and CMSYear=@CMSYear 
		and isGpro=1 and 
		Npi is null
		end



	END
	END

END ---IF(@blnGPRO=1)

ELSE --for non GPRO

BEGIN
PRINT 'TIN: ' + CAST(@strCurTIN AS VARCHAR(10))+' is NON GPRO TIN'
END

     PRINT 'TIN Cursor Ends with  TIN: ' + CAST(@strCurTIN AS VARCHAR(10))

    FETCH NEXT FROM CurTINs INTO @strCurTIN
     -----------------TIN Cursor END------------------------------
    END

    CLOSE CurTINs;
    DEALLOCATE CurTINs;


END


