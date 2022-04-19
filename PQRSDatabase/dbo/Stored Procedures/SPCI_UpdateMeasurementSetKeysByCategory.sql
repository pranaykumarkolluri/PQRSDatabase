-- =============================================
-- Author:		Hari J
-- Create date:  30-jan-2019
-- Description: Used to update the MeasurementSetKeys
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_UpdateMeasurementSetKeysByCategory]
	-- Add the parameters for the stored procedure here
	 @Tin varchar(9) ,
	 @Npi varchar(10),
	 @CmsYear int,
	 @ResponseId int,
	 @MeasurementSet_Unquekey_id varchar(150),
	 @Submission_Uniquekey_Id varchar(150),

	--@tbl_CI_Source_UniqueKeys_Type tbl_CI_Source_UniqueKeys_Type READONLY,
	@CategoryId int
AS
BEGIN


---Step#1 Update IsMSetIdActive=0 based on Tin ,Npi,CmsYear

update tbl_CI_Source_UniqueKeys 
set IsMSetIdActive =0 
where ISNULL(MeasurementSet_Unquekey_id,'')='' or ISNULL(Submission_Uniquekey_Id,'')=''

update tbl_CI_Source_UniqueKeys 
set IsMSetIdActive =0 
where Tin=@Tin and  isnull(Npi,'')=isnull(@Npi,'') and CmsYear =@CmsYear and Category_Id=@CategoryId

--Step#2  Insert new data to tbl_CI_Source_UniqueKeys from @tbl_CI_Source_UniqueKeys_Type based on  Tin ,Npi,CmsYear
--if(isnull(@MeasurementSet_Unquekey_id,'')<>'' and isnull(@Submission_Uniquekey_Id,'')<>'' ) 
--begin
--insert into tbl_CI_Source_UniqueKeys 
--(Tin,
--Npi,
--CmsYear,
--MeasurementSet_Unquekey_id,
--Response_Id,
--Submission_Uniquekey_Id,
--Category_Id,
--IsMSetIdActive
--)
--select 
--@Tin
--,@Npi
--,@CmsYear
--,
--@MeasurementSet_Unquekey_id,
--@ResponseId,
--@Submission_Uniquekey_Id,
--@CategoryId,
--1 
--end

	if not exists(select 1 from  tbl_CI_Source_UniqueKeys where Category_Id=@CategoryId and CmsYear=@CmsYear and ISNULL(tin,'') =isnull(@Tin,'') and ISNULL(Npi,'')=ISNULL(@Npi,'') and IsMSetIdActive=1)
	begin
	--insert into tmp_raju values('insert');
				INSERT INTO [dbo].[tbl_CI_Source_UniqueKeys]
						   ([Submission_Uniquekey_Id]
						   ,[MeasurementSet_Unquekey_id]
						   --,[Measurement_Uniquekey_id]
						   ,[Category_Id]
						
						   ,IsMSetIdActive
						   ,Tin
						   ,Npi
						   ,CmsYear
						
						  )
						SELECT
							@Submission_Uniquekey_Id
						   ,@MeasurementSet_Unquekey_id
						   --,[Measurement_Uniquekey_id]
						   ,@CategoryId
						
						   ,1 -- 1 active and 0 for deleted.
						   ,@Tin
						   ,@Npi
						   ,@CmsYear
						  
						 
		end
		else
		begin
			--insert into tmp_raju values('update');
				update tbl_CI_Source_UniqueKeys
					   set 
					      Submission_Uniquekey_Id=@Submission_Uniquekey_Id,
						  MeasurementSet_Unquekey_id=@MeasurementSet_Unquekey_id,
						  IsMSetIdActive=1
						
					 
					   where
							 Category_Id=@CategoryId 
							 and CmsYear=@CmsYear 
							 and ISNULL(tin,'') =isnull(@Tin,'') 
							 and ISNULL(Npi,'')=ISNULL(@Npi,'')
							 and IsMSetIdActive=1
					
					    
		end
		   



END
