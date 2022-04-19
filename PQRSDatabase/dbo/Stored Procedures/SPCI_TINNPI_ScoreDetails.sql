-- =============================================

-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [SPCI_TINNPI_ScoreDetails]
	-- Add the parameters for the stored procedure here
 @TIN varchar(9),
 @NPI varchar(10),
 @CMSYear int
AS
BEGIN


SELECT  DISTINCT
U.TIN,
U.NPI,
S.Total_Score as 'Score'
,@CMSYear as 'CMSYear'
--,CASE WHEN U.Submission_Uniquekey_Id IS NOT NULL  THEN 'submitted to CMS'
--ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
-- ,S.QM_Weight_Score as 'QM Contribution to Final Score'
--,S.QM_UnWeight_Score as 'QM Unweighted Score'
--,S.IA_Weight_Score as 'IA Contribution to Final Score'
--,S.IA_UnWeight_Score as 'IA Unweighted Score'
--,S.PI_Weight_Score as 'PI Contribution to Final Score'
--,S.PI_UnWeight_Score as 'PI Unweighted Score'

 FROM  tbl_TIN_GPRO G

                             inner JOIN tbl_CI_Source_UniqueKeys U ON U.Tin=G.TIN AND G.is_GPRO=0
                                                   AND U.IsMSetIdActive=1
                                                     AND ( U.Npi <>'' or U.Npi is not null)
													 and u.Tin=@TIN
													 and u.Npi=@NPI
 AND U.CmsYear=@CMSYear

LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id  AND S.Sub_ScoreId=U.Score_ResponseId

  ORDER BY U.TIN
END
