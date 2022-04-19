




-- =============================================
-- Author:		PRashanth kumar Garlapally
-- Create date: sept 4,2014
-- Description:	Used to retrieve  TINS from NRDR9x or NRDR
-- =============================================
CREATE PROCEDURE [dbo].[sp_getTINNumbers] 
	-- Add the parameters for the stored procedure here
	@NPI nvarchar(50) ,
	@RegistryName nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @TINS table (TIN nvarchar(50),
						Registry Nvarchar(50),
						TIN_Description nvarchar(256))

  insert @TINS (TIN,Registry,TIN_Description)
  EXEC nrdr..[sp_getTINNumbers] @NPI,'ALL' 
  
  set nocount off
  select * from @TINS
  
  return @@rowCount;
 
END






