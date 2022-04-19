-- =============================================
-- Author:		<Sumanth>
-- Create date: <16-Jan-2019>
-- Description:	<Used to get physician attestation Status>
-- =============================================
CREATE PROCEDURE [dbo].[SPAttestation_PhysicianDetails]
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
--set @PhyEmail='raz@gmail.com'

Declare @Physicantinscount int;
Declare @ExistedPhysicantinscount int;

DECLARE @PhyTins table (Tin varchar(9)) 

DECLARE @ATTESTEDBY int;
DECLARE @ATTESTEDUSERNAME varchar(200);
DECLARE @ATTESTED_DATE DATETIME;
DECLARE @IsPhyNonGproTinExists bit;

set @IsPhyNonGproTinExists=0;

insert @PhyTins select distinct TIN from NRDR..PHYSICIAN_TIN_VW  where NPI= @NPI

select  @Physicantinscount= count(distinct t.Tin) from @PhyTins t inner join tbl_tin_gpro g on t.Tin=g.TIN where g.is_GPRO=0

print('@Physicantinscount'+Convert(varchar(50),@Physicantinscount))
if(@Cmsyear<2020)
Begin
select  @ExistedPhysicantinscount =COUNT(distinct t.Tin) from @PhyTins t inner join tbl_tin_gpro g on t.Tin=g.TIN where g.is_GPRO=0
 and t.Tin  in(select Tin from tbl_CMS_Attestation_Year where PhysicianNPI=@NPI and TIN=t.Tin and CMSAttestYear=@Cmsyear and IsAttested=1)
end
else
begin
select  @ExistedPhysicantinscount =COUNT(distinct t.Tin) from @PhyTins t inner join tbl_tin_gpro g on t.Tin=g.TIN where g.is_GPRO=0
 and t.Tin  in(select Tin from tbl_CMS_Attestation_Year where PhysicianNPI=@NPI and TIN=t.Tin and CMSAttestYear=@Cmsyear and AttestedBy=@userid and IsAttested=1)

end


 print('@Physican exists tinscount'+Convert(varchar(50),@ExistedPhysicantinscount))
 set @IsNewTinsforNpi=0;
 if(@Physicantinscount>@ExistedPhysicantinscount )
 begin
 set @IsNewTinsforNpi=1
 end
 if(@Physicantinscount <=@ExistedPhysicantinscount and @ExistedPhysicantinscount<>0 )

 begin
 set @ATTESTATION_STATUS=1;
 end
 else if(@Physicantinscount=0)
 begin 
 set @ATTESTATION_STATUS=0;
 end

 if(@IsNewTinsforNpi=1)
 begin
 set @ATTESTATION_STATUS=0;

 end

 if(@Physicantinscount>0)
 begin
 set @IsPhyNonGproTinExists=1;
 end


--IF NOT EXISTS
--	(
--select * from @PhyTins t inner join tbl_tin_gpro g on t.Tin=g.TIN where g.is_GPRO=0
-- and t.Tin not in(select Tin from tbl_CMS_Attestation_Year where PhysicianNPI=@NPI and CMSAttestYear=@Cmsyear and IsAttested=1))
--begin
--  set @ATTESTATION_STATUS=1;
--end

--else
--begin
--set @ATTESTATION_STATUS=0;
--end

if(@Cmsyear<2020)
begin

select  top 1 @PhyEmail= Isnull(A.Email,'') , @ATTESTEDBY=ISNULL(A.AttestedBy,0),@ATTESTED_DATE=A.Attestation_Agree_Time from @PhyTins t inner join tbl_tin_gpro g on t.Tin=g.TIN
inner join tbl_CMS_Attestation_Year A on A.TIN =t.Tin
 where g.is_GPRO=0 and A.PhysicianNPI=@NPI and A.CMSAttestYear=@Cmsyear and A.IsAttested=1 order by A.Attestation_Agree_Time desc

select top 1 @ATTESTEDUSERNAME= case when ISnull(FirstName,'') <>'' and  ISNULL(LastName,'')<>'' then ISnull(FirstName,'')+' '+ ISNULL(LastName,'') else isnull(UserName,'') end from tbl_Users where UserID=@ATTESTEDBY

end 
else
begin

select  top 1 @PhyEmail= Isnull(A.Email,'') , @ATTESTEDBY=ISNULL(A.AttestedBy,0),@ATTESTED_DATE=A.Attestation_Agree_Time from @PhyTins t inner join tbl_tin_gpro g on t.Tin=g.TIN
inner join tbl_CMS_Attestation_Year A on A.TIN =t.Tin
 where
  g.is_GPRO=0 
  and A.PhysicianNPI=@NPI 
  and A.CMSAttestYear=@Cmsyear 
 and A.IsAttested=1
 and a.AttestedBy=@userid
  order by A.Attestation_Agree_Time desc

select top 1 @ATTESTEDUSERNAME= case when ISnull(FirstName,'') <>'' and  ISNULL(LastName,'')<>'' then ISnull(FirstName,'')+' '+ ISNULL(LastName,'') else isnull(UserName,'') end, @PhyEmail=EMail_Address from tbl_Users where UserID=@ATTESTEDBY

end

--if (@ATTESTATION_STATUS=0) and (select count(*) from tbl_CMS_Attestation_Year where PhysicianNPI=@NPI and CMSAttestYear=@Cmsyear)



SELECT @ATTESTATION_STATUS as IsAttested,@IsNewTinsforNpi as IsNewTins,@PhyEmail as Email, @ATTESTEDUSERNAME AS AttestedBy,
 @ATTESTED_DATE as AttestedDate,@IsPhyNonGproTinExists as IsNonGproTinExists
end 



