CREATE FUNCTION [dbo].[fndecodehtmlstring] (@input VARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
--Decoding encoded HTML string

    DECLARE @htmlNames TABLE 
(
    ID INT IDENTITY(1,1), 
    asciiDecimal INT, 
    htmlName varchar(50)
);

INSERT INTO @htmlNames 
VALUES 
    (34,'&quot;'),
    (38,'&amp;'),
    (60,'&lt;'),
    (62,'&gt;'),
    (160,'&nbsp;'),
    (161,'&iexcl;'),
    (162,'&cent;')
;
DECLARE @resultString VARCHAR(MAX) = @input;

-- Simple HTML-decode:
SELECT
    @resultString = REPLACE(@resultString COLLATE Latin1_General_CS_AS, htmlName, NCHAR(asciiDecimal))
FROM
    @htmlNames
;

-- Multiple HTML-decode:
SET @resultString = @input;

DECLARE @temp VARCHAR(MAX) = '';
WHILE @resultString != @temp
BEGIN
    SET @temp = @resultString;

    SELECT
        @resultString = REPLACE(@resultString COLLATE Latin1_General_CS_AS, htmlName, NCHAR(asciiDecimal))
    FROM
        @htmlNames
    ;
END;
RETURN @resultString;
END;
    
;