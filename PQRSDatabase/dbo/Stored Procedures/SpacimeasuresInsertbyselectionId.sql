
-- =============================================
-- Author:		<Hari>
-- Create date: <07/03/2018>
-- Description:	<Insert aci measures based on SelectionId,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpacimeasuresInsertbyselectionId] 
	-- Add the parameters for the stored procedure here
@Tin as varchar(10),
@Npi as varchar(10),
@CMSYear as int,
@FacilityUsername as varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	declare @aciid int;

declare @Sel_id int;
declare @Sel_Scope_Id int;

select @aciid=ACI_Id ,@Sel_id=Selected_Id from tbl_ACI_Users where tin=@Tin and NPI=@Npi and CMSYear=@CMSYear
--print('id'+cast(@aciid as varchar))
insert into tbl_ACI_User_Measure_Type(ACI_Id,Updated_By,Updated_Datetime)

select @aciid,@FacilityUsername,GETDATE()

select @Sel_Scope_Id=SCOPE_IDENTITY() 
--print('Sel_Scope_Id'+cast(@Sel_Scope_Id as varchar))
--print('Sel_Scope_Id'+cast(@Sel_id as varchar))


insert into tbl_User_Selected_ACI_Measures
select [Selected_MeasureIds]
      ,[Updated_By]
      ,[Updated_Datetime]
      ,[Start_Date]
      ,[End_Date]
      ,@Sel_Scope_Id
      ,[CMSYear]
      ,[Numerator]
      ,[Denominator]
      ,[Attestion] from tbl_User_Selected_ACI_Measures where Selected_Id=@Sel_id

	  update tbl_ACI_Users set Selected_Id=@Sel_Scope_Id
	    where tin=@Tin and NPI=@Npi and CMSYear=@CMSYear

	 
END
