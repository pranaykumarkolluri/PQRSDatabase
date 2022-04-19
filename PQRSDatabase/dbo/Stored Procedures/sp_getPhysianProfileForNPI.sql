-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getPhysianProfileForNPI] 
	-- Add the parameters for the stored procedure here
	@NPI nvarchar(50)
AS
Begin


  DECLARE @Tbl_PhysianProfileForNPI TABLE

            (

              NPI NVARCHAR(50) ,

              FirstName NVARCHAR(50) ,

              LastName NVARCHAR(50),
		    UserId varchar(100),
		    UserName varchar(50),
		    Email varchar(50)

            )

insert into @Tbl_PhysianProfileForNPI

 exec  NRDR..sp_getPhysianProfileForNPI @NPI

 select * from @Tbl_PhysianProfileForNPI
	
END

