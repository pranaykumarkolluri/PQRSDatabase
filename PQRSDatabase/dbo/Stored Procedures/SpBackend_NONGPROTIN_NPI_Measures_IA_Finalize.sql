
-- =============================================
-- Author:		Hari J
-- Create date: <Create Date,,>
-- Description: it will work for Finalize/Undo Finalize based on @isFinalize for NONGPROTIN side
--exec SpBackend_NONGPROTIN_NPI_Measures_Finalize 2017,1,427,'hariTINNPIFINALIZE@gmail.com'
-- =============================================
CREATE PROCEDURE [dbo].[SpBackend_NONGPROTIN_NPI_Measures_IA_Finalize]
	-- Add the parameters for the stored procedure here
   @CMSYear int  ,
    @isFinalize	as bit ,--@isFinalize=1 for Finalization and -@isFinalize=0 for Undo Finalization
    @UserID int,
   @FinalizeEmailAddress varchar (50)
AS
BEGIN
	

   declare @strCurTIN varchar(10)
    declare @strCurNPI varchar(10)
 
   DECLARE @blnGPRO as bit;

   -----------------TIN-NPI Cursor STARTS------------------------------

    declare CurTINs_CurNPIs CURSOR FOR

    --STEP #1: Getting Required TIN 
    select DISTINCT TIN,NPI from TBL_SELECT_NON_GPRO_MEASURES_BACKEND  WITH(NOLOCK)
    
    OPEN CurTINs_CurNPIs

    
    FETCH NEXT FROM CurTINs_CurNPIs INTO @strCurTIN,@strCurNPI

    WHILE @@FETCH_STATUS=0

    BEGIN
     PRINT 'TIN-NPI Cursor Started with  TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10));
	  --STEP #2: Check TIN is GPRO or NOT 
	 set @blnGPRO = 0;		
	                          --Check tin gpro status
							exec sp_getTIN_GPRO @strCurTIN
							select top 1  @blnGPRO =  is_GPRO from 
							tbl_TIN_GPRO where ltrim(rtrim(TIN)) = ltrim(rtrim(@strCurTIN))

IF(@blnGPRO=0)--finalize functionality applicable for NON GPRO TINS only 
BEGIN

	IF(@isFinalize=1)
	BEGIN
     PRINT 'CODE IA:FTN 201 - Finalization For TIN: ' + CAST(@strCurTIN AS VARCHAR(10))+' NPI: ' + CAST(@strCurNPI AS VARCHAR(10));
	
	  --STEP #3: INSERT/UPDATE table tbl_CMS_Finalization

	 IF NOT EXISTS(select * from tbl_CMS_IA_Finalization  where TIN=@strCurTIN and Finalize_Year=@CMSYear and NPI =@strCurNPI)
	BEGIN
	  PRINT 'CODE IA:FTN 202 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) +' was not finalized so we will inserting into tbl_CMS_IA_Finalization';
	

	 INSERT INTO [dbo].[tbl_CMS_IA_Finalization]
           ([isGpro]
           ,[TIN]
          ,[NPI]
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
         ,@strCurNPI--<NPI, varchar(10),>
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
	 PRINT 'CODE IA:FTN 203 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) +' was  finalized so we will updating into tbl_CMS_IA_Finalization for Finalization'
	

	UPDATE [tbl_CMS_IA_Finalization]
     SET 
     [isFinalize] =1-- <isFinalize, bit,>
     ,[FinalizeAgreeTime] = GETDATE()--<FinalizeAgreeTime, datetime,>
     -- ,[FinalizeDisagreeTime] = <FinalizeDisagreeTime, datetime,>     
      ,[UpdatedBy] =@UserID   -- <UpdatedBy, int,>
      ,[UpdatedDate] =GETDATE()-- <UpdatedDate, datetime,>
      
     WHERE  TIN=@strCurTIN and Finalize_Year=@CMSYear and NPI =@strCurNPI

	--STEP #4: INSERT/UPDATE table tbl_TINConvertion_Lock

	  if not exists(select Id from tbl_TINConvertion_Lock  where TIN=@strCurTIN and CMSYear=@CMSYear and isGpro=0 and Npi=@strCurNPI)
		begin 
		 PRINT 'COD IA:FTN 204 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) +' value insert into tbl_TINConvertion_Lock for Locking'
		insert into
		 tbl_TINConvertion_Lock
		(TIN,
		NPI,
		isGpro,
		CMSYear,
		isIAFinalize,
		isLock,
		CreatedBy,
		CreatedDate)
		values
		(
		@strCurTIN,
		@strCurNPI,
		0,
		@CMSYear,
		@isFinalize,
		1,
		@UserID,
		GETDATE()
		)	
		end
		else
		begin

		 PRINT 'CODE IA:FTN 205 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) +' value updating into tbl_TINConvertion_Lock for Locking'
		update tbl_TINConvertion_Lock
		 set 	
		 isIAFinalize=1,
		 LastModifiedBy=@UserID,
		 LastModifiedDate=GETDATE()
		where TIN=@strCurTIN and CMSYear=@CMSYear and isGpro=0 and Npi=@strCurNPI
		end




	END
	END -- ends IF(@isFinalize=1)
	ELSE--undo finalize functionality

	BEGIN
	 PRINT 'CODE IA:FTN 206 - UNDO Finalization For TIN: ' + CAST(@strCurTIN AS VARCHAR(10))+' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) ;

	   --STEP #3: INSERT/UPDATE table tbl_CMS_Finalization
	 IF NOT EXISTS(select * from tbl_CMS_IA_Finalization where TIN=@strCurTIN and Finalize_Year=@CMSYear and Npi=@strCurNPI)
	BEGIN
	 
	   PRINT 'CODE IA:FTN 207 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) +' was not UNDO finalized so we will inserting into tbl_CMS_IA_Finalization';
	
	 INSERT INTO [dbo].[tbl_CMS_IA_Finalization]
           ([isGpro]
           ,[TIN]
           ,[NPI]
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
           (0
           ,@strCurTIN
           ,@strCurNPI--<NPI, varchar(10),>
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
 PRINT 'CODE IA:FTN 208 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) +' was UNDO finalized so we will updating into tbl_CMS_IA_Finalization for Finalization'
	

	UPDATE [tbl_CMS_IA_Finalization]
   SET 
     [isFinalize] =0-- <isFinalize, bit,>
     -- ,[FinalizeAgreeTime] = <FinalizeAgreeTime, datetime,>
    ,[FinalizeDisagreeTime] = GETDATE()--<FinalizeDisagreeTime, datetime,>     
    ,[UpdatedBy] =@UserID  -- <UpdatedBy, int,>
     ,[UpdatedDate] =GETDATE()-- <UpdatedDate, datetime,>
      
    WHERE  TIN=@strCurTIN and Finalize_Year=@CMSYear and  NPI = @strCurNPI


    --STEP #4: INSERT/UPDATE table tbl_TINConvertion_Lock

	  if not exists(select Id from tbl_TINConvertion_Lock  where TIN=@strCurTIN and CMSYear=@CMSYear and isGpro=0 and Npi=@strCurNPI)
		begin 
		 PRINT 'CODE IA:FTN 209 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) +' value insert into tbl_TINConvertion_Lock for Locking'
		insert into
		 tbl_TINConvertion_Lock
		(TIN,
		NPI,
		isGpro,
		CMSYear,
		isIAFinalize,
		isLock,
		CreatedBy,
		CreatedDate)
		values
		(
		@strCurTIN,
		@strCurNPI,
		0,
		@CMSYear,
		0,
		0,
		@UserID,
		GETDATE()
		)	
		end
		else
		begin

		 PRINT 'CODE IA:FTN 210 -TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) +' value updating into tbl_TINConvertion_Lock for Locking'
		update tbl_TINConvertion_Lock
		 set 	
		 isIAFinalize=0,
		 LastModifiedBy=@UserID,
		 LastModifiedDate=GETDATE()
		where TIN=@strCurTIN and CMSYear=@CMSYear 
		and isGpro=0 and 
		Npi =@strCurNPI
		end



	END
	END

END ---IF(@blnGPRO=0)

ELSE --for GPRO

BEGIN
PRINT 'CODE:FTN 211 TIN: ' + CAST(@strCurTIN AS VARCHAR(10))+' is  GPRO TIN'
END

     PRINT 'TIN-NPI Cursor Ends with  TIN: ' + CAST(@strCurTIN AS VARCHAR(10)) +' NPI: ' + CAST(@strCurNPI AS VARCHAR(10)) ;

     FETCH NEXT FROM CurTINs_CurNPIs INTO @strCurTIN,@strCurNPI
     -----------------TIN-NPI Cursor END------------------------------
    END

    CLOSE CurTINs_CurNPIs;
    DEALLOCATE CurTINs_CurNPIs;


END



