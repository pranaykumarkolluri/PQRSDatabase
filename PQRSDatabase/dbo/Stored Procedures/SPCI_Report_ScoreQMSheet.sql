
-- =============================================
-- Author:		Harikrishna J
-- Create date: Feb 12th,2019
-- Description: get data for qm excel sheet by user
--CHANGE#1:HARI J ON MAR, 26 2019  JIRA#683
-- CHANGE#1:REMOVE THE SPACES BETWEEN 'ACR' MEASURES
--Change#2:JIRA#922
--ChangeBy#2: Raju G
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_Report_ScoreQMSheet]
	-- Add the parameters for the stored procedure here
	@CMSYear int,
	@UserName varchar(50),
	@isTinReport bit,
	@IsACRStaff bit
AS
BEGIN

DECLARE @Category_Id INT=1;---FOR QM
---------- ACR STAFF----------------	
IF(@IsACRStaff=1)
    BEGIN
    ---------- GPRO TIN----------------	
    IF(@isTinReport=1)
	   BEGIN
	  -- print('tin')

	   SELECT F.TIN AS TIN
		    ,G.Measure_num AS 'QM Measure Number'
		    ,CASE WHEN U.SelectedForSubmission=1 THEN 'selected' 
				ELSE 'have not selected' END AS 'Measure Selection Status'
		   ,CASE WHEN M.Measure_Name IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
		    ,I.Measure_Score AS 'Measurement Score Value'
		    ,I.totalBonusPoints AS 'Total Bonus Point'
		    ,I.measurementPicker as 'Processing Status'
		    ,I.feedback_quality as 'Feeback-Quality'
		    ,I.endToEndBonus as 'End to End Bonus'
		    ,I.outcomeOrPatientExperienceBonus as 'Outcome or Patient Experience Bonus'
		    ,I.highPriorityBonus as 'High Priority Bonus'
		    ,I.totaldecileScore as 'Decile Score'
	 
	
		    FROM tbl_TIN_GPRO F LEFT JOIN  tbl_TIN_Aggregation_Year G ON G.Exam_TIN=F.TIN AND G.CMS_Submission_Year=@CMSYear
			 and (G.Measure_Num not like '%Q%' and G.Measure_Num not like '%acr%' )--Change#2
									     LEFT JOIN tbl_GPRO_TIN_Selected_Measures U ON U.Tin=G.Exam_TIN AND 
										                                               U.Measure_num=G.Measure_Num
																			  AND U.Submission_year=G.CMS_Submission_Year
											LEFT JOIN tbl_CI_Source_UniqueKeys SS  ON  SS.Tin=G.Exam_TIN AND (SS.Npi IS NULL OR SS.Npi ='') AND  SS.IsMSetIdActive=1 AND SS.Category_Id=@Category_Id AND SS.CmsYear=@CMSYear
										   LEFT  JOIN  tbl_CI_Measuredata_value M ON SS.Key_Id=M.KeyId AND M.Measure_Name=CASE WHEN LEN(G.Measure_num)=1 THEN   '00'+G.Measure_num
																						WHEN LEN(G.Measure_num)=2 THEN   '0'+G.Measure_num
																						ELSE REPLACE(G.Measure_num,' ','') -- CHANGE#1:
																						END
																						

										   --AND M.KeyId=(SELECT MAX(SS.Key_Id) FROM tbl_CI_Source_UniqueKeys SS WHERE SS.Tin=G.Exam_TIN AND (SS.Npi IS NULL OR SS.Npi ='') AND  SS.IsMSetIdActive=1 AND SS.Category_Id=@Category_Id AND SS.CmsYear=@CMSYear)
										   LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name=M.Measure_Name 
																						    AND I.Sub_ScoreId=SS.Score_ResponseId
																							AND i.Category_Id=sS.Category_Id
																			  --AND I.Sub_ScoreId=(SELECT MAX(CS.Sub_ScoreId) FROM tbl_CI_Submission_Score CS WHERE 
																			  --CS.Submission_Uniquekey_Id=(SELECT TOP 1 CSS.Submission_Uniquekey_Id FROM tbl_CI_Source_UniqueKeys CSS WHERE 
																			  --CSS.Tin=G.Exam_TIN AND (CSS.Npi IS NULL OR CSS.Npi ='') AND CSS.IsMSetIdActive=1 AND CSS.Category_Id=@Category_Id AND CSS.CmsYear=@CMSYear) )
		   WHERE 
		   F.IS_GPRO=1 order by F.TIN
			--AND G.TIN='232323233'
		   -- UNION

			  --SELECT DISTINCT TIN
		   
		   --  ,NULL AS 'QM Measure Number'
		   -- ,'have not selected'  AS 'Measure Selection Status'
		   --,'have not submitted to CMS'  AS 'CMS Submission Status'
		   -- ,null AS 'Measurement Score Value'
		   -- ,null AS 'Total Bonus Point'
		   -- ,null as 'Processing Status'
		   -- ,null as 'Feeback-Quality'
		   -- ,null as 'End to End Bonus'
		   -- ,null as 'Outcome or Patient Experience Bonus'
		   -- ,null as 'High Priority Bonus'
		   -- ,null as 'Decile Score'
			  --FROM tbl_TIN_GPRO WHERE IS_GPRO=1 AND TIN NOT IN (SELECT G.Exam_TIN FROM tbl_TIN_Aggregation_Year G INNER JOIN tbl_TIN_GPRO T ON G.Exam_TIN=T.TIN AND T.is_GPRO=1 AND G.CMS_Submission_Year=@CMSYear)
			  --ORDER BY G.Exam_TIN
	   END
    ----------NON GPRO TIN----------------	
    ELSE

	   BEGIN
	  -- print('tin npi')

	 		--Declare @AllTINNPIs as Table(NPI Varchar(10),TIN varchar(9))
			 --INSERT into @AllTINNPIs
			 --select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW]

	   SELECT P.TIN AS TIN
		    ,P.NPI
		    ,G.Measure_Num AS 'QM Measure Number'
		    ,CASE WHEN U.SelectedForSubmission=1 THEN 'selected' 
				ELSE 'have not selected' END AS 'Measure Selection Status'
		   ,CASE WHEN M.Measure_Name IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
		    ,I.Measure_Score AS 'Measurement Score Value'
		    ,I.totalBonusPoints AS 'Total Bonus Point'
		    ,I.measurementPicker as 'Processing Status'
		    ,I.feedback_quality as 'Feeback-Quality'
		    ,I.endToEndBonus as 'End to End Bonus'
		    ,I.outcomeOrPatientExperienceBonus as 'Outcome or Patient Experience Bonus'
		    ,I.highPriorityBonus as 'High Priority Bonus'
		    ,I.totaldecileScore as 'Decile Score'
	 
	FROM NRDR..PHYSICIAN_TIN_VW P INNER JOIN tbl_TIN_GPRO TG ON P.TIN=TG.TIN collate DATABASE_DEFAULT AND TG.is_GPRO=0 
		     LEFT JOIN tbl_Physician_Aggregation_Year G ON G.Exam_TIN=TG.TIN 
			                                               AND G.Physician_NPI=P.NPI collate DATABASE_DEFAULT
			                                             AND G.CMS_Submission_Year=@CMSYear
														 and  (G.Measure_Num not like '%Q%' and G.Measure_Num not like '%acr%' ) --Change#2

										    --INNER JOIN   @AllTINNPIs F ON G.Exam_TIN=F.TIN AND F.npi=G.Physician_NPI
									       LEFT JOIN tbl_Physician_Selected_Measures U ON U.Tin=G.Exam_TIN 
										                                           AND U.NPI=G.Physician_NPI
																		   AND U.Measure_num_ID=G.Measure_Num
																		   AND U.Submission_year=G.CMS_Submission_Year
																					  LEFT JOIN tbl_CI_Source_UniqueKeys SS  ON  SS.Tin=G.Exam_TIN AND (SS.Npi IS NULL OR SS.Npi ='') AND  SS.IsMSetIdActive=1 AND SS.Category_Id=@Category_Id AND SS.CmsYear=@CMSYear							
										   LEFT  JOIN  tbl_CI_Measuredata_value M ON SS.Key_Id=M.KeyId AND M.Measure_Name=CASE WHEN LEN(G.Measure_Num)=1 THEN   '00'+G.Measure_Num
																						WHEN LEN(G.Measure_Num)=2 THEN   '0'+G.Measure_Num
																						ELSE REPLACE(G.Measure_num,' ','') -- CHANGE#1:
																						END

										  -- AND M.KeyId=(SELECT MAX(SS.Key_Id) FROM tbl_CI_Source_UniqueKeys SS WHERE SS.Tin=G.Exam_TIN AND SS.Npi =G.Physician_NPI  AND  SS.IsMSetIdActive=1 AND SS.Category_Id=@Category_Id AND SS.CmsYear=@CMSYear)
										   LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name=M.Measure_Name 
																							 AND I.Sub_ScoreId=SS.Score_ResponseId
																							 AND i.Category_Id=sS.Category_Id
																			  --AND I.Sub_ScoreId=(SELECT MAX(CS.Sub_ScoreId) FROM tbl_CI_Submission_Score CS WHERE 
																			  --CS.Submission_Uniquekey_Id=(SELECT TOP 1 CSS.Submission_Uniquekey_Id FROM tbl_CI_Source_UniqueKeys CSS WHERE
																			  -- CSS.Tin=G.Exam_TIN AND  CSS.Npi=G.Physician_NPI AND CSS.IsMSetIdActive=1 AND CSS.Category_Id=@Category_Id AND CSS.CmsYear=@CMSYear) )
		   --WHERE 
		   --T.is_GPRO=0
			--AND G.TIN='232323233'
		  --UNION

			 -- SELECT DISTINCT TIN
			 -- ,NPI
		   
		  --   ,NULL AS 'QM Measure Number'
		  --  ,'have not selected'  AS 'Measure Selection Status'
		  -- ,'have not submitted to CMS'  AS 'CMS Submission Status'
		  --  ,null AS 'Measurement Score Value'
		  --  ,null AS 'Total Bonus Point'
		  --  ,null as 'Processing Status'
		  --  ,null as 'Feeback-Quality'
		  --  ,null as 'End to End Bonus'
		  --  ,null as 'Outcome or Patient Experience Bonus'
		  --  ,null as 'High Priority Bonus'
		  --  ,null as 'Decile Score'
			 -- FROM @AllTINNPIs WHERE  TIN NOT IN (SELECT G.Exam_TIN  FROM tbl_Physician_Aggregation_Year G INNER JOIN tbl_TIN_GPRO T ON G.Exam_TIN=T.TIN AND T.is_GPRO=0 AND G.CMS_Submission_Year=@CMSYear

				--						                        INNER JOIN   @AllTINNPIs F ON G.Exam_TIN=F.TIN AND F.npi=G.Physician_NPI)
			  ORDER BY P.TIN,P.NPI,G.Measure_Num
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

	   SELECT F.TIN AS TIN
		    ,G.Measure_num AS 'QM Measure Number'
		    ,CASE WHEN U.SelectedForSubmission=1 THEN 'selected' 
				ELSE 'have not selected' END AS 'Measure Selection Status'
		   ,CASE WHEN M.Measure_Name IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
		    ,I.Measure_Score AS 'Measurement Score Value'
		    ,I.totalBonusPoints AS 'Total Bonus Point'
		    ,I.measurementPicker as 'Processing Status'
		    ,I.feedback_quality as 'Feeback-Quality'
		    ,I.endToEndBonus as 'End to End Bonus'
		    ,I.outcomeOrPatientExperienceBonus as 'Outcome or Patient Experience Bonus'
		    ,I.highPriorityBonus as 'High Priority Bonus'
		    ,I.totaldecileScore as 'Decile Score'
	 
	
		     FROM @facilitytins F  LEFT JOIN  tbl_TIN_Aggregation_Year G ON G.Exam_TIN=F.TIN AND G.CMS_Submission_Year=@CMSYear 
			                                                      and (G.Measure_Num not like '%Q%' and G.Measure_Num not like '%acr%' ) --Change#2
									     LEFT JOIN tbl_GPRO_TIN_Selected_Measures U ON U.Tin=G.Exam_TIN AND 
										                                               U.Measure_num=G.Measure_Num
																			  AND U.Submission_year=G.CMS_Submission_Year
												LEFT JOIN tbl_CI_Source_UniqueKeys SS  ON  SS.Tin=G.Exam_TIN AND (SS.Npi IS NULL OR SS.Npi ='') AND  SS.IsMSetIdActive=1 AND SS.Category_Id=@Category_Id AND SS.CmsYear=@CMSYear
										   LEFT  JOIN  tbl_CI_Measuredata_value M ON SS.Key_Id=M.KeyId AND M.Measure_Name=CASE WHEN LEN(G.Measure_num)=1 THEN   '00'+G.Measure_num
																						WHEN LEN(G.Measure_num)=2 THEN   '0'+G.Measure_num
																						ELSE REPLACE(G.Measure_num,' ','') -- CHANGE#1:
																						END
										
										   --AND M.KeyId=(SELECT MAX(SS.Key_Id) FROM tbl_CI_Source_UniqueKeys SS WHERE SS.Tin=G.Exam_TIN AND (SS.Npi IS NULL OR SS.Npi ='') AND  SS.IsMSetIdActive=1 AND SS.Category_Id=@Category_Id AND SS.CmsYear=@CMSYear)
										   LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name=M.Measure_Name 
																			AND I.Sub_ScoreId=SS.Score_ResponseId
																		 AND i.Category_Id=sS.Category_Id
																			  --AND I.Sub_ScoreId=(SELECT MAX(CS.Sub_ScoreId) FROM tbl_CI_Submission_Score CS WHERE 
																			  --CS.Submission_Uniquekey_Id=(SELECT TOP 1 CSS.Submission_Uniquekey_Id FROM tbl_CI_Source_UniqueKeys CSS WHERE 
																			  --CSS.Tin=G.Exam_TIN AND (CSS.Npi IS NULL OR CSS.Npi ='') AND CSS.IsMSetIdActive=1 AND CSS.Category_Id=@Category_Id AND CSS.CmsYear=@CMSYear) )
		   WHERE F.IS_GPRO=1 order by F.TIN,G.Measure_Num
			--AND G.TIN='232323233'
		   -- UNION

			  --SELECT DISTINCT TIN
		   
		   --  ,NULL AS 'QM Measure Number'
		   -- ,'have not selected'  AS 'Measure Selection Status'
		   --,'have not submitted to CMS'  AS 'CMS Submission Status'
		   -- ,null AS 'Measurement Score Value'
		   -- ,null AS 'Total Bonus Point'
		   -- ,null as 'Processing Status'
		   -- ,null as 'Feeback-Quality'
		   -- ,null as 'End to End Bonus'
		   -- ,null as 'Outcome or Patient Experience Bonus'
		   -- ,null as 'High Priority Bonus'
		   -- ,null as 'Decile Score'
			  --FROM @facilitytins WHERE IS_GPRO=1 AND TIN NOT IN (SELECT G.Exam_TIN FROM tbl_TIN_Aggregation_Year G INNER JOIN @facilitytins T ON G.Exam_TIN=T.TIN AND T.is_GPRO=1 AND G.CMS_Submission_Year=@CMSYear)
			  --ORDER BY G.Exam_TIN,  G.Measure_Num 
	   END
	    ----------NON GPRO TIN----------------	
    ELSE

	   BEGIN
	  -- print('tin npi')

	   DECLARE @Tins_Npis table(first_name varchar(100),last_name varchar(100),npi varchar(10),tin varchar(9),is_active bit, deactivation_date datetime,is_enrolled bit)

	   insert into @Tins_Npis
	    exec sp_getFacilityPhysicianNPIsTINs @UserName;

	   SELECT DISTINCT F.TIN AS TIN
		    ,F.npi
		    ,G.Measure_Num AS 'QM Measure Number'
		    ,CASE WHEN U.SelectedForSubmission=1 THEN 'selected' 
				ELSE 'have not selected' END AS 'Measure Selection Status'
		   ,CASE WHEN M.Measure_Name IS NOT NULL  THEN 'submitted to CMS' 
				ELSE 'have not submitted to CMS' END AS 'CMS Submission Status'
		    ,I.Measure_Score AS 'Measurement Score Value'
		    ,I.totalBonusPoints AS 'Total Bonus Point'
		    ,I.measurementPicker as 'Processing Status'
		    ,I.feedback_quality as 'Feeback-Quality'
		    ,I.endToEndBonus as 'End to End Bonus'
		    ,I.outcomeOrPatientExperienceBonus as 'Outcome or Patient Experience Bonus'
		    ,I.highPriorityBonus as 'High Priority Bonus'
		    ,I.totaldecileScore as 'Decile Score'
	 
	
		    FROM tbl_TIN_GPRO T  INNER JOIN  @Tins_Npis F ON T.TIN=F.TIN  AND T.is_GPRO=0

										    LEFT JOIN tbl_Physician_Aggregation_Year G ON G.Exam_TIN=T.TIN 
											                                           AND F.npi=G.Physician_NPI
											                                           AND G.CMS_Submission_Year=@CMSYear
																					   and (G.Measure_Num not like '%Q%' and G.Measure_Num not like '%acr%' ) --Change#2
									       LEFT JOIN tbl_Physician_Selected_Measures U ON U.Tin=G.Exam_TIN 
										                                           AND U.NPI=G.Physician_NPI
																		   AND U.Measure_num_ID=G.Measure_Num
																		   AND U.Submission_year=G.CMS_Submission_Year
                                          		 LEFT JOIN tbl_CI_Source_UniqueKeys SS  ON  SS.Tin=G.Exam_TIN AND SS.Npi =G.Physician_NPI  AND  SS.IsMSetIdActive=1 AND SS.Category_Id=@Category_Id AND SS.CmsYear=@CMSYear
										  LEFT  JOIN  tbl_CI_Measuredata_value M ON SS.Key_Id=M.KeyId AND M.Measure_Name=CASE WHEN LEN(G.Measure_Num)=1 THEN   '00'+G.Measure_Num
																						WHEN LEN(G.Measure_Num)=2 THEN   '0'+G.Measure_Num
																						ELSE REPLACE(G.Measure_num,' ','') -- CHANGE#1:
																						END
								
										  -- AND M.KeyId=(SELECT MAX(SS.Key_Id) FROM tbl_CI_Source_UniqueKeys SS WHERE SS.Tin=G.Exam_TIN AND SS.Npi =G.Physician_NPI  AND  SS.IsMSetIdActive=1 AND SS.Category_Id=@Category_Id AND SS.CmsYear=@CMSYear)
										   LEFT JOIN tbl_CI_Individual_Measure_Score I ON I.Measure_Name=M.Measure_Name 
																						AND I.Sub_ScoreId=SS.Score_ResponseId
																						AND i.Category_Id=sS.Category_Id
																			  --AND I.Sub_ScoreId=(SELECT MAX(CS.Sub_ScoreId) FROM tbl_CI_Submission_Score CS WHERE 
																			  --CS.Submission_Uniquekey_Id=(SELECT TOP 1 CSS.Submission_Uniquekey_Id FROM tbl_CI_Source_UniqueKeys CSS WHERE 
																			  --CSS.Tin=G.Exam_TIN AND  CSS.Npi=G.Physician_NPI  AND CSS.IsMSetIdActive=1 AND CSS.Category_Id=@Category_Id  AND CSS.CmsYear=@CMSYear) )
		  
			--AND G.TIN='232323233'
		   --  UNION

			  --SELECT DISTINCT TIN
			  --,NPI
		   
		   --  ,NULL AS 'QM Measure Number'
		   -- ,'have not selected'  AS 'Measure Selection Status'
		   --,'have not submitted to CMS'  AS 'CMS Submission Status'
		   -- ,null AS 'Measurement Score Value'
		   -- ,null AS 'Total Bonus Point'
		   -- ,null as 'Processing Status'
		   -- ,null as 'Feeback-Quality'
		   -- ,null as 'End to End Bonus'
		   -- ,null as 'Outcome or Patient Experience Bonus'
		   -- ,null as 'High Priority Bonus'
		   -- ,null as 'Decile Score'
			  --FROM @Tins_Npis WHERE  TIN NOT IN (SELECT G.Exam_TIN  FROM tbl_Physician_Aggregation_Year G INNER JOIN tbl_TIN_GPRO T ON G.Exam_TIN=T.TIN AND T.is_GPRO=0 AND G.CMS_Submission_Year=@CMSYear

					--					                        INNER JOIN   @Tins_Npis F ON G.Exam_TIN=F.TIN AND F.npi=G.Physician_NPI)
			  ORDER BY F.tin,g.Measure_Num
	   END



END
	
	

	
END





