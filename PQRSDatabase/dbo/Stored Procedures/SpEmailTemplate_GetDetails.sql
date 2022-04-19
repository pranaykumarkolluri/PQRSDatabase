-- =============================================
-- Author:		RAJU G
-- Create date: 16-01-2021
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpEmailTemplate_GetDetails]

  @EmailTemplateType varchar(256),
  @EmailTemplateTypeId int=0
AS
BEGIN

    SELECT
	          Id as Email_Manager_ID,
			 FromAddress
			 ,ToAddress
			 ,[Subject]
			 ,Category as TemplateType
			 ,Body 
			 ,CreatedBy
			 ,CreatedDate
			 ,UpdatedBy
			 ,UpdatedDate	
	 FROM tbl_MIPS_Email_Manager WHERE Category=@EmailTemplateType

END
