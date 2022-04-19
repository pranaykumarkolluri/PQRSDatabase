﻿-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2019
-- Description:	Used to get IA Activities data
--@Role:   1--Facility  , 2--AcrStaff  ,3--Physician 
-- =============================================
CREATE PROCEDURE [dbo].[SPGetActivitieslist_IA]	
    
	 @CMSYear int,	 
	 @Role int,
	 @Category_Id int,
	  @Tin varchar(9)='', 
	 @Npi varchar(10)='',
	  @isGPRO bit=0,
	 @facilityusername varchar(50)='',
	 @Userid int=0
	 
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
		tin varchar(9),
		is_active bit, 
		deactivation_date datetime,
		is_enrolled bit
		)

		insert into @FacilityPhysicianNPISTINS
			exec sp_getFacilityPhysicianNPIsTINs @facilityusername,@Tin



			IF(@isGPRO=1)
			BEGIN
				   select distinct @SelectedID=SelectedID from tbl_IA_Users where TIN=@Tin and CMSYear=@CMSYear

				   IF(@SelectedID>0)
				   BEGIN
						   select   @SelectedActivity=COALESCE(@SelectedActivity+', ' ,'') + SelectedActivity
						   from tbl_IA_User_Selected where SelectedID=@SelectedID
						  
				   END

				           IF(@CMSYear<=2017)
										select distinct 
								first_name as Firstname,				
									last_name as Lastname,
									f.npi as NPI,
									f.tin as Tin,
									@SelectedActivity as SelectedActivites,
									@isGPRO as isGpro,
							 CASE WHEN (I.FinalizeEmail IS NULL OR I.FinalizeEmail='') THEN (Select top 1 GPROTIN_EmailAddress from tbl_GPRO_TIN_EmailAddresses where Tin_CMSAttestYear=@CMSYear and CreatedBy =@Userid)
							 else I.FinalizeEmail end as emailid,							  
								I.isFinalize as isFinalize,
								I.FinalizeAgreeTime as finalizeAgreeDate,
								I.FinalizeDisagreeTime as finalizeDisAgreeDate,
								 0 as isSubmitToCI,
								'' as LastSubmittedDateTime,
								@CMSYear as CMSYear 
									from @FacilityPhysicianNPISTINS f left join tbl_CMS_IA_Finalization I
									on f.tin=i.TIN and f.npi=i.NPI and i.Finalize_Year=@CMSYear and i.isGpro=@isGPRO
									where f.tin=@Tin
						   ELSE
						   BEGIN
						   	declare @isSubmittoCMS bit
	                        declare @LastSubmittedDate varchar(50)



								 select @isSubmittoCMS=count(*) 
								 --Sk.Submission_Uniquekey_Id, Sk.MeasurementSet_Unquekey_id
							--select * from
							from  tbl_CI_Source_UniqueKeys Sk 


							where sk.Tin=@Tin
							and ISNULL(sk.Npi,'')= case ISNULL(@Npi,'') when '' then '' else @Npi end 
							 and sk.CmsYear=@CmsYear 
							 and Sk.Category_Id=@Category_Id
							 and sk.IsMSetIdActive=1
							-- order by sk.[Key_Id] desc

							select @LastSubmittedDate=res.CreatedDate from tbl_CI_RequestData req join tbl_CI_ResponseData res on
							req.Request_Id=res.Request_Id join tbl_CI_Source_UniqueKeys keys on keys.Tin=req.Tin

							where req.Tin=@Tin 

							and ISNULL(req.Npi,'')= case ISNULL(@Npi,'') when '' then '' else @Npi end 
							and req.Category_Id=@Category_Id
							and res.Method_Id in(5,6,12)
							and res.Status='success'
							and keys.IsMSetIdActive=1
								select distinct 
								first_name as Firstname,				
									last_name as Lastname,
									npi as NPI,
									tin as Tin,
									@SelectedActivity as SelectedActivites,
									@isGPRO as isGpro,
								'' as emailid,
								0 as isFinalize,
								'' as finalizeAgreeDate,
								'' as finalizeDisAgreeDate,
								'' as isSubmitToCI,
								'' as LastSubmittedDateTime,
								@CMSYear as CMSYear 
									from @FacilityPhysicianNPISTINS where tin=@Tin
					 END

			 END
		----------GPRO END-------------
		ELSE   ---NonGpro Starts
		BEGIN

				select distinct 
				first_name as Firstname,				
			    last_name as Lastname,
			    t.npi as NPI,
			    t.tin as Tin,
				dbo.fnGetCOALESCEByTinNpi(t.tin, t.npi,@CMSYear,2) as SelectedActivites,
				 @isGPRO as isGpro,
				'' as emailid,
				'' as isFinalize,
				'' as finalizeAgreeDate,
				'' as finalizeDisAgreeDate,
				'' as isSubmitToCI,
				'' as LastSubmittedDateTime,
				'' as CMSYear  
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

					select distinct first_name as Firstname,				
					 last_name as Lastname,
					 npi as NPI,
					 tin as Tin,
					 @SelectedActivity as SelectedActivites,
					@isGPRO as isGpro,
					'' as emailid,
					'' as isFinalize,
					'' as finalizeAgreeDate,
					'' as finalizeDisAgreeDate,
					'' as isSubmitToCI,
					'' as LastSubmittedDateTime,
					'' as CMSYear 

					 from @ACRStaffNpisbyTIN  where tin=@Tin and ISNULL(npi,'')= case ISNULL(@Npi,'') when '' then npi else @Npi end 
					  

			 END
		----------GPRO END-------------
		ELSE   ---NonGpro Starts
		BEGIN

				select distinct first_name as Firstname,
				last_name  as Lastname, 
				t.npi as NPI,
				t.tin  as Tin,
				dbo.fnGetCOALESCEByTinNpi(t.tin, t.npi,@CMSYear,2) AS SelectedActivites,
				 @isGPRO as isGpro,
				'' as emailid,
				'' as isFinalize,
				'' as finalizeAgreeDate,
				'' as finalizeDisAgreeDate,
				'' as isSubmitToCI,
				'' as LastSubmittedDateTime,
				'' as CMSYear 	

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

						select distinct '' as Firstname,
						'' as Lastname, 
						@Npi as NPI,
						t.tin as Tin,
						dbo.fnGetCOALESCEByTinNpi(t.tin, @Npi,@CMSYear,2) AS SelectedActivites,
						 @isGPRO as isGpro,
						'' as emailid,
						'' as isFinalize,
						'' as finalizeAgreeDate,
						'' as finalizeDisAgreeDate,
						'' as isSubmitToCI,
						'' as LastSubmittedDateTime,
						'' as CMSYear 						
					from @PhysicianTins t LEFT join  tbl_IA_Users I on t.tin=i.TIN 
					                                           and i.NPI=@Npi 
															   and i.CMSYear=@CMSYear
					                      LEFT join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID  
										  LEFT join tbl_TIN_GPRO g on g.TIN=t.tin
					

			 END

			 ELSE  --CMSPhysician IA Page
			 BEGIN
   
                	select distinct '' as Firstname,
						'' as Lastname, 
						i.NPI as NPI,
						@Tin as Tin,
						dbo.fnGetCOALESCEByTinNpi(@Tin, @Npi,@CMSYear,2) AS SelectedActivites,
						 @isGPRO as isGpro,
						'' as emailid,
						'' as isFinalize,
						'' as finalizeAgreeDate,
						'' as finalizeDisAgreeDate,
						'' as isSubmitToCI,
						'' as LastSubmittedDateTime,
						'' as CMSYear 						
					    from  tbl_IA_Users I join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID  										   
										   where i.CMSYear=@CMSYear and i.TIN=@Tin and i.NPI=@Npi




			 END





	
END   --Physician Role end






END

