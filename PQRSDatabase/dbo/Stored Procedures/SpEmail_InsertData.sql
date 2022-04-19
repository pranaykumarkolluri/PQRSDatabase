-- =============================================
-- Author:		RAJU G
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpEmail_InsertData] @EmailTemplateId INT,
                                           @Subject         VARCHAR(5000),
                                           @Body            VARCHAR(MAX),
                                           @EmailStatus     BIT,
                                           @UserId          INT,
                                           @TIN             VARCHAR(9),
                                           @NPI             VARCHAR(10),
                                           @CMSYear         INT,
                                           @ToAddress       VARCHAR(1000)
AS
         BEGIN
             INSERT INTO [dbo].[tbl_MIPS_Email_History]
([Email_Manager_Id],
 [EmailSubject],
 [EmailBody],
 [Email_Status],
 [CreatedBy],
 [CreatedDate],
 [TIN],
 [NPI],
 [CMSYear],
 [ToAddress]
)
             VALUES
(@EmailTemplateId,
 @Subject,
 @Body,
 @EmailStatus,
 @UserId,
 GETDATE(),
 @TIN,
 @NPI,
 @CMSYear,
 @ToAddress
);
         END;
