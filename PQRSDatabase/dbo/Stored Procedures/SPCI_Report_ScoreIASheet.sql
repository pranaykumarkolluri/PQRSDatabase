-- =============================================
-- Author:		Harikrishna J
-- Create date: Feb 12th,2019
-- Description: get data for Ia excel sheet by user
--Change#1 Sumanth
--Change1:Jira-784
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_Report_ScoreIASheet]
	-- Add the parameters for the stored procedure here
	@CMSYear int,
	@UserName varchar(50),
	@isTinReport bit,
	@IsACRStaff bit
AS
BEGIN

DECLARE @Category_Id INT=2;---FOR IA
---------- ACR STAFF----------------	
IF(@IsACRStaff=1)
    BEGIN
    ---------- GPRO TIN----------------	
    IF(@isTinReport=1)
	   BEGIN
	  -- print('tin')

	    SELECT   DISTINCT T.Tin AS TIN
		   -- ,G.NPI
		    ,S.SelectedActivity AS 'IA Measure Number'	
		   -- ,'selected' AS 'Measure Selection Status'	    
		   ,CASE WHEN M.Measure_Name IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
		    ,I.Contribution_Value AS 'Contribution Value'
		    ,I.Measure_Weight AS 'Weight'
		    ,I.Ia_Complete as Complete
		   -- ,I.Ia_Message as 'Message'
		    FROM tbl_TIN_GPRO T LEFT JOIN tbl_IA_Users G ON G.TIN=T.TIN AND G.CMSYear=@CMSYear 
			and  ((@CMSYear>=2020 and G.IsGpro=1 ) or @CMSYear<2020 )                      --Change1
		                      LEFT JOIN tbl_IA_User_Selected S ON S.SelectedID=G.SelectedID and S.attest=1
						LEFT JOIN tbl_CI_Source_UniqueKeys SS on  SS.Tin=G.TIN AND (SS.Npi = ''OR SS.Npi IS NULL) AND SS.Category_Id=@Category_Id AND  SS.IsMSetIdActive=1 AND SS.CmsYear=@CMSYear
						  LEFT  JOIN  tbl_CI_Measuredata_value  M ON SS.Key_Id=M.KeyId AND M.Measure_Name=S.SelectedActivity

						 -- AND M.KeyId=(SELECT MAX(SS.Key_Id) FROM tbl_CI_Source_UniqueKeys SS WHERE SS.Tin=G.TIN AND (SS.Npi = ''OR SS.Npi IS NULL) AND SS.Category_Id=@Category_Id AND  SS.IsMSetIdActive=1 AND SS.CmsYear=@CMSYear)
						  LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name=M.Measure_Name  
																		AND I.Sub_ScoreId=SS.Score_ResponseId
																		aND I.Category_Id=SS.Category_Id
					--										 AND I.Sub_ScoreId=(SELECT MAX(CS.Sub_ScoreId) FROM tbl_CI_Submission_Score CS WHERE 
					--										 CS.Submission_Uniquekey_Id=(SELECT TOP 1 CSS.Submission_Uniquekey_Id FROM tbl_CI_Source_UniqueKeys CSS WHERE 
					--										 CSS.Tin=G.TIN AND  (CSS.Npi = ''OR CSS.Npi IS NULL) AND CSS.Category_Id=@Category_Id   AND CSS.IsMSetIdActive=1 AND CSS.CmsYear=@CMSYear) )
			  WHERE 
			  T.is_GPRO=1 order by T.TIN
			--AND G.TIN='232323233'
		     
			  --UNION

			  --SELECT DISTINCT TIN
		   
		   -- ,NULL AS 'IA Measure Number'	
		   ---- ,'have not selected' AS 'Measure Selection Status'	    
		   --,'have not submitted to CMS'  AS 'CMS Submission Status'
		   -- ,0.00 AS 'Contribution Value'
		   -- ,'' AS 'Weight'
		   -- ,'' as Complete
		   ---- ,'' as 'Message'
			  --FROM tbl_TIN_GPRO WHERE IS_GPRO=1 AND TIN NOT IN (SELECT G.TIN FROM tbl_IA_Users G INNER JOIN tbl_TIN_GPRO T ON G.TIN=T.TIN AND T.is_GPRO=1 AND G.CMSYear=@CMSYear)
			  --ORDER BY G.TIN

	   END
    ----------NON GPRO TIN----------------	
    ELSE

	   BEGIN
	  -- print('tin npi')

	 		--Declare @AllTINNPIs as Table(NPI Varchar(10),TIN varchar(9))
			 --INSERT into @AllTINNPIs
			 --select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW]

	       SELECT   DISTINCT P.Tin AS TIN
		   ,P.NPI
		    ,S.SelectedActivity AS 'IA Measure Number'	
		   -- ,'selected' AS 'Measure Selection Status'	    
		   ,CASE WHEN M.Measure_Name IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
		    ,I.Contribution_Value AS 'Contribution Value'
		    ,I.Measure_Weight AS 'Weight'
		    ,I.Ia_Complete as Complete
		   -- ,I.Ia_Message as 'Message'
		   FROM NRDR..PHYSICIAN_TIN_VW P INNER JOIN tbl_TIN_GPRO TG ON P.TIN=TG.TIN collate DATABASE_DEFAULT AND TG.is_GPRO=0 
		                       -- INNER JOIN @AllTINNPIs T ON G.TIN=T.TIN AND G.NPI=T.NPI

						LEFT JOIN tbl_IA_Users G on
												G.TIN=P.TIN collate DATABASE_DEFAULT
											and G.NPI=P.NPI	 collate DATABASE_DEFAULT
											AND G.CMSYear=@CMSYear
		                  LEFT JOIN tbl_IA_User_Selected S ON S.SelectedID=G.SelectedID 
						  lEFT JOIN tbl_CI_Source_UniqueKeys SS on  SS.Tin=G.TIN AND (SS.Npi =G.NPI) AND SS.Category_Id=@Category_Id AND  SS.IsMSetIdActive=1 AND SS.CmsYear=@CMSYear
						  LEFT  JOIN  tbl_CI_Measuredata_value M ON  SS.Key_Id=M.KeyId AND M.Measure_Name=S.SelectedActivity

						  --AND M.KeyId=(SELECT MAX(SS.Key_Id) FROM tbl_CI_Source_UniqueKeys SS WHERE SS.Tin=G.TIN AND (SS.Npi =G.NPI) AND SS.Category_Id=@Category_Id AND  SS.IsMSetIdActive=1 AND SS.CmsYear=@CMSYear)
						  LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name=M.Measure_Name 
																		AND I.Sub_ScoreId=SS.Score_ResponseId
																		AND i.Category_Id=SS.Category_Id
					--										 AND I.Sub_ScoreId=(SELECT MAX(CS.Sub_ScoreId) FROM tbl_CI_Submission_Score CS WHERE 
					--										 CS.Submission_Uniquekey_Id=(SELECT TOP 1 CSS.Submission_Uniquekey_Id FROM tbl_CI_Source_UniqueKeys CSS WHERE 
					--										 CSS.Tin=G.TIN AND  (CSS.Npi = G.NPI) AND CSS.Category_Id=@Category_Id   AND CSS.IsMSetIdActive=1 AND CSS.CmsYear=@CMSYear) )
			  ----WHERE 
			  --G.CMSYear=@CMSYear
			--AND G.TIN='232323233'
		  	--		 UNION

			  --SELECT DISTINCT TIN
			  --,npi as NPI
		   
		   -- ,NULL AS 'IA Measure Number'	
		   ---- ,'have not selected' AS 'Measure Selection Status'	    
		   --,'have not submitted to CMS'  AS 'CMS Submission Status'
		   -- ,0.00 AS 'Contribution Value'
		   -- ,'' AS 'Weight'
		   -- ,'' as Complete
		   ---- ,'' as 'Message'
			  --FROM @AllTINNPIs WHERE  TIN NOT IN (SELECT G.TIN FROM tbl_IA_Users G INNER JOIN tbl_TIN_GPRO T ON G.TIN=T.TIN AND T.is_GPRO=0 AND G.CMSYear=@CMSYear
		   --                     INNER JOIN   @AllTINNPIs F ON G.TIN=F.TIN AND F.npi=G.NPI)
			  ORDER BY P.TIN,P.NPI
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

	    SELECT   DISTINCT T.Tin AS TIN
		   -- ,G.NPI
		    ,S.SelectedActivity AS 'IA Measure Number'	
		   -- ,'selected' AS 'Measure Selection Status'	    
		   ,CASE WHEN M.Measure_Name IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
		    ,I.Contribution_Value AS 'Contribution Value'
		    ,I.Measure_Weight AS 'Weight'
		    ,I.Ia_Complete as Complete
		  --  ,I.Ia_Message as 'Message'
		    FROM @facilitytins T LEFT JOIN tbl_IA_Users G ON G.TIN=T.TIN AND G.CMSYear=@CMSYear 
			and  ((@CMSYear>=2020 and G.IsGpro=1 ) or @CMSYear<2020 )               --Change1
		                      LEFT JOIN tbl_IA_User_Selected S ON S.SelectedID=G.SelectedID AND S.attest=1
						  LEFT JOIN tbl_CI_Source_UniqueKeys SS on  SS.Tin=G.TIN AND (SS.Npi = ''OR SS.Npi IS NULL) AND SS.Category_Id=@Category_Id AND  SS.IsMSetIdActive=1 AND SS.CmsYear=@CMSYear
						  LEFT  JOIN  tbl_CI_Measuredata_value M ON  SS.Key_Id=M.KeyId AND M.Measure_Name=S.SelectedActivity
						 -- AND M.KeyId=(SELECT MAX(SS.Key_Id) FROM tbl_CI_Source_UniqueKeys SS WHERE SS.Tin=G.TIN AND (SS.Npi = ''OR SS.Npi IS NULL) AND SS.Category_Id=@Category_Id AND  SS.IsMSetIdActive=1 AND SS.CmsYear=@CMSYear)

						  LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name=M.Measure_Name 
																	  AND I.Sub_ScoreId=SS.Score_ResponseId
																	  AND i.Category_Id=SS.Category_Id
															 --AND I.Sub_ScoreId=(SELECT MAX(CS.Sub_ScoreId) FROM tbl_CI_Submission_Score CS WHERE 
															 --CS.Submission_Uniquekey_Id=(SELECT TOP 1 CSS.Submission_Uniquekey_Id FROM tbl_CI_Source_UniqueKeys CSS WHERE 
															 --CSS.Tin=G.TIN AND  (CSS.Npi = ''OR CSS.Npi IS NULL) AND CSS.Category_Id=@Category_Id   AND CSS.IsMSetIdActive=1 AND CSS.CmsYear=@CMSYear) )
			  WHERE 
			  T.is_GPRO=1 order by T.TIN
			  
			   
			  --UNION

			  --SELECT DISTINCT TIN
		   
		   -- ,NULL AS 'IA Measure Number'	
		   ---- ,'have not selected' AS 'Measure Selection Status'	    
		   --,'have not submitted to CMS'  AS 'CMS Submission Status'
		   -- ,0.00 AS 'Contribution Value'
		   -- ,'' AS 'Weight'
		   -- ,'' as Complete
		   ---- ,'' as 'Message'
			  --FROM @facilitytins WHERE IS_GPRO=1 AND TIN NOT IN (SELECT G.TIN FROM tbl_IA_Users G INNER JOIN @facilitytins T ON G.TIN=T.TIN AND T.is_GPRO=1 AND G.CMSYear=@CMSYear)
			  --ORDER BY G.TIN

			--AND G.TIN='232323233'
			 
	   END
	    ----------NON GPRO TIN----------------	
    ELSE

	   BEGIN
	  -- print('tin npi')

	   DECLARE @Tins_Npis table(first_name varchar(100),last_name varchar(100),npi varchar(10),tin varchar(9),is_active bit, deactivation_date datetime,is_enrolled bit)

	   insert into @Tins_Npis
	    exec sp_getFacilityPhysicianNPIsTINs @UserName;

	    SELECT   DISTINCT F.Tin AS TIN
		   ,F.npi
		    ,S.SelectedActivity AS 'IA Measure Number'	
		   -- ,'selected' AS 'Measure Selection Status'	    
		   ,CASE WHEN M.Measure_Name IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
		    ,I.Contribution_Value AS 'Contribution Value'
		    ,I.Measure_Weight AS 'Weight'
		    ,I.Ia_Complete as Complete
		   -- ,I.Ia_Message as 'Message'
		    FROM  tbl_TIN_GPRO T 
		                        INNER JOIN   @Tins_Npis F ON T.TIN=F.TIN  and T.is_GPRO=0

						LEFT JOIN tbl_IA_Users G on G.TIN=T.TIN
								AND F.npi=G.NPI 
								AND G.CMSYear=@CMSYear
		                      LEFT JOIN tbl_IA_User_Selected S ON S.SelectedID=G.SelectedID
                          LEFT JOIN tbl_CI_Source_UniqueKeys SS ON  SS.Tin=G.TIN AND SS.Npi=G.NPI AND SS.Category_Id=@Category_Id AND  SS.IsMSetIdActive=1 AND SS.CmsYear=@CMSYear
						  LEFT  JOIN  tbl_CI_Measuredata_value M ON SS.Key_Id=M.KeyId AND M.Measure_Name=S.SelectedActivity
						 -- LEFT JOIN tbl_CI_Source_UniqueKeys SS ON  SS.Key_Id=M.KeyId AND SS.Tin=G.TIN AND SS.Npi=G.NPI AND SS.Category_Id=@Category_Id AND  SS.IsMSetIdActive=1 AND SS.CmsYear=@CMSYear
						 -- AND M.KeyId=(SELECT MAX(SS.Key_Id) FROM tbl_CI_Source_UniqueKeys SS WHERE SS.Tin=G.TIN AND SS.Npi=G.NPI AND SS.Category_Id=@Category_Id AND  SS.IsMSetIdActive=1 AND SS.CmsYear=@CMSYear)
						  LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name=M.Measure_Name 
																		 AND I.Sub_ScoreId=SS.Score_ResponseId
																		 AND i.Category_Id=SS.Category_Id
															 --AND I.Sub_ScoreId=(SELECT MAX(CS.Sub_ScoreId) FROM tbl_CI_Submission_Score CS WHERE 
															 --CS.Submission_Uniquekey_Id=(SELECT TOP 1 CSS.Submission_Uniquekey_Id FROM tbl_CI_Source_UniqueKeys CSS WHERE 
															 --CSS.Tin=G.TIN AND  CSS.Npi=G.NPI  AND CSS.Category_Id=@Category_Id   AND CSS.IsMSetIdActive=1 AND CSS.CmsYear=@CMSYear) )
			  --WHERE 
			  --G.CMSYear=@CMSYear
			--AND G.TIN='232323233'

			 --UNION

			 -- SELECT DISTINCT TIN
			 -- ,npi as NPI
		   
		  --  ,NULL AS 'IA Measure Number'	
		  -- -- ,'have not selected' AS 'Measure Selection Status'	    
		  -- ,'have not submitted to CMS'  AS 'CMS Submission Status'
		  --  ,0.00 AS 'Contribution Value'
		  --  ,'' AS 'Weight'
		  --  ,'' as Complete
		  ----  ,'' as 'Message'
			 -- FROM @Tins_Npis WHERE  TIN NOT IN (SELECT G.TIN FROM tbl_IA_Users G INNER JOIN tbl_TIN_GPRO T ON G.TIN=T.TIN AND T.is_GPRO=0 AND G.CMSYear=@CMSYear
		  --                      INNER JOIN   @Tins_Npis F ON G.TIN=F.TIN AND F.npi=G.NPI)
			  ORDER BY F.TIN,F.npi

		 
	   END



END
	
	


END






