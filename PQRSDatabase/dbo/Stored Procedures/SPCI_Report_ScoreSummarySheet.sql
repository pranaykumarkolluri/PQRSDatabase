

-- =============================================
-- Author:		Harikrishna J
-- Create date: Feb 12th,2019
-- Description: get data for summary excel sheet by user
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_Report_ScoreSummarySheet]
	-- Add the parameters for the stored procedure here
	@CMSYear int,
	@UserName varchar(50),
	@isTinReport bit,
	@IsACRStaff bit

AS
BEGIN
	
---------- ACR STAFF----------------	
IF(@IsACRStaff=1)
    BEGIN
    ---------- GPRO TIN----------------	
    IF(@isTinReport=1)
	   BEGIN
	  -- print('tin')

	  
			 SELECT DISTINCT
			 G.TIN
			 ,@CMSYear as 'CMS Reporting Year'
			 ,CASE WHEN U.Submission_Uniquekey_Id IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'			
			 ,S.QM_Weight_Score as 'QM Contribution to Final Score'
			 ,S.QM_UnWeight_Score as 'QM Unweighted Score'
			 ,S.IA_Weight_Score as 'IA Contribution to Final Score'
			 ,S.IA_UnWeight_Score as 'IA Unweighted Score'
			 ,S.PI_Weight_Score as 'PI Contribution to Final Score'
			 ,S.PI_UnWeight_Score as 'PI Unweighted Score'
			 ,S.Total_Score
			 
			 FROM tbl_TIN_GPRO G   LEFT JOIN tbl_CI_Source_UniqueKeys U ON U.Tin=G.TIN --AND G.is_GPRO=1
									                                             AND U.IsMSetIdActive=1
									                                               AND (U.Npi IS NULL OR U.Npi='')
																		AND U.CmsYear=@CMSYear
                    --                  LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id
								            --                                AND S.Sub_ScoreId=(SELECT MAX(SS.Sub_ScoreId) FROM tbl_CI_Submission_Score SS WHERE 
																    --SS.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id) 
																	 LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id  AND S.Sub_ScoreId=U.Score_ResponseId
			
		   WHERE G.is_GPRO=1
		   ORDER BY G.TIN
	   END
    ----------NON GPRO TIN----------------	
    ELSE

	   BEGIN
	  -- print('tin npi')

	 		--Declare @AllTINNPIs as Table(NPI Varchar(10),TIN varchar(9))
			 --INSERT into @AllTINNPIs
			 --select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW]

	      
			 SELECT DISTINCT
			 G.TIN,
			 G.NPI
			 ,@CMSYear as 'CMS Reporting Year'
			 ,CASE WHEN U.Submission_Uniquekey_Id IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'			
			 	 ,S.QM_Weight_Score as 'QM Contribution to Final Score'
			 ,S.QM_UnWeight_Score as 'QM Unweighted Score'
			 ,S.IA_Weight_Score as 'IA Contribution to Final Score'
			 ,S.IA_UnWeight_Score as 'IA Unweighted Score'
			 ,S.PI_Weight_Score as 'PI Contribution to Final Score'
			 ,S.PI_UnWeight_Score as 'PI Unweighted Score'
			  ,S.Total_Score
			  FROM NRDR..PHYSICIAN_TIN_VW G INNER JOIN tbl_TIN_GPRO TG ON G.TIN=TG.TIN collate DATABASE_DEFAULT AND TG.is_GPRO=0 
			-- FROM tbl_TIN_GPRO G LEFT JOIN tbl_Physician_Aggregation_Year T ON G.TIN=T.Exam_TIN --AND G.is_GPRO=0
			                              LEFT JOIN tbl_CI_Source_UniqueKeys U ON U.Tin=TG.TIN AND U.Npi=G.NPI  collate DATABASE_DEFAULT
									                                                    AND U.IsMSetIdActive=1
									                                                      AND U.Npi <>''
																			  AND U.CmsYear=@CMSYear
                    --                        LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id
								            --                                AND S.Sub_ScoreId=(SELECT MAX(SS.Sub_ScoreId) FROM tbl_CI_Submission_Score SS WHERE 
																    --SS.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id)  
																	 LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id  AND S.Sub_ScoreId=U.Score_ResponseId 
			--AND G.TIN='232323233'
			--where G.IS_GPRO=0
			--AND T.CMS_Submission_Year=@CMSYear
		   ORDER BY G.TIN
	   END

    END
---------- FACILITIES----------------	
ELSE
    BEGIN
     ---------- GPRO TIN----------------	
    IF(@isTinReport=1)
	   BEGIN
	  -- print('tin')
	   declare @facilitytins table(TIN varchar(9), IS_GPRO bit)

	   insert into @facilitytins
	   exec sp_getFacilityTIN_GPRO @UserName

	    
			 SELECT DISTINCT
			 T.TIN
			 ,@CMSYear as 'CMS Reporting Year'
			 ,CASE WHEN U.Submission_Uniquekey_Id IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'			
				 ,S.QM_Weight_Score as 'QM Contribution to Final Score'
			 ,S.QM_UnWeight_Score as 'QM Unweighted Score'
			 ,S.IA_Weight_Score as 'IA Contribution to Final Score'
			 ,S.IA_UnWeight_Score as 'IA Unweighted Score'
			 ,S.PI_Weight_Score as 'PI Contribution to Final Score'
			 ,S.PI_UnWeight_Score as 'PI Unweighted Score'
			  ,S.Total_Score
			 
			 FROM @facilitytins T LEFT JOIN tbl_CI_Source_UniqueKeys U ON U.Tin=T.TIN --AND T.IS_GPRO=1
									                                                    AND U.IsMSetIdActive=1
									                                                    AND(U.Npi IS NULL OR U.Npi='')
																			  AND U.CmsYear=@CMSYear
                    --                        LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id
								            --                                AND S.Sub_ScoreId=(SELECT MAX(SS.Sub_ScoreId) FROM tbl_CI_Submission_Score SS WHERE 
																    --SS.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id)   
																	 LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id  AND S.Sub_ScoreId=U.Score_ResponseId

			--AND G.TIN='232323233'
			where T.IS_GPRO=1
			  ORDER BY T.TIN
	   END
	    ----------NON GPRO TIN----------------	
    ELSE

	   BEGIN
	  -- print('tin npi')

	   DECLARE @Tins_Npis table(first_name varchar(100),last_name varchar(100),npi varchar(10),tin varchar(9),is_active bit, deactivation_date datetime,is_enrolled bit)

	   insert into @Tins_Npis
	    exec sp_getFacilityPhysicianNPIsTINs @UserName;

	   
			 SELECT DISTINCT
			 G.TIN,
			 T.NPI
			 ,@CMSYear as 'CMS Reporting Year'
			 ,CASE WHEN U.Submission_Uniquekey_Id IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'			
			 	 ,S.QM_Weight_Score as 'QM Contribution to Final Score'
			 ,S.QM_UnWeight_Score as 'QM Unweighted Score'
			 ,S.IA_Weight_Score as 'IA Contribution to Final Score'
			 ,S.IA_UnWeight_Score as 'IA Unweighted Score'
			 ,S.PI_Weight_Score as 'PI Contribution to Final Score'
			 ,S.PI_UnWeight_Score as 'PI Unweighted Score'
			  ,S.Total_Score
			 
			 FROM tbl_TIN_GPRO G INNER JOIN @Tins_Npis T ON G.TIN=T.TIN --AND G.is_GPRO=0
			                              LEFT JOIN tbl_CI_Source_UniqueKeys U ON U.Tin=T.TIN AND U.Npi=T.NPI 
									                                                    AND U.IsMSetIdActive=1
									                                                      AND U.Npi <>''
																			  AND U.CmsYear=@CMSYear
                    --                        LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id
								            --                                AND S.Sub_ScoreId=(SELECT MAX(SS.Sub_ScoreId) FROM tbl_CI_Submission_Score SS WHERE 
																    --SS.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id)   
																	 LEFT JOIN tbl_CI_Submission_Score S ON S.Submission_Uniquekey_Id=U.Submission_Uniquekey_Id  AND S.Sub_ScoreId=U.Score_ResponseId
			--AND G.TIN='232323233'
			where G.IS_GPRO=0
		   ORDER BY G.TIN
	   END



END
END







