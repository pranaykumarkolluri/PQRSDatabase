CREATE PROCEDURE [dbo].[sp_sendquarterlymails]
@cmsYear INT
AS
BEGIN
--Start

DECLARE @recordexists INT = 0;
DECLARE @sendMail INT = 0;
DECLARE @currentMonth INT = MONTH(GETDATE());
DECLARE @currentDay INT = DAY(GETDATE());


DECLARE @quarterlyEmailDates AS TABLE([MONTH] INT,
	[DAY] INT
);

DECLARE @emailTemplate AS TABLE([Id] INT , [FromAddress] [varchar](250) NULL,
	[ToAddress] [varchar](900) NULL,
	[Subject] [varchar](900) NULL,
	[Body] [varchar](max) NULL
);

INSERT INTO @quarterlyEmailDates VALUES (1,1),(4,1),(7,1),(10,1),(12,1)

DECLARE @htmlencodedbody VARCHAR(max);
DECLARE @htmldecodedbody VARCHAR(max);
DECLARE @fromAddress VARCHAR(250);
DECLARE @toAddress VARCHAR(900);
DECLARE @subject VARCHAR(900);
DECLARE @templateId INT = 0;
DECLARE @insertToHistory INT = 0;

SET @recordexists = (SELECT COUNT(*) FROM @quarterlyEmailDates WHERE [MONTH] = @currentMonth AND [DAY] = @currentDay)

IF(@recordexists <> 0)
BEGIN TRY

INSERT INTO @emailTemplate
SELECT TOP 1 Id,FromAddress,ToAddress,Subject,Body FROM [dbo].[tbl_MIPS_Email_Manager] WHERE Category = 'QuarterlySheduledMails'
SET @recordexists = (SELECT COUNT(*) FROM @emailTemplate);
IF(@recordexists <> 0)
BEGIN

SET @templateId = (SELECT TOP 1 Id FROM @emailTemplate)
SET @recordexists = (SELECT COUNT(*) FROM [dbo].[tbl_MIPS_Email_History] WHERE CAST(CreatedDate AS DATE) = CAST(GETDATE() AS DATE) AND Email_Status = 1 AND Email_Manager_Id = @templateId)


IF(@recordexists = 0)
BEGIN
SET @insertToHistory = 1;
SET @htmlencodedbody = (SELECT TOP 1 Body FROM @emailTemplate)

SET @htmldecodedbody = (SELECT dbo.fndecodehtmlstring(@htmlencodedbody));
SET @htmldecodedbody = REPLACE(@htmldecodedbody,'###cmsyear###',@cmsYear);
SET @fromAddress = (SELECT TOP 1 FromAddress FROM @emailTemplate)
SET @toAddress = (SELECT TOP 1 ToAddress FROM @emailTemplate)
--SET @toAddress = (select Mails = STUFF((SELECT DISTINCT ';' + ProfileEmail FROM NRDR..[MIPS_USERS_EMAILS_VW] FOR XML PATH('')),1,1,''));
SET @toAddress = REPLACE(@toAddress,',',';')
SET @subject = (SELECT TOP 1 Subject FROM @emailTemplate)


IF(@toAddress IS NOT NULL OR @toAddress <> '')
BEGIN
SET @sendMail = 1;
END
END
END

IF(@sendMail = 1)
BEGIN
EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'MIPSMailAlerts',  
    @recipients =@toAddress,  
    @body = @htmldecodedbody,
    @body_format = 'HTML', 
    @subject = @subject,
	@from_address = @fromAddress

EXECUTE [dbo].[SpEmail_InsertData] @templateId,@subject,@htmldecodedbody,1,0,NULL,NULL,NULL,@toAddress

END

END TRY
BEGIN CATCH
SET @sendMail = 0
END CATCH

IF(@sendMail = 0 AND  @insertToHistory = 1)
BEGIN
EXECUTE [dbo].[SpEmail_InsertData] @templateId,@subject,@htmldecodedbody,0,0,NULL,NULL,NULL,@toAddress
END

--End
END