
-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 1/ june/2017
-- Description:	Used to get  physician details and their TIN based o NPI. Note: only  TIN  will be added but not TIN Description
-- Modified #1: On Nov 9th 2017
-- Modified #1 Desc: Allowd to import email address from NRDR
-- Modified #2: On DEC 7th 2017
-- Modified #2 Desc: if Physician Exits, It updates TINs from NRDR.....
-- Modified #3 Desc: Hari J ,no need to use Tbl_Physician_Tin,JIRA#568
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreatePhysicianRecords]
	-- Add the parameters for the stored procedure here
	@PhysicianNPI as varchar(10)
	
AS
BEGIN

    declare @Userid int
	declare @roleid int = 2;
	declare @TINS table (TIN nvarchar(50),
						Registry Nvarchar(50),
						TIN_Description nvarchar(256))

	
	--SET NOCOUNT ON;


    -- Insert statements for procedure here
	if exists( select top 1 * from tbl_Users where
		NPI = @PhysicianNPI
		)
		Begin
		-- Perform the operation of updating NPI tins
		  select 'NPI already exists' as  ResponceMessage
		  --select @Userid = UserID from tbl_Users where NPI = @PhysicianNPI
		  --if @Userid > 0 
		  --Begin
		  				
			 -- insert @TINS (TIN,Registry,TIN_Description)
			 -- EXEC nrdr..[sp_getTINNumbers] @PhysicianNPI,'ALL' 
 
    --           if  exists(select top 1 * from @TINS)
				--begin
				-- Print  'Deleting TINS for  NPI ' + @PhysicianNPI  + ' Userid:'  + convert(varchar(10),@Userid)
				--	Delete from tbl_Physician_TIN where UserID = @userID;
				--	Insert into tbl_Physician_TIN
				--	   (
				--		  UserID,
				--		  TIN,
				--		  REGISTRY_NAME,
				--		  TIN_DESCRIPTION,
				--		  Facility_name,
				--		  Created_Date,
				--		  Created_By,
				--		  Last_Mod_Date,
				--		  Last_Mod_By,
				--		  GPRO
				--	   )
				--	   select distinct  @Userid,
				--			  TIN,
				--			  '', --Registry,
				--			  '', -- TIN_Description,
				--			  '',
				--			  GETDATE(),
				--			  @Userid,
				--			  GETDATE(),
				--			  @Userid,
				--			  0
				--			  from @TINS

				--			  Print  'inserting TINS' 
				--End
				
		--  End

		--return;
		End
	Else
		Begin
		--step1 declare a temp table and check
		
		declare @tempPhyNPI table 
		                ( npi nvarchar(10),
						  Firstname Nvarchar(50),
						  Lastname nvarchar(50),
						  Userid nvarchar(50),
						  Username varchar(50),
						  Email varchar(100)
						);
         
		 insert @tempPhyNPI (npi,Firstname,Lastname,Userid,Username,Email)
		 exec NRDR..[sp_getPhysianProfileForNPI] @PhysicianNPI
		
		
        -- select * from @tempPhyTins
		 -- exec [sp_getPhysianProfileForNPI] 1528286911
		--step2 if there is a record withFULL data then insert into tbl_users
		  if exists(select top 1 * from @tempPhyNPI)
		   begin

		    
			 INSERT INTO tbl_Users 
			 (
			    NPI,
				FirstName,
				LastName,
				NRDRUserID,
				UserName,
				EMail_Address,
				Attested,
				Created_Date,
				Last_Mod_Date
			 )
             SELECT npi,
			        Firstname,
					Lastname,
					Userid,
					Username, --SUBSTRING(Username, 11,len(Username)), --Username
					isnull(Email,'noemail@email.com'),
					1,
					GETDATE(),
					GETDATE()
             FROM @tempPhyNPI;

			    -- SELECT * FROM @tempPhyNPI

			  select @Userid = SCOPE_IDENTITY()
			
			  --step3  get tins and insert if the done exists
		      
			 

			  --insert @TINS (TIN,Registry,TIN_Description)
			  --EXEC nrdr..[sp_getTINNumbers] @PhysicianNPI,'ALL' 
 
    --           if  exists(select top 1 * from @TINS)
				--begin
				--  insert into tbl_Physician_TIN
			 --  (
			 --     UserID,
				--  TIN,
				--  REGISTRY_NAME,
				--  TIN_DESCRIPTION,
				--  Facility_name,
				--  Created_Date,
				--  Created_By,
				--  Last_Mod_Date,
				--  Last_Mod_By,
				--  GPRO
			 --  )
			 --  select distinct  @Userid,
			 --         TIN,
				--	  '', --Registry,
				--	  '', -- TIN_Description,
				--	  '',
				--	  GETDATE(),
				--	  @Userid,
				--	  GETDATE(),
				--	  @Userid,
				--	  0
				--	  from @TINS
				--End

			   --select * from @TINS

			 

              select @roleid = Role_ID from tbl_Lookup_Roles where Role_Name = LOWER('PhysicianUser')
			  insert into tbl_UserRoles
			  (
			    UserID,
				RoleID
			  )
			  values
			  (
			    @Userid,
				@roleid
			  )

			   select 'insert record' as ResponceMessage
		     
		   end
		   else 
		   Begin
		    select ' Error: No record sent by NRDR..[sp_getPhysianProfileForNPI] for ' + isnull(@PhysicianNPI,'')  as ResponceMessage
		   End
		--return ;
		End
END


