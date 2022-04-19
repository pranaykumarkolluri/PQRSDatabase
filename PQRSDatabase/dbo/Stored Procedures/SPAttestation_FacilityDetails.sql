-- =============================================
-- Author:		Raju Gaddam
-- Create date: Jan-11-2018
-- Description:	Facility Attestation Details
-- =============================================
CREATE PROCEDURE [dbo].[SPAttestation_FacilityDetails]
	-- Add the parameters for the stored procedure here
@UserId int,
@CmsYear int,
@ISEmailAddrRequire bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
DECLARE @UserName VARCHAR(50);
DECLARE  @FacilityTins table(TIN  VARCHAR(9),IS_GPRO bit)
--DECLARE @FacilityNPIs table(first_name VARCHAR(50),last_name VARCHAR(50),npi VARCHAR(10))

DECLARE @GPRO_ATTESTATION_STATUS  Bit;
DECLARE @NONGPRO_ATTESTATION_STATUS  Bit;
DECLARE @ATTESTATION_STATUS  Bit;
DECLARE @TINsNPIsNewExists Bit;
DECLARE @EMAILADDR  varchar(50);

DECLARE @FACILITYTINS_COUNT  INT;
DECLARE @FACILITYTINS_NPIS_COUNT  INT;
DECLARE @FACILITY_EXISTED_TINS_COUNT  INT;
DECLARE @FACILITY_EXISTED_TINS_NPIS_COUNT  INT;

DECLARE @ATTESTEDBY int;
DECLARE @ATTESTEDUSERNAME varchar(200);
DECLARE @ATTESTED_DATE DATETIME
DECLARE @ISTinsNPIsAvaliable bit

DECLARE @FacilityGproTinsExisted bit;
DECLARE @FacilityNonGproNpisExisted bit;
DECLARE @FACILITYTINS_NPIS TABLE(first_name varchar(100),lastname varchar(100),npi varchar(11),tin varchar(10),is_active bit, deactivation_date datetime,is_enrolled bit)

DECLARE @GPROAgreeTime datetime;
DECLARE @NonGPROAgreeTime datetime;

DECLARE @GPROEmail varchar(50);
DECLARE @NonGPROEmail  varchar(50);

DECLARE @GPROAttestedBy int;
DECLARE @NonGPROAttestedBy int;


SET  @GPRO_ATTESTATION_STATUS  =0;
SET @NONGPRO_ATTESTATION_STATUS  =0;
SET @ATTESTATION_STATUS  =0;
SET @TINsNPIsNewExists =0;

SET @FacilityGproTinsExisted=0;
SET @FacilityNonGproNpisExisted=0;

SET @ISTinsNPIsAvaliable=0;

SET @EMAILADDR='';
SET @ATTESTED_DATE=NULL;
SET @ATTESTEDBY=0;

SELECT top 1 @UserName=UserName FROM tbl_Users WHERE UserID=@UserId 


INSERT into @FacilityTins EXEC sp_getFacilityTIN_GPRO @UserName
-- INSERT INTO @FACILITYTINS_NPIS EXEC sp_getFacilityPhysicianNPIsTINs  @UserName
if not exists( select  *
	        
		    from  @FacilityTins F 
			--INNER JOIN
			---tbl_GPRO_TIN_EmailAddresses GT ON 
			--F.TIN=GT.GPROTIN
			 where
			
		   -- AND GT.Tin_CMSAttestYear=@CmsYear
			-- Gt.IsAttested=1
			F.TIN not in(select distinct GPROTIN from tbl_GPRO_TIN_EmailAddresses
				where Tin_CMSAttestYear=@CmsYear and IsAttested=1 and AttestedBy=@UserId)
				)
				Begin
				set @ATTESTATION_STATUS= 1
				end

else
begin
	set @ATTESTATION_STATUS= 0
end



if(@CmsYear <2020)
Begin
 if exists( select Top 1 * from @FacilityTins F where is_GPRO=1)
 Begin
 SET @FacilityGproTinsExisted=1;
 end

  if exists( select  distinct F.Npi from @FACILITYTINS_NPIS F inner join tbl_TIN_GPRO T on T.TIN=F.TIN where T.is_GPRO=0)
 Begin
 SET @FacilityNonGproNpisExisted=1;
 end

 IF (@FacilityGproTinsExisted=1)
 BEGIN
  if not exists( select  *
	        
		    from  @FacilityTins F 
			--INNER JOIN
			---tbl_GPRO_TIN_EmailAddresses GT ON 
			--F.TIN=GT.GPROTIN
			 where
			 F.is_GPRO=1 and
		   -- AND GT.Tin_CMSAttestYear=@CmsYear
			-- Gt.IsAttested=1
			F.TIN not in(select distinct GPROTIN from tbl_GPRO_TIN_EmailAddresses
				where Tin_CMSAttestYear=@CmsYear and IsAttested=1)
				)
				Begin
				set @GPRO_ATTESTATION_STATUS= CASE WHEN @FacilityGproTinsExisted=1 THEN 1 ELSE 0 END
				end
END


IF(@FacilityNonGproNpisExisted=1)
BEGIN
 if not exists ( select	*      from
			
			(
			select distinct f.tin,f.npi from @FACILITYTINS_NPIS F INNER JOIN
			tbl_TIN_GPRO T on T.TIN=F.TIN 
			--INNER JOIN
			--tbl_CMS_Attestation_Year GT ON 
			--F.TIN=GT.TIN
			 where
			 T.is_GPRO=0 and
			 --and Gt.IsAttested=1
		    --AND GT.CMSAttestYear=@CmsYear
			--AND GT.PhysicianNPI=f.npi)
			not exists
			(
			select distinct GT.TIN,GT.PhysicianNPI from tbl_CMS_Attestation_Year GT where GT.TIN=f.tin and gt.PhysicianNPI=f.npi 
			and IsAttested=1 and CMSAttestYear=@CmsYear 
			--F.TIN=GT.TIN
			))
			as t
			)
Begin

set @NONGPRO_ATTESTATION_STATUS=CASE WHEN @FacilityNonGproNpisExisted=1 THEN 1 ELSE 0 END; 
end
END


SET @ATTESTATION_STATUS = 
CASE WHEN @FacilityGproTinsExisted=1 AND @FacilityNonGproNpisExisted=1 AND @GPRO_ATTESTATION_STATUS=1 and @NONGPRO_ATTESTATION_STATUS=1  THEN 1
WHEN  @FacilityGproTinsExisted=1 AND @FacilityNonGproNpisExisted=0 AND @GPRO_ATTESTATION_STATUS=1  THEN 1
WHEN  @FacilityGproTinsExisted=1 AND @FacilityNonGproNpisExisted=0 AND @GPRO_ATTESTATION_STATUS=1  THEN 1 
WHEN  @FacilityGproTinsExisted=0 AND @FacilityNonGproNpisExisted=1 AND @NONGPRO_ATTESTATION_STATUS=1  THEN 1 
ELSE 0 END



SET @TINsNPIsNewExists=0;

--DECLARE @GPROAgreeTime datetime;
--DECLARE @NonGPROAgreeTime datetime;

--DECLARE @GPROEmail varchar(50);
--DECLARE @NonGPROEmail  varchar(50);

--DECLARE @GPROAttestedBy int;
--DECLARE @NonGPROAttestedBy int;


IF(@FacilityGproTinsExisted=1 AND @ISEmailAddrRequire=1)
BEGIN
print('1');

 SELECT TOP 1 @GPROEmail= ISNULL(GT.GPROTIN_EmailAddress,''),
 @GPROAgreeTime=GT.Attestation_Agree_Time ,@GPROAttestedBy=GT.AttestedBy  from  @FacilityTins F 
			INNER JOIN
			tbl_GPRO_TIN_EmailAddresses GT ON 
			F.TIN=GT.GPROTIN
			 where
			 F.is_GPRO=1
		    AND GT.Tin_CMSAttestYear=@CmsYear
			AND GT.IsAttested=1
			--AND GT.PhysicianNPI=f.npi 
			ORDER BY GT.Attestation_Agree_Time DESC

			print('GproEmail='+Convert(varchar(50),@GPROEmail))

END
 IF(@FacilityNonGproNpisExisted=1 AND @ISEmailAddrRequire=1)
BEGIN

print('2');
 SELECT TOP 1 @NonGPROEmail= ISNULL(GT.Email,''),
 @NonGPROAgreeTime=GT.Attestation_Agree_Time ,@NonGPROAttestedBy=GT.AttestedBy  from  @FACILITYTINS_NPIS F INNER JOIN
			tbl_TIN_GPRO T on T.TIN=F.TIN 
			INNER JOIN
			tbl_CMS_Attestation_Year GT ON 
			F.TIN=GT.TIN and F.npi=gt.PhysicianNPI
			 where
			 T.is_GPRO=0
		    AND GT.CMSAttestYear=@CmsYear
			AND GT.IsAttested=1
			--AND GT.PhysicianNPI=f.npi 
			ORDER BY GT.Attestation_Agree_Time DESC
END




SET @ISTinsNPIsAvaliable =CASE WHEN ISNULL(@FacilityGproTinsExisted,0)=0 AND ISNULL(@FacilityNonGproNpisExisted,0)=0 THEN 0 ELSE 1 END;

if(isnull(@GPROAgreeTime,'01-01-1800') >=  ISNULL(@NonGPROAgreeTime,'01-01-1800'))
begin
print('2');
		if(@GPROAgreeTime is not null)
		Begin
		print('3');
		set @EMAILADDR=@GPROEmail
		set @ATTESTED_DATE=@GPROAgreeTime
		set @ATTESTEDBY=@GPROAttestedBy
		end
end
else
begin

		if(@NonGPROAgreeTime is not null)
		Begin
		print('3');
		set @EMAILADDR=@NonGPROEmail
		set @ATTESTED_DATE=@NonGPROAgreeTime
		set @ATTESTEDBY=@NonGPROAttestedBy
		end	
end

select top 1 @ATTESTEDUSERNAME= case when ISnull(FirstName,'') <>'' and  ISNULL(LastName,'')<>'' then ISnull(FirstName,'')+' '+ ISNULL(LastName,'') else isnull(UserName,'') end   from tbl_Users where UserID=@ATTESTEDBY

SELECT @ATTESTATION_STATUS as IsAttested,
@NONGPRO_ATTESTATION_STATUS as IsNonGproAttested,
 @GPRO_ATTESTATION_STATUS as IsGproAttested,
 @TINsNPIsNewExists as TINsNPIsNewExists,
 @EMAILADDR as EmailAddr
 ,@ATTESTEDUSERNAME AS AttestedBy,
 @ATTESTED_DATE as AttestedDate,
 @ISTinsNPIsAvaliable as ISTinsNPIsAvaliable,
 @FacilityNonGproNpisExisted as IsFacilityNonGproNpisExisted,
 @FacilityGproTinsExisted as IsFacilityGproTinsExisted
end
else
begin


  if not exists( select  *
	        
		    from  @FacilityTins F 
			--INNER JOIN
			---tbl_GPRO_TIN_EmailAddresses GT ON 
			--F.TIN=GT.GPROTIN
			 where
			
		   -- AND GT.Tin_CMSAttestYear=@CmsYear
			-- Gt.IsAttested=1
			F.TIN not in(select distinct GPROTIN from tbl_GPRO_TIN_EmailAddresses
				where Tin_CMSAttestYear=@CmsYear and IsAttested=1)
				)
				Begin
				set @ATTESTATION_STATUS=1;
				end
				else
				begin

				set @ATTESTATION_STATUS=0;
				end


select top 1 @ATTESTEDUSERNAME= case when ISnull(FirstName,'') <>'' and  ISNULL(LastName,'')<>'' then ISnull(FirstName,'')+' '+ ISNULL(LastName,'') else isnull(UserName,'')   end, @EMAILADDR=EMail_Address   from tbl_Users where UserID=@ATTESTEDBY

SET  @FacilityNonGproNpisExisted =1;
SET @FacilityGproTinsExisted=1;

SELECT @ATTESTATION_STATUS as IsAttested,
@NONGPRO_ATTESTATION_STATUS as IsNonGproAttested,
 @GPRO_ATTESTATION_STATUS as IsGproAttested,
 @TINsNPIsNewExists as TINsNPIsNewExists,
 @EMAILADDR as EmailAddr
 ,@ATTESTEDUSERNAME AS AttestedBy,
 @ATTESTED_DATE as AttestedDate,
 @ISTinsNPIsAvaliable as ISTinsNPIsAvaliable,
 @FacilityNonGproNpisExisted as IsFacilityNonGproNpisExisted,
 @FacilityGproTinsExisted as IsFacilityGproTinsExisted
end





--select @FacilityGproTinsExisted as  Gproexisted ,@FacilityNonGproNpisExisted as NonGproExisted
--if(@GPRO_ATTESTATION_STATUS=1 and @NONGPRO_ATTESTATION_STATUS=1)
--begin
--set @ATTESTATION_STATUS=1
--end 
--else
--begin
--set @ATTESTATION_STATUS=0
--end




END

