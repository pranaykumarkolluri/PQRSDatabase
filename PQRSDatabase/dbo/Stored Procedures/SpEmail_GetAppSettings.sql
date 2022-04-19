-- =============================================
-- Author:		hari j
-- Create date: 20th, Jan 2021
-- Description:	get email configuration setting
-- =============================================
CREATE PROCEDURE [dbo].[SpEmail_GetAppSettings]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
      [Set_Key]
      ,[Value]
     
  FROM [tbl_Lookup_MIPS_Settings] where Set_Key in('IsDevEmail','SMTPServer','SMTPUseSsl','ServerMachineName')
END