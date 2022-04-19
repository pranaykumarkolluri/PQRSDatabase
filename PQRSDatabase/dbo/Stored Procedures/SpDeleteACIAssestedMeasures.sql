-- =============================================
-- Author:		HAri & Sumanth
-- Create date: 01-Mar-18
-- Description:	used to delete default aci measures while Unfinalization
--Change #1: Sumanth 19/7/2018
--Description: In 2018 ACI renamed as PI
-- =============================================
CREATE PROCEDURE [dbo].[SpDeleteACIAssestedMeasures]
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
		
		--change #1
		if(@CMSYear < 2018)
		begin
		 If ((Select count(*) from @SelectionIds) > 0)
	   BEGIN
		delete from tbl_User_Selected_ACI_Measures
		where [Selected_MeasureIds] in ('ACI_INFBLO_1','ACI_ONCDIR_1')
		and [Selected_Id] in (select sel_Id from @SelectionIds)
 
		END
		end

		else
		begin
		 If ((Select count(*) from @SelectionIds) > 0)
	   BEGIN
		delete from tbl_User_Selected_ACI_Measures
		where [Selected_MeasureIds] in ('PI_INFBLO_1','PI_ONCDIR_1')
		and [Selected_Id] in (select sel_Id from @SelectionIds)
 
		END
		end

	  */

	  declare @SelectionId int
	  if(@isGPRO=1)
	  Begin
	   
	   select distinct @SelectionId= Selected_Id from tbl_ACI_Users 
	    where tin=@TIN 
		and CMSYear=@CMSYear
		--AND NPI=@NPI
		END
		ELse
		begin 
		
	    select distinct @SelectionId= Selected_Id from tbl_ACI_Users 
	    where tin=@TIN 
		and CMSYear=@CMSYear
		AND NPI=@NPI
		end

		delete from tbl_User_Selected_ACI_Measures
		where [Selected_MeasureIds] in (select MeasureId from tbl_Lookup_ACI_Data where CMSYear=@CMSYear and ACI_Id=3)       --ACI_Id=3 Attested Measures
		and [Selected_Id]=@SelectionId
END

