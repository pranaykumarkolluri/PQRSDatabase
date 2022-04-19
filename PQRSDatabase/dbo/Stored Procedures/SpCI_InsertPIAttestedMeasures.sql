-- =============================================
-- Author:		HAri & Sumanth
-- Create date: 27-Nov-18
-- Description:	used to Delete/insert default aci measures while attestation

-- JIRA#785 by raju g
-- =============================================
CREATE PROCEDURE [dbo].[SpCI_InsertPIAttestedMeasures]
 @TIN varchar(10),
 @CMSYear int,
 @UserName varchar(50),
 --@isGPRO bit,
 @NPI varchar(50)=''
AS
BEGIN

     /*
          --Delete
    declare @SelectionId as int		    
		   		  
	        select distinct  @SelectionId= Selected_Id from tbl_ACI_Users 
	        where tin=@TIN 
		    and CMSYear=@CMSYear
			and NPI= 
			case ISNULL(@NPI,'') when '' then NPI else @NPI end 		   		                                                                                                                              		 		    
       --If ((Select count(*) from @SelectionIds) > 0)
	  -- BEGIN
	  if(@CMSYear<2018)
	  begin
		   delete from tbl_User_Selected_ACI_Measures
		   where [Selected_MeasureIds] in ('ACI_INFBLO_1','ACI_ONCDIR_1')
		   and [Selected_Id]=@SelectionId
		   end
		   else
		   begin
		    delete from tbl_User_Selected_ACI_Measures
		   where [Selected_MeasureIds] in ('PI_INFBLO_1','PI_ONCDIR_1')
		   and [Selected_Id]=@SelectionId
		   end
		--END

		--Insert

		If ( @SelectionId > 0  and @CMSYear<2018)
	   BEGIN
		   insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

		select 'ACI_INFBLO_1',@UserName,GETDATE(),@SelectionId,@CMSYear,1 
		 
		 insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

		select 'ACI_ONCDIR_1',@UserName,GETDATE(),@SelectionId,@CMSYear,1 
		END

		else if(@SelectionId > 0)
		begin
		insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

		select 'PI_INFBLO_1',@UserName,GETDATE(),@SelectionId,@CMSYear,1 
		 
		 insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

		select 'PI_ONCDIR_1',@UserName,GETDATE(),@SelectionId,@CMSYear,1 
		end

		*/

		 declare @SelectionId as int		    
		   
		   --JIRA#785
		   if(ISNULL(@NPI,'') !='')
		   begin
		   	  
	        select distinct  @SelectionId= Selected_Id from tbl_ACI_Users 
	        where tin=@TIN 
		    and CMSYear=@CMSYear
			and NPI= @NPI
			--and  NPI is not null
			--case ISNULL(@NPI,'') when '' then NPI else @NPI end 
		   end
		   else
		   Begin 

		             select distinct  @SelectionId= Selected_Id from tbl_ACI_Users 
	        where tin=@TIN 
		    and CMSYear=@CMSYear
			and ((@CMSYear>=2020 and IsGpro=1 ) or @CMSYear<2020 ) 
		   end

		   
		  -- JIRA#785 
			  
	 

			delete M from  tbl_User_Selected_ACI_Measures M join tbl_Lookup_ACI_Data A
			on M.Selected_MeasureIds=A.MeasureId
			 and M.CMSYear=A.CMSYear
			where A.ACI_Id=3
		   --where [M.Selected_MeasureIds] in ('ACI_INFBLO_1','ACI_ONCDIR_1')
		   and [Selected_Id]=@SelectionId

		   insert into tbl_User_Selected_ACI_Measures
		([Selected_MeasureIds]
           ,[Updated_By]
           ,[Updated_Datetime]       
           ,[Selected_Id]
           ,[CMSYear]          
           ,[Attestion])

	select MeasureId,@UserName,GETDATE(),@SelectionId,@CMSYear,1 from tbl_Lookup_ACI_Data where ACI_Id=3 and CMSYear=@CMSYear  --ACI_Id=3 Attested Measures

END

