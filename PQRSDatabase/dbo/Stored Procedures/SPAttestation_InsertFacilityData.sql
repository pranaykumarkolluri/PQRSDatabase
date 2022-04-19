

-- =============================================
-- Author:		Raju Gaddam
-- Create date: Jan-10-2019
-- Description:	Inserting Attestion data in tbl_CMS_Attestation_Year
-- =============================================
CREATE PROCEDURE [dbo].[SPAttestation_InsertFacilityData]
@UserId int,
@EmailAddress varchar(50),
@CmsYear int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
DECLARE @UserName VARCHAR(50);
DECLARE  @FacilityTins table(TIN  VARCHAR(9),IS_GPRO BIT)
DECLARE @FacilityNPIs table(first_name VARCHAR(50),last_name VARCHAR(50),npi VARCHAR(10))


DECLARE @FACILITYTINS_NPIS TABLE(first_name varchar(100),lastname varchar(100),npi varchar(11),tin varchar(10),is_active bit, deactivation_date datetime,is_enrolled bit)

SELECT top 1 @UserName=UserName FROM tbl_Users WHERE UserID=@UserId 
--SELECT * from tbl_users WHERE username=@UserName
BEGIN TRY

BEGIN Transaction

INSERT into @FacilityTins EXEC sp_getFacilityTIN_GPRO @UserName
INSERT INTO @FACILITYTINS_NPIS EXEC sp_getFacilityPhysicianNPIsTINs  @UserName

INSERT INTO [dbo].[tbl_GPRO_TIN_EmailAddresses]
           (	   
		   [GPROTIN]
           ,[GPROTIN_EmailAddress]
           ,[CreatedBy]
           ,[CreatedDate]
           --,[Modifiedby]
           --,[ModifiedDate]
           ,[Tin_CMSAttestYear]
           ,[IsAttested]
           ,[Attestation_Agree_Time]
          -- ,[Attestation_Disagree_Time]
           ,[AttestedBy]
          -- ,[Last_Modified_FacilityID]
		  )
		   select 
		   F.TIN  
		   ,@EmailAddress
		   ,@UserId
		   ,GETDATE()
		   , @CmsYear
		   ,1 --Attested
		   ,GETDATE()
		   ,@UserId
		    from  @FacilityTins F 
			 where
			    F.is_GPRO=1 and
			    F.TIN not in(select distinct isnull(GPROTIN, '')  from tbl_GPRO_TIN_EmailAddresses
				where Tin_CMSAttestYear=@CmsYear and IsAttested=1 and GPROTIN is not null
		   )
INSERT INTO [dbo].[tbl_CMS_Attestation_Year]
           ([CMSAttestYear]
           ,[PhysicianNPI]
           ,[IsAttested]
           ,[Attestation_Agree_Time]
           --,[Attestation_Disagree_Time]
           ,[AttestedBy]
           ,[Email]
           ,[TIN])

SELECT @CmsYear 
,Result.NPI
,1 --Attested
,GETDATE()
,@UserId
,@EmailAddress
,Result.TIN
 from (
			SELECT DISTINCT P1.TIN,P1.NPI from @FACILITYTINS_NPIS P1 inner join
			tbl_TIN_GPRO T on T.TIN=P1.tin
			--inner join tbl_CMS_Attestation_Year A on A.PhysicianNPI=P.NPI and P.Tin =A.TIN
			WHERE  T.is_GPRO=0  and
			not exists(
			SELECT DISTINCT TIN,PhysicianNPI as NPI FROM tbl_CMS_Attestation_Year WHERE Tin=P1.Tin
			 and PhysicianNPI=P1.NPI 
			and isAttested=1 and CMSAttestYear=@CmsYear and tin is not null

			)
) as Result
COMMIT Transaction
END TRY
BEGIN CATCH
Rollback Transaction

INSERT INTO [dbo].[tbl_CI_FailureDetails]
           ([FailureCaseId]
           --,[CategoryId]
         --  ,[Tin]
           --,[Npi]
           ,[CmsYear]
           ,[FailureMessage]
           ,[CreatedDate]
           ,[CreatedBy])
     VALUES
           (12--<FailureCaseId, int,>
         --  ,<CategoryId, int,>
         --  ,@Tin--<Tin, varchar(9),>
         --  ,@Npi--<Npi, varchar(10),>
           ,@CmsYear--<CmsYear, int,>
           ,'Error in SPAttestation_InsertFacilityData from Sql server side: '+ERROR_MESSAGE()--<FailureMessage, varchar(max),>
           ,GETDATE()--<CreatedDate, datetime,>
           ,CONVERT(varchar, isnull(@UserId,0))--<CreatedBy, varchar(50),>
		 )
END CATCH
END

