-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2019
-- Description:	Used to get IA Activities data
--@Role:   1--Facility  , 2--AcrStaff  ,3--Physician 
-- =============================================
CREATE PROCEDURE [dbo].[SPGetActivitieslist_IA_bak]	
    
	 @CMSYear int,	 
	 @Role int,
	  @Tin varchar(9)='', 
	 @Npi varchar(10)='',
	  @isGPRO bit=0,
	 @facilityusername varchar(50)=''
AS
BEGIN


declare @SelectedActivity varchar(max);
declare @SelectedID int;


IF(@Role=1)  --Facility Role Starts
BEGIN

		declare @FacilityPhysicianNPISTINS table(	
		first_name varchar(256),
		last_name varchar(256),
		npi varchar(10),
		tin varchar(9)
		,is_active bit, deactivation_date datetime
		)

		insert into @FacilityPhysicianNPISTINS
			exec sp_getFacilityPhysicianNPIsTINs @facilityusername



			IF(@isGPRO=1)
			BEGIN
				   select distinct @SelectedID=SelectedID from tbl_IA_Users where TIN=@Tin and CMSYear=@CMSYear

				   IF(@SelectedID>0)
				   BEGIN
						   select   @SelectedActivity=COALESCE(@SelectedActivity+', ' ,'') + SelectedActivity
						   from tbl_IA_User_Selected where SelectedID=@SelectedID
						  
				   END

					select distinct first_name,				
					 last_name,npi,tin,@SelectedActivity as SelectedActivity,@isGPRO as Gpro  from @FacilityPhysicianNPISTINS where tin=@Tin

			 END
		----------GPRO END-------------
		ELSE   ---NonGpro Starts
		BEGIN

				select distinct first_name,
				last_name, 
				t.npi,
				t.tin,
				dbo.fnGetCOALESCEByTinNpi(t.tin, t.npi,@CMSYear,2) AS SelectedActivity,
				@isGPRO as Gpro
				---s.SelectedActivity	

			from @FacilityPhysicianNPISTINS t LEFT join  tbl_IA_Users I on t.tin=i.TIN and t.npi=i.NPI and I.CMSYear=@CMSYear
			LEFT join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID  where t.tin=@Tin 


		END    ---NonGpro End
	
END   --Facility Role end




ELSE IF(@Role=2)  --ACRStaff Role Starts
BEGIN

declare @ACRStaffNpisbyTIN table(	
npi varchar(10),
first_name varchar(256),
last_name varchar(256),
tin varchar(9),
isgpro bit
)

insert into @ACRStaffNpisbyTIN
    exec sp_getNPIsOfTin @Tin


	IF(@isGPRO=1)
			BEGIN
				   select distinct @SelectedID=SelectedID from tbl_IA_Users where TIN=@Tin 
				                                                              and CMSYear=@CMSYear
																			  


				   IF(@SelectedID>0)
				   BEGIN
						   select   @SelectedActivity=COALESCE(@SelectedActivity+', ' ,'') + SelectedActivity
						   from tbl_IA_User_Selected where SelectedID=@SelectedID
						  
				   END

					select distinct first_name,				
					 last_name,npi,tin,@SelectedActivity as SelectedActivity,@isGPRO as Gpro from @ACRStaffNpisbyTIN 
					                                                                          where tin=@Tin 
																							   and ISNULL(npi,'')= case ISNULL(@Npi,'') when '' then npi else @Npi end 
					  

			 END
		----------GPRO END-------------
		ELSE   ---NonGpro Starts
		BEGIN

				select distinct first_name,
				last_name, 
				t.npi,
				t.tin,
				dbo.fnGetCOALESCEByTinNpi(t.tin, t.npi,@CMSYear,2) AS SelectedActivity,
				@isGPRO as Gpro
				---s.SelectedActivity	

			from @ACRStaffNpisbyTIN t LEFT join  tbl_IA_Users I on t.tin=i.TIN and t.npi=i.NPI 
			                                                                   and I.CMSYear=@CMSYear
			LEFT join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID  where t.tin=@Tin 
			                                                      and ISNULL(t.npi,'')= case ISNULL(@Npi,'') when '' then t.npi else @Npi end 


		END    ---NonGpro End


	
END   --ACRStaff Role end




ELSE IF(@Role=3)  --Physician Role Starts
BEGIN
 
			 IF(@Tin='')  --Physician IA Page
			 BEGIN
   
						   declare @PhysicianTins table(	
						tin varchar(9)
						)
						insert into @PhysicianTins
                        exec SPGetNpisofTin_VW @Npi

						select distinct '' as first_name,
						'' as last_name, 
						@Npi as npi,
						t.tin,
						dbo.fnGetCOALESCEByTinNpi(t.tin, @Npi,@CMSYear,2) AS SelectedActivity,
						g.is_GPRO as Gpro						
					from @PhysicianTins t LEFT join  tbl_IA_Users I on t.tin=i.TIN 
					                                           and i.NPI=@Npi 
															   and i.CMSYear=@CMSYear
					                      LEFT join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID  
										  LEFT join tbl_TIN_GPRO g on g.TIN=t.tin
					

			 END

			 ELSE  --CMSPhysician IA Page
			 BEGIN
   
                	select distinct '' as first_name,
						'' as last_name, 
						i.NPI as npi,
						@Tin as tin,
						dbo.fnGetCOALESCEByTinNpi(@Tin, @Npi,@CMSYear,2) AS SelectedActivity,
						@isGPRO as Gpro						
					from  tbl_IA_Users I join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID  										   
										   where i.CMSYear=@CMSYear and i.TIN=@Tin and i.NPI=@Npi




			 END





	
END   --Physician Role end






END

