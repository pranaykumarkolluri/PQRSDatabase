-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE SPCI_FinalScoreDetails
	
	@CMSYear int
AS
BEGIN

DECLARE @FINAL_SCORE_DATE DATETIME;
DECLARE @SCORE_IDS TABLE(SCORE_ID INT);
DECLARE @GPRO_COUNT  INT;
DECLARE @NON_GPRO_COUNT INT;
DECLARE @GPRO_TOTAL_TINS INT=0;
DECLARE @NONGPRO_TOTAL_TINS INT=0;

SELECT @FINAL_SCORE_DATE=FinalScoreDate FROM tbl_Lookup_Active_Submission_Year WHERE Submission_Year=@CMSYear;

INSERT INTO @SCORE_IDS(SCORE_ID)
SELECT Sub_ScoreId FROM
 tbl_CI_Submission_Score 
 WHERE Created_Date >= @FINAL_SCORE_DATE AND ( IsFinalScore IS NULL OR IsFinalScore=0)

 
 SELECT @GPRO_COUNT=  COUNT(DISTINCT U.Tin)
								 FROM tbl_CI_Source_UniqueKeys U INNER JOIN 								
								@SCORE_IDS S ON U.Score_ResponseId=S.SCORE_ID 
									AND U.IsMSetIdActive=1 AND U.CmsYear=@CMSYear
									AND U.Npi IS NOT NULL
								

 SELECT @NON_GPRO_COUNT=  COUNT(DISTINCT U.Tin)
								 FROM tbl_CI_Source_UniqueKeys U INNER JOIN 								
								@SCORE_IDS S ON U.Score_ResponseId=S.SCORE_ID 
									AND U.IsMSetIdActive=1 AND U.CmsYear=@CMSYear
									AND U.Npi IS  NULL

SELECT @GPRO_TOTAL_TINS= COUNT( DISTINCT Tin)  FROM tbl_CI_Source_UniqueKeys WHERE CmsYear=@CMSYear AND IsMSetIdActive=1 AND Npi IS NOT NULL

SELECT @NONGPRO_TOTAL_TINS= COUNT( DISTINCT Tin)  FROM tbl_CI_Source_UniqueKeys WHERE CmsYear=@CMSYear AND IsMSetIdActive=1 AND Npi IS  NULL

SELECT 
@FINAL_SCORE_DATE AS FINALSCOREDATE 
,@GPRO_COUNT AS GPRO_COUNT
,@NON_GPRO_COUNT AS NON_GPRO_COUNT
, @GPRO_TOTAL_TINS AS GPRO_TOTAL_TINS 
,@NONGPRO_TOTAL_TINS AS NONGPRO_TOTAL_TINS;


END
