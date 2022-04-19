

 CREATE PROCEDURE [dbo].[sp_getFacilityAdminNPIs] 

	-- Add the parameters for the stored procedure here

	

	--@UserID nvarchar(50) ,

	--@RegistryName varchar(50)= '

	

	@Nrdr_Facility_id as varchar(25)

AS

BEGIN



    -- Insert statements for procedure here

	--select TIN,REGISTRY_NAME,TIN_DESCRIPTION from tbl_TINNumbers 

	--where NPI = @NPI 

	--and REGISTRY_NAME =  case upper(@RegistryName) when 'All' then REGISTRY_NAME else REGISTRY_NAME end

	

	--select UserID, PhysicianNPI,FacilityID from dbo.tbl_FacilityManaged_NPI_List

	--where Userid = @UserID

	

	SET NOCOUNT ON;

	

	

	

	declare @FacilityNPIs table (Physician_first_name nvarchar(50),

						physician_last_name Nvarchar(50),

						Physician_NPI nvarchar(256))



  insert @FacilityNPIs (Physician_first_name,physician_last_name,Physician_NPI)

  EXEC nrdr..[sp_getFacilityPhysicianNPIs] @Nrdr_Facility_id--,'ALL' 

  

  set nocount off

  select * from @FacilityNPIs

  

  return @@rowCount;

	

	

END

