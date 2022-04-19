-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetTinlevelAttesationDetailsOfUser] 
@UserId INT,
@UserRole int, -- 1.Facility 2.Physician 
@NPI varchar(10)='',
@CMSYEAR INT
AS
BEGIN

-- EXEC SpTinlevelAttesationDetailsOfUser 1204,1,'',2020
-- EXEC SpTinlevelAttesationDetailsOfUser 1199,2,'1528286911',2020
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
    -- Insert statements for procedure here
	declare @UserName varchar(256);
		DECLARE @PhysicianRelatedTINS table(TIN varchar(9));
DECLARE @FACILITYTINS_NPIS TABLE(first_name varchar(100),lastname varchar(100),npi varchar(11),tin varchar(10),is_active bit, deactivation_date datetime,is_enrolled bit)
DECLARE  @FacilityTins table(TIN  VARCHAR(9),IS_GPRO bit)
SELECT top 1 @UserName=UserName FROM tbl_Users WHERE UserID=@UserId
 

if(@UserRole=1)
BEGIN
			INSERT into @FacilityTins EXEC sp_getFacilityTIN_GPRO @UserName;

			WITH AttestationUserDetails as (
			SELECT TIN,@UserId AS USERID FROM @FacilityTins
			)

			SELECT distinct A.TIN as Tin ,G.IsAttested asIsAttested ,g.Attestation_Agree_Time as attesteddate FROM  AttestationUserDetails A
			LEFT JOIN
			tbl_GPRO_TIN_EmailAddresses G  ON A.USERID=g.AttestedBy
			AND A.TIN=G.GPROTIN 
			AND G.Tin_CMSAttestYear=@CMSYEAR
			AND G.AttestedBy=@UserId
			
END
ELSE
BEGIN
				insert into @PhysicianRelatedTINS
										exec SPGetNpisofTin_VW @Npi	
				 INSERT INTO @FACILITYTINS_NPIS(tin,npi) SELECT Q.TIN,@NPI FROM @PhysicianRelatedTINS q;
			
				;WITH AttestationUserDetails as (
				SELECT DISTINCT TIN,@UserId AS USERID FROM @FACILITYTINS_NPIS 
				WHERE npi =@NPI and tin in (select tin from tbl_TIN_GPRO where is_GPRO=0)
				)
				--SELECT * FROM  AttestationUserDetails;
				SELECT distinct A.TIN as Tin ,G.IsAttested asIsAttested ,g.Attestation_Agree_Time as attesteddate FROM  AttestationUserDetails A
				LEFT JOIN
				tbl_CMS_Attestation_Year G  ON A.USERID=g.AttestedBy AND G.CMSAttestYear=@CMSYEAR
				AND A.tin =g.TIN
				AND G.PhysicianNPI=@NPI
END

END
