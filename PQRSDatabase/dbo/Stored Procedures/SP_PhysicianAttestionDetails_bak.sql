
-- =============================================
-- Author:		<Sumanth>
-- Create date: <16-Jan-2019>
-- Description:	<Used to get physician attestation Status>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PhysicianAttestionDetails_bak]
	-- Add the parameters for the stored procedure here
	@userid int,
	@NPI varchar(10),
	@Cmsyear int
AS
BEGIN

 Declare @ATTESTATION_STATUS  Bit;

	SET @ATTESTATION_STATUS  =0;

Declare @IsNewTinsforNpi bit;
SET @IsNewTinsforNpi  =0;

Declare @PhyEmail varchar(50);
set @PhyEmail='raz@gmail.com'

DECLARE @PhyTins table (Tin varchar(9)) 

insert @PhyTins select distinct TIN from NRDR..PHYSICIAN_TIN_VW  where NPI= @NPI

IF NOT EXISTS
	(
select * from @PhyTins t inner join tbl_tin_gpro g on t.Tin=g.TIN where g.is_GPRO=0
 and t.Tin not in(select Tin from tbl_CMS_Attestation_Year where PhysicianNPI=@NPI and CMSAttestYear=@Cmsyear and IsAttested=1))
begin
  set @ATTESTATION_STATUS=1;
end

else
begin
set @ATTESTATION_STATUS=0;
end

--if (@ATTESTATION_STATUS=0) and (select count(*) from tbl_CMS_Attestation_Year where PhysicianNPI=@NPI and CMSAttestYear=@Cmsyear)

SELECT @ATTESTATION_STATUS as IsAttested,@IsNewTinsforNpi as IsNewTins,@PhyEmail as Email
end 

