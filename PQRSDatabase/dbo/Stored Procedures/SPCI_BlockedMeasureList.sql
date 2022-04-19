-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BlockedMeasureList] 
	-- Add the parameters for the stored procedure here
 @CmsYear int,
 @Tin varchar(9),
 @CategoryId int,
 @IsGpro bit
AS
BEGIN

		IF(@CategoryId=1 and @IsGpro=1)
		BEGIN
		 
				
				       SELECT distinct  Bm.Measure  FROM tbl_lookup_block_submission B INNER JOIN
						 tbl_lookup_MeasureBlockList BM on B.BlockId=Bm.BlockId						
		                 INNER JOIN
						 tbl_GPRO_TIN_Selected_Measures T ON 
																B.CMSYear=T.Submission_year
																
																AND B.TIN=T.TIN
																AND T.Is_90Days=0
																AND T.SelectedForSubmission=1
																AND BM.Measure=T.Measure_num
																AND B.CMSYear=@CmsYear
																AND B.TIN=@Tin
																AND B.CategoryId=1
				 
				    
				

		END
		ELSE IF(@CategoryId=1 AND @IsGpro=0)
		BEGIN
			  SELECT distinct Bm.Measure  FROM tbl_lookup_block_submission B INNER JOIN
						 tbl_lookup_MeasureBlockList BM on B.BlockId=Bm.BlockId						
		                 INNER JOIN
						 tbl_Physician_Selected_Measures T ON 
																B.CMSYear=T.Submission_year
																--AND B.CategoryId=1
																AND B.TIN=T.TIN
																AND T.Is_90Days=0
																AND T.SelectedForSubmission=1
																AND BM.Measure=T.Measure_num_ID
																AND B.CMSYear=@CmsYear
																AND B.TIN=@Tin
																AND B.CategoryId=1
		END
		ELSE IF(@CategoryId=2)
		BEGIN
		 PRINT('iA');
		    
        
		   SELECT distinct  Bm.Measure  FROM tbl_lookup_block_submission B INNER JOIN
						 tbl_lookup_MeasureBlockList BM on B.BlockId=Bm.BlockId						
		                 INNER JOIN
		                tbl_IA_Users A ON B.CMSYear=A.CMSYear 
											AND B.TIN=a.TIN
											
											AND  ((@CMSYear>=2020 and A.IsGpro=@IsGpro) or @CMSYear<2020 )
											AND B.CMSYear=@CmsYear
											AND B.TIN=@Tin
											AND B.CategoryId=2
											
						INNER JOIN
						tbl_IA_User_Selected S ON A.SelectedID=S.SelectedID 
												  AND Bm.Measure=S.SelectedActivity
												  AND S.attest = CASE WHEN @IsGpro=1 and @CmsYear>=2020 THEN 1 ELSE  S.attest END
		   
		END
		ELSE IF(@CategoryId=3)
		BEGIN
		 

		 	   SELECT  distinct Bm.Measure  FROM tbl_lookup_block_submission B INNER JOIN
						 tbl_lookup_MeasureBlockList BM on B.BlockId=Bm.BlockId						
		                 INNER JOIN
		                tbl_ACI_Users A ON B.CMSYear=A.CMSYear 
											AND B.TIN=a.TIN
											AND  ((@CMSYear>=2020 and A.IsGpro=@IsGpro) or @CMSYear<2020 )
											AND B.CMSYear=@CmsYear
											AND B.TIN=@Tin
											AND B.CategoryId=3
						INNER JOIN
						tbl_User_Selected_ACI_Measures S ON A.Selected_Id=S.Selected_Id 
												  AND Bm.Measure=S.Selected_MeasureIds


		END


END

