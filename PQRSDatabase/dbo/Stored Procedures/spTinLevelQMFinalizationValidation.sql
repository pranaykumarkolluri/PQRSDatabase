-- =============================================
-- Author:		Raju Gaddam
-- Create date: Feb 28, 2018
-- Description:	CMS TinLevel Attestation and Finalization Validation
-- =============================================
CREATE PROCEDURE [dbo].[spTinLevelQMFinalizationValidation]
	-- Add the parameters for the stored procedure here
@TIN varchar(10),
@CMSYear int,
@is90days bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
--Step #1 tin level attestation validation
if(@is90days =0)
	begin
		select case
		when (select COUNT(*) 
		from  tbl_GPRO_TIN_EmailAddresses where GPROTIN =@TIN 
		and Tin_CMSAttestYear=@CMSYear and IsAttested=1)=0 then 1


		--Step #2 Measure validation
		when (select count(*) from tbl_GPRO_TIN_Selected_Measures where TIN=@TIN
		and Submission_year=@CMSYear and SelectedForSubmission = 1) =0 then 5
		else 0 end as  validationvalue

	end 
	else 
	begin 
		select case
		when (select COUNT(*) 
		from  tbl_GPRO_TIN_EmailAddresses where GPROTIN =@TIN 
		and Tin_CMSAttestYear=@CMSYear and IsAttested=1)=0 then 1


		--Step # Measure validation
		when (select count(*) from tbl_GPRO_TIN_Selected_Measures_90days where TIN=@TIN
		and Submission_year=@CMSYear and SelectedForSubmission = 1 ) =0 then 5
		else 0 end as  validationvalue
	end 

END
