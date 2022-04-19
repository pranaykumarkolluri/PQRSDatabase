-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================


CREATE PROCEDURE [dbo].[SPCI_GetTIN_NPI_ProcessDetails]
	
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

 
 SELECT DISTINCT U.Tin as Tin ,U.Npi as  Npi,u.Submission_Uniquekey_Id
								 FROM tbl_CI_Source_UniqueKeys U INNER JOIN 								
								@SCORE_IDS S ON U.Score_ResponseId=S.SCORE_ID 
									AND U.IsMSetIdActive=1 AND U.CmsYear=@CMSYear
	

END
