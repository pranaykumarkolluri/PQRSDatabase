
CREATE PROCEDURE [dbo].[sp_getPhysicianProfile] 

	-- Add the parameters for the stored procedure here

    @UserName NVARCHAR(50)

AS 

    BEGIN

	

        DECLARE @user TABLE

            (

              NPI NVARCHAR(50) ,

              FirstName NVARCHAR(50) ,

              LastName NVARCHAR(50)

            )



        SET nocount ON

        INSERT  @user

                ( NPI ,

                  FirstName ,

                  LastName

                )

                EXEC nrdr..[sp_getPhysicianProfile] @UserName



        SET nocount OFF

        SELECT  *

        FROM    @user



        RETURN @@RowCount







    END
	
