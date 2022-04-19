-- =============================================
-- Author:		HAri & Sumanth
-- Create date: 01-Mar-18
-- Description:	used to insert default aci measures while finalization
--change #1: Sumanth 19/7/2018
--Description: In 2018 ACI renamed as PI

--Change#1 By: Raju G 
--Change#1:JIRA-785
-- =============================================
CREATE PROCEDURE [dbo].[SpInsertACIAssestedMeasures]
 @TIN varchar(10),
 @CMSYear int,
 @UserName varchar(50),
 @isGPRO bit,
 @NPI varchar(50)=''
AS
BEGIN
/*
	  declare @SelectionIds table(sel_Id int)
	  if(@isGPRO=1)
	  Begin
	   insert into @SelectionIds
	   select distinct Selected_Id from tbl_ACI_Users 
	    where tin=@TIN 
		and CMSYear=@CMSYear
		--AND NPI=@NPI
		END
		ELse
		begin 
		insert into @SelectionIds
	    select distinct Selected_Id from tbl_ACI_Users 
	    where tin=@TIN 
		and CMSYear=@CMSYear
		AND NPI=@NPI
		end
		 
		-- change #1
		if(@CMSYear < 2018)
		begin

		If ((Select count(*) from @SelectionIds) > 0)
	   BEGIN
		insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

		select 'ACI_INFBLO_1',@UserName,GETDATE(),sel_Id,@CMSYear,1 from @SelectionIds
		 
		 insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

		select 'ACI_ONCDIR_1',@UserName,GETDATE(),sel_Id,@CMSYear,1 from @SelectionIds
		 
		END
		end

		else
		begin

		If ((Select count(*) from @SelectionIds) > 0)
	   BEGIN
		insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

		select 'PI_INFBLO_1',@UserName,GETDATE(),sel_Id,@CMSYear,1 from @SelectionIds
		select MeasureId ,'administrator_100210',GETDATE(),1284,2019,1 from tbl_Lookup_ACI_Data where ACI_Id=3 and CMSYear=2019 
		--select (select MeasureId from tbl_Lookup_ACI_Data where ACI_Id=3),@UserName,GETDATE(),sel_Id,@CMSYear,1 from @SelectionIds
		 
		 insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

		select 'PI_ONCDIR_1',@UserName,GETDATE(),sel_Id,@CMSYear,1 from @SelectionIds
		 
		END
		end

	  */ 
	  Declare @SelectionId int

	   if(@isGPRO=1)
	      BEGIN
	        select top 1 @SelectionId=Selected_Id from tbl_ACI_Users 
	    where tin=@TIN 
		and CMSYear=@CMSYear 
		and ((@CMSYear >=2020 and IsGpro=1) or @CMSYear <2020 )  ----Change#1
		order by Selected_Id desc
		 			

		  END
		ELSE
		    BEGIN 

     select top 1 @SelectionId=Selected_Id from tbl_ACI_Users 
	    where tin=@TIN 
		and CMSYear=@CMSYear 
		and NPI=@NPI
		and NPI is not null  --Change#1
		order by Selected_Id desc

		    END
			insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

	select MeasureId,@UserName,GETDATE(),@SelectionId,@CMSYear,1 from tbl_Lookup_ACI_Data where ACI_Id=3 and CMSYear=@CMSYear    --ACI_Id=3 Attested Measures

END



