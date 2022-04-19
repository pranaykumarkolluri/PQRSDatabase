-- =============================================
-- Author:		<Sumanth>
-- Create date: <16-Jan-2019>
-- Description:	<Used to insert physician attested Tins>
-- =============================================
CREATE PROCEDURE [dbo].[SPAttestation_InsertPhysicianData] 
	-- Add the parameters for the stored procedure here
	@userid int,
	@NPI varchar(10),
	@Cmsyear int,
	@Email varchar(50)

AS
BEGIN
--SET NOCOUNT ON;
DECLARE @PhyTins table (Tin varchar(9)) 

insert @PhyTins select distinct TIN from NRDR..PHYSICIAN_TIN_VW  where NPI= @NPI


INSERT INTO [dbo].[tbl_CMS_Attestation_Year]
           ([CMSAttestYear]
           ,[PhysicianNPI]
           ,[IsAttested]
           ,[Attestation_Agree_Time]         
           ,[AttestedBy]
           ,[Email]
           ,[TIN])
         
		   select distinct 
		   @Cmsyear,
		   @NPI,
		   1,
		   getdate(),
		   @userid,
		   @Email,
		   t.Tin
		   from 
		  @PhyTins t inner join tbl_tin_gpro g on t.Tin=g.TIN where g.is_GPRO=0
          and t.Tin not in(select Tin from tbl_CMS_Attestation_Year  where
		   PhysicianNPI=@NPI and 
		   CMSAttestYear=@Cmsyear and
		   IsAttested=1 and tin is not null)
return @@ROWCOUNT

end 



