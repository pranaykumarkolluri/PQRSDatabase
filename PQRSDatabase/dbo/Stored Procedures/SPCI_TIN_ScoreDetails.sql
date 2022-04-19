-- =============================================

-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [SPCI_TIN_ScoreDetails]
	-- Add the parameters for the stored procedure here
 @TIN varchar(9),
 @CMSYear int
AS
BEGIN


SELECT DISTINCT
G.TIN
,S.Total_Score as 'Score'
,@CMSYear as 'CMSYear'
--,S.QM_Weight_Score as 'QM Contribution to Final Score'
--,S.QM_UnWeight_Score as 'QM Unweighted Score'
--,S.IA_Weight_Score as 'IA Contribution to Final Score'
--,S.IA_UnWeight_Score as 'IA Unweighted Score'
--,S.PI_Weight_Score as 'PI Contribution to Final Score'
--,S.PI_UnWeight_Score as 'PI Unweighted Score'
-- ,CASE WHEN U.Submission_Uniquekey_Id IS NOT NULL  THEN 'submitted to CMS'
     --ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
FROM tbl_TIN_GPRO G   Inner Join tbl_CI_Source_UniqueKeys U ON U.Tin=G.TIN AND G.is_GPRO=1
											and G.TIN=@TIN
                                            AND U.IsMSetIdActive=1
                                              AND (U.Npi IS NULL OR U.Npi='')
AND U.CmsYear=@CMSYear
LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id  AND S.Sub_ScoreId=U.Score_ResponseId


  ORDER BY G.TIN
END
