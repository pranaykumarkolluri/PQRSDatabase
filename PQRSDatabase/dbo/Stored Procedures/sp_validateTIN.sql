
CREATE PROCEDURE [dbo].[sp_validateTIN] 

	-- Add the parameters for the stored procedure here

    @NPI NVARCHAR(50) ,

    @TIN NVARCHAR(50)

AS 

    BEGIN

        DECLARE @count INTEGER ;

        SET @count = 0 ;

        EXEC @count = NRDR..sp_validateTIN @NPI, @TIN

--select @count

        RETURN @count ;

    END

	
