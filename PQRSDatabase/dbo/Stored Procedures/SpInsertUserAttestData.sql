-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpInsertUserAttestData]
 
 @UserId int,
 @NPI varchar(10),
 @UserRole int,
 @CMSYEAR INT,
 @USERMAIL VARCHAR(256),
 @tbl_UserAttestData_type tbl_UserAttestData_type READONLY
AS
BEGIN
	declare @VerifedDate DateTime = GETDATE();
IF(@UserRole=1)
BEGIN
    
	UPDATE G SET 
	AttestedBy =@UserId,
	IsAttested=T.IsAttested,
	Attestation_Agree_Time=@VerifedDate,
	G.Modifiedby=@UserId,
	g.ModifiedDate=@VerifedDate,
	GPROTIN_EmailAddress=@USERMAIL
	 FROM tbl_GPRO_TIN_EmailAddresses G 
		   INNER JOIN @tbl_UserAttestData_type T ON G.AttestedBy=@UserId				
												AND G.Tin_CMSAttestYear=@CMSYEAR
												AND G.GPROTIN=T.Tin
						
    
INSERT INTO [dbo].[tbl_GPRO_TIN_EmailAddresses]
           ([GPROTIN]
           ,[GPROTIN_EmailAddress]
           ,[CreatedBy]
           ,[CreatedDate]
          
           ,[Tin_CMSAttestYear]
           ,[IsAttested]
           ,[Attestation_Agree_Time]
           
           ,[AttestedBy]
           )
     
				 SELECT T.Tin,
				 @USERMAIL,
				 @UserId,
				 @VerifedDate,
				 @CMSYEAR,
				 T.IsAttested,
				 @VerifedDate,
				 @UserId
				  FROM  @tbl_UserAttestData_type T 
				  where T.Tin NOT IN (
				  select GPROTIN from @tbl_UserAttestData_type as U JOIN tbl_GPRO_TIN_EmailAddresses as G
					ON G.AttestedBy=@UserId				
						AND G.Tin_CMSAttestYear=@CMSYEAR
						AND G.GPROTIN=T.Tin 
				  )
END
ELSE

BEGIN


	UPDATE G SET 
	G.AttestedBy =@UserId,
	G.IsAttested=T.IsAttested,
	G.Attestation_Agree_Time=@VerifedDate,
	
	g.Email=@USERMAIL
	 FROM tbl_CMS_Attestation_Year G 
		   INNER JOIN @tbl_UserAttestData_type T ON G.AttestedBy=@UserId				
												AND G.CMSAttestYear=@CMSYEAR
												AND G.TIN=T.Tin
												AND G.PhysicianNPI=@NPI
						
    
INSERT INTO [dbo].[tbl_CMS_Attestation_Year]
           ([CMSAttestYear]
           ,[PhysicianNPI]
           ,[IsAttested]
           ,[Attestation_Agree_Time]
          
           ,[AttestedBy]
           ,[Email]
           ,[TIN])


			 SELECT @CMSYEAR,
			 @NPI,
			 T.IsAttested,
			 @VerifedDate,
			 @UserId,
			@USERMAIL,
			t.Tin
			  FROM  @tbl_UserAttestData_type T
				  where T.Tin NOT IN (
				  select GPROTIN from @tbl_UserAttestData_type as U JOIN tbl_GPRO_TIN_EmailAddresses as G
					ON G.AttestedBy=@UserId				
						AND G.Tin_CMSAttestYear=@CMSYEAR
						AND G.GPROTIN=T.Tin 
				  )

END
    
END
