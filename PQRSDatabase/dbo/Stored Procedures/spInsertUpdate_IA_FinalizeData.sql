-- =============================================
-- Author:		Raju Gaddam
-- Create date:  Feb 14,2108
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spInsertUpdate_IA_FinalizeData]
	-- Add the parameters for the stored procedure here
@Tin varchar(9),
@Npi varchar(11),
@isGpro bit,
@CMSYear int,
@isFinalize bit,
@CreateBy int,
@Createddate datetime,
@ModifiedBy int,
@ModifiedDate datetime,
@isTinLock bit,
@Email varchar(50),
@finalizeAgreeTime datetime,
@finalizeDisAgreeTime datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	 print 'started enter tin leve gpro'+Convert(varchar(50), @isGpro);
  --TIN level insert/update data
	if(@isGpro =1)
	begin
	  print 'enter gpro level';
		if not exists (select  Fid  from tbl_CMS_IA_Finalization  where TIN=@Tin and isGpro=@isGpro and Finalize_Year=@CMSYear and NPI is null)
		begin 
		--inserting 
         print 'enter tin leve gpro';
		insert into 
		tbl_CMS_IA_Finalization(TIN,isGpro,
		isFinalize,FinalizeEmail,Finalize_Year
		,FinalizeAgreeTime,CreatedBy,CreatedDate)
		values
		(@Tin,@isGpro,@isFinalize,@Email,
		@CMSYear,@finalizeAgreeTime,
		@CreateBy,@Createddate)
		end
		else

		begin
				if(@isFinalize=0)
				begin
							update tbl_CMS_IA_Finalization 
					set
	   
					FinalizeEmail=@Email,
					isFinalize=@isFinalize,
					
					FinalizeDisagreeTime=@finalizeDisAgreeTime ,
					UpdatedBy =@ModifiedBy,
					UpdatedDate=@ModifiedDate
					where  TIN=@Tin and isGpro=@isGpro and Finalize_Year=@CMSYear and NPI is null
				end
				else
				begin
							update tbl_CMS_IA_Finalization 
					set
	   
					FinalizeEmail=@Email,
					isFinalize=@isFinalize,
					FinalizeAgreeTime=@finalizeAgreeTime ,
				
					UpdatedBy =@ModifiedBy,
					UpdatedDate=@ModifiedDate
					where  TIN=@Tin and isGpro=1 and Finalize_Year=@CMSYear and NPI is null
				end
				
		end
		-- Insert/update TIN Level data to tbl_TINConvertion_Lock for Lockig Tin GPRO/NonGpro Management

        if not exists(select Id from tbl_TINConvertion_Lock  where TIN=@Tin and CMSYear=@CMSYear and isGpro=@isGpro and Npi is null)
		begin 
		insert into tbl_TINConvertion_Lock
		(TIN,isGpro,CMSYear,isIAFinalize,isLock,CreatedBy,CreatedDate)
		values
		(@Tin,@isGpro,@CMSYear,@isFinalize,@isTinLock,@CreateBy,@Createddate)	
		end
		else
		begin
		update tbl_TINConvertion_Lock
		 set 
		 isIAFinalize=@isFinalize,	
		 LastModifiedBy=@ModifiedBy,
		 LastModifiedDate=@ModifiedDate
	
		where TIN=@Tin and CMSYear=@CMSYear and isGpro=@isGpro and Npi is null
		end
	end
	else
	begin

		if not exists (select Fid from tbl_CMS_IA_Finalization  where TIN=@Tin and isGpro=@isGpro and Finalize_Year=@CMSYear and NPI=@Npi)
		begin 
		--inserting 
		insert into 
		tbl_CMS_IA_Finalization(TIN,NPI,isGpro,
		isFinalize,FinalizeEmail,Finalize_Year
		,FinalizeAgreeTime,CreatedBy,CreatedDate)
		values
		(@Tin, @Npi,@isGpro,@isFinalize,@Email,
		@CMSYear,@finalizeAgreeTime,
		@CreateBy,@Createddate)
		end
		else
		begin
						if(@isFinalize=0)
				begin
					update tbl_CMS_IA_Finalization 
					set	
					FinalizeEmail=@Email,		
					isFinalize=@isFinalize,	
				
					FinalizeDisagreeTime=@finalizeDisAgreeTime,
					UpdatedBy =@ModifiedBy,
					UpdatedDate=@ModifiedDate
					where TIN=@Tin and isGpro=@isGpro and Finalize_Year=@CMSYear and NPI=@Npi
				end
				else
				begin
						update tbl_CMS_IA_Finalization 
						set	
						FinalizeEmail=@Email,		
						isFinalize=@isFinalize,	
						FinalizeAgreeTime=@finalizeAgreeTime ,
						
						UpdatedBy =@ModifiedBy,
						UpdatedDate=@ModifiedDate
						where TIN=@Tin and isGpro=@isGpro and Finalize_Year=@CMSYear and NPI=@Npi
				end
	
		end

	    -- Insert/update TIN/NPL Level data to tbl_TINConvertion_Lock for Lockig Tin GPRO/NonGpro Management
	
        if not exists( select Id from tbl_TINConvertion_Lock  where TIN=@Tin and CMSYear=@CMSYear and isGpro=@isGpro and NPI=@Npi)
		begin 
		insert into tbl_TINConvertion_Lock
		(TIN,NPI,isGpro,CMSYear,isIAFinalize,isLock,CreatedBy,CreatedDate)
		values
		(@Tin,@Npi,@isGpro,@CMSYear,@isFinalize,@isTinLock,@CreateBy,@Createddate)	
		end
		else
		begin
		update tbl_TINConvertion_Lock
		 set 
		 isIAFinalize=@isFinalize,
		 LastModifiedBy=@ModifiedBy,
		 LastModifiedDate=@ModifiedDate
		 where TIN=@Tin and CMSYear=@CMSYear and isGpro=@isGpro and NPI=@Npi
		end
	end
END
