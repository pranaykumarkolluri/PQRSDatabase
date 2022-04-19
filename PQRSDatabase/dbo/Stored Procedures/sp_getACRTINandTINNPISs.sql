CREATE PROCEDURE [dbo].[sp_getACRTINandTINNPISs] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	declare @UserRelatedTINSNPIS table(
	TIN varchar(9),
	NPI varchar(10)
	)
	declare @UserRelatedTINS table(	
	TIN varchar(9)
	)
	insert into @UserRelatedTINS
			exec SPGetNpisofTin_VW 
	insert into @UserRelatedTINSNPIS
		select distinct TIN,null from @UserRelatedTINS

	insert into @UserRelatedTINSNPIS
	select distinct U.TIN,V.NPI from @UserRelatedTINS as U join PHYSICIAN_TIN_VW as V on V.TIN COLLATE Database_Default = U.TIN 

	select * from @UserRelatedTINSNPIS
END