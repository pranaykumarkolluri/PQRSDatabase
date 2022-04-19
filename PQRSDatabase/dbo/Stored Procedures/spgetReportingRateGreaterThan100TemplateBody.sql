CREATE PROCEDURE [dbo].[spgetReportingRateGreaterThan100TemplateBody]
 @emailtemplate VARCHAR(MAX) OUT,
 @toAddress VARCHAR(MAX) OUT,
 @subject VARCHAR(MAX) OUT,
 @isFromPortal BIT = 0
 
 AS
 BEGIN



DECLARE @recordexists INT = 0;
DECLARE @sendMail INT = 0;
DECLARE @currentMonth INT = MONTH(GETDATE());
DECLARE @currentDay INT = DAY(GETDATE());

DECLARE @tbl_Aggregation TABLE ( 
    ID INT IDENTITY(1,1), 
	Exam_TIN [varchar](10) NOT NULL,
	Physician_NPI [varchar](50) NOT NULL,
	Measure_Num [varchar](50) NULL,
	Reporting_Denominator [int] NOT NULL,
	Reporting_Numerator [decimal](18, 2) NULL,
	Reporting_rate [decimal](18, 4) NULL
)

INSERT INTO @tbl_Aggregation
SELECT STUFF(Exam_TIN,1,(LEN(Exam_TIN)-3) - 1,REPLICATE('*',(LEN(Exam_TIN)-3) - 1))
,Physician_NPI
,Measure_Num
,Original_Reporting_Denominator AS Reporting_Denominator
,Original_Reporting_Numerator AS Reporting_Numerator
,Original_Reporting_Rate AS Reporting_rate
 from tbl_ReportingRateGreaterThan100


DECLARE @tblEmailTemplate AS TABLE([Id] INT , [FromAddress] [varchar](250) NULL,
	[ToAddress] [varchar](900) NULL,
	[Subject] [varchar](900) NULL,
	[Body] [varchar](MAX) NULL
);


DECLARE @htmlencodedbody VARCHAR(MAX);
DECLARE @htmldecodedbody VARCHAR(MAX);
DECLARE @fromAddress VARCHAR(250);
DECLARE @templateId INT = 0;

SET @recordexists = (SELECT COUNT(*) FROM @tbl_Aggregation)

IF(@recordexists <> 0)
BEGIN TRY

INSERT INTO @tblEmailTemplate
SELECT TOP 1 Id,FromAddress,ToAddress,Subject,Body FROM [dbo].[tbl_MIPS_Email_Manager] WHERE Category = 'ReportingRateError'
SET @recordexists = (SELECT COUNT(*) FROM @tblEmailTemplate);
IF(@recordexists <> 0)
BEGIN

SET @templateId = (SELECT TOP 1 Id FROM @tblEmailTemplate)
SET @htmlencodedbody = (SELECT TOP 1 Body FROM @tblEmailTemplate)

SET @htmldecodedbody = (SELECT dbo.fndecodehtmlstring(@htmlencodedbody));
SET @fromAddress = (SELECT TOP 1 FromAddress FROM @tblEmailTemplate)
SET @toAddress = (SELECT TOP 1 ToAddress FROM @tblEmailTemplate)
SET @toAddress = REPLACE(@toAddress,',',';')
SET @subject = (SELECT TOP 1 Subject FROM @tblEmailTemplate)


IF(@toAddress IS NOT NULL OR @toAddress <> '')
BEGIN

DECLARE @style VARCHAR(MAX) = N'style="border-left: 0; border-top: 0.5px solid #000000; border-right: 0.5px solid #000000; border-bottom: 0.5px solid #000000; text-align:center; padding:5px 10px;"'
DECLARE @tabletemplate VARCHAR(MAX) = N'<table style="cellspacing:0; border-spacing:0; color:#000000; border-collapse:collapse; border: 0.5px solid #000000;">
  <tr>
    <th '+@style+'>TIN</th>
    <th '+@style+'>NPI</th>
    <th '+@style+'>Measure Number</th>
	<th '+@style+'>Reporting Denominator</th>
	<th '+@style+'>Reporting Numerator</th>
	<th '+@style+'>Reporting Rate</th>
  </tr>
  ###rowscontent###
  </table>
 '

  DECLARE @currentCount INT
DECLARE @totalCount INT
SET @currentCount = 0
SET @totalCount = (SELECT COUNT(*) FROM @tbl_Aggregation) 
DECLARE @resultContent VARCHAR(MAX) = N''

WHILE @currentCount< @totalCount
BEGIN
    DECLARE @Physician_NPI varchar(50) = ''
	DECLARE @Exam_TIN varchar(10) = ''
	DECLARE @Measure_Num varchar(50) = ''
	DECLARE @Reporting_Denominator int = 0
	DECLARE @Reporting_Numerator decimal(18, 2) = 0
	DECLARE @Reporting_Rate decimal(18, 4) = 0

  SET @Physician_NPI = (SELECT Physician_NPI FROM @tbl_Aggregation 
   ORDER BY Id
   OFFSET @currentCount ROWS
   FETCH NEXT 1 ROWS ONLY)
   ----------------------------------
     SET @Exam_TIN = (SELECT Exam_TIN FROM @tbl_Aggregation 
   ORDER BY Id
   OFFSET @currentCount ROWS
   FETCH NEXT 1 ROWS ONLY)
   ------------------------------------
     SET @Measure_Num = (SELECT Measure_Num FROM @tbl_Aggregation 
   ORDER BY Id
   OFFSET @currentCount ROWS
   FETCH NEXT 1 ROWS ONLY)
   ------------------------------------
     SET @Reporting_Denominator = (SELECT Reporting_Denominator FROM @tbl_Aggregation 
   ORDER BY Id
   OFFSET @currentCount ROWS
   FETCH NEXT 1 ROWS ONLY)
   -------------------------------------
     SET @Reporting_Numerator = (SELECT Reporting_Numerator FROM @tbl_Aggregation 
   ORDER BY Id
   OFFSET @currentCount ROWS
   FETCH NEXT 1 ROWS ONLY)
   ----------------------------------------
     SET @Reporting_Rate = (SELECT Reporting_Rate FROM @tbl_Aggregation 
   ORDER BY Id
   OFFSET @currentCount ROWS
   FETCH NEXT 1 ROWS ONLY)

  SET @resultContent = CONCAT(@resultContent , ' <tr>
    <td '+@style+'>' +@Exam_TIN + '</td>
    <td '+@style+'>' +@Physician_NPI + '</td>
     <td '+@style+'>' +@Measure_Num + '</td>
	 <td '+@style+'>' + ISNULL(CAST(@Reporting_Denominator AS VARCHAR),'--') + '</td>
    <td '+@style+'>' +ISNULL(CAST(@Reporting_Numerator AS VARCHAR),'--') + '</td>
   <td '+@style+'>' +ISNULL(CAST(@Reporting_Rate AS VARCHAR),'--') + '</td>
  </tr>')

   SET @currentCount = @currentCount + 1;
END;
SET @tabletemplate = REPLACE(@tabletemplate,'###rowscontent###',@resultContent);
SET @htmldecodedbody = REPLACE(@htmldecodedbody,'###templatecontent###',@tabletemplate);
SET @sendMail = 1;
END
END


IF(@sendMail = 1)
BEGIN
SET @emailtemplate = @htmldecodedbody

IF(@isFromPortal = 0)
BEGIN
EXECUTE [dbo].[SpEmail_InsertData] @templateId,@subject,@htmldecodedbody,1,0,NULL,NULL,NULL,@toAddress
END
END

END TRY
BEGIN CATCH
SET @sendMail = 0
END CATCH

IF(@sendMail = 0)
BEGIN
SET @emailtemplate = ''
SET @toAddress = ''
SET @subject = ''
IF(@isFromPortal = 0)
BEGIN
EXECUTE [dbo].[SpEmail_InsertData] @templateId,@subject,@htmldecodedbody,0,0,NULL,NULL,NULL,@toAddress
END
END
 END