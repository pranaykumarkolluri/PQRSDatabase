-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--Change#1 By: Raju G
--Chnage#1: Jira-785
--Change#2 Sumanth
--Change#2:Jira-784
--Change#3: Raju G
--Change#3: JIRA-798 -IA attestation / added attest condition.
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_IsAnyMeasureDataExistsForCMS]
	@CmsYear int,
	@Tin varchar(9),
	@NPI varchar(10),
	@CategoryId int,
	@Is90days bit,
	@ISGPRO bit
AS
BEGIN
DECLARE @IsMeasureDataExists bit=0;
IF(
@CategoryId=1 
AND @ISGPRO=1 

AND EXISTS( select 1 from tbl_TIN_Aggregation_Year  GT with(nolock)
inner join tbl_GPRO_TIN_Selected_Measures GS with(nolock)
									on 
										GT.CMS_Submission_Year=@CmsYear
										and GT.Exam_TIN=@Tin
										and GT.Is_90Days=@Is90days
										and GT.CMS_Submission_Year=GS.Submission_year														
										and GT.Exam_TIN =GS.TIN 
										and GT.Measure_Num=GS.Measure_num
										and GT.Is_90Days=GS.Is_90Days 										
										and GT.SelectedForCMSSubmission=1
										and gt.SelectedForCMSSubmission=Gs.SelectedForSubmission
										 and ISNULL(GT.Performance_rate,0) <=100.00
										and ISNULL(GT.Reporting_Rate,0) <=100.00
										and GT.Init_Patient_Population is not null

inner join  tbl_TIN_GPRO T  with(nolock)
									on 
										GT.Exam_TIN=T.TIN and T.is_GPRO=1
inner join tbl_Lookup_Measure M with(nolock)
									on  
										M.Measure_num=GT.Measure_Num 
										and GT.CMS_Submission_Year=M.CMSYear 
										and M.ForCMSSubmission=1)
)
BEGIN

SET @IsMeasureDataExists=1
END

ELSE IF(
@CategoryId=1 
AND @ISGPRO=0 

AND EXISTS(select 1 from tbl_Physician_Aggregation_Year GT  with(nolock)
			inner join tbl_Physician_Selected_Measures GS with(nolock)
									on 
										GT.CMS_Submission_Year=@CmsYear
										and GT.Exam_TIN=@Tin
										and GT.Physician_NPI=@NPI
										and GT.Is_90Days=@Is90days
										and GT.CMS_Submission_Year=GS.Submission_year														
										and GT.Exam_TIN =GS.TIN 
										and GT.Physician_NPI=GS.NPI
										and GT.Measure_Num=GS.Measure_num_ID
										and GT.Is_90Days=GS.Is_90Days 							
										and GT.SelectedForCMSSubmission=1
										and gt.SelectedForCMSSubmission=Gs.SelectedForSubmission
										 and ISNULL(GT.Performance_rate,0) <=100.00
										and ISNULL(GT.Reporting_Rate,0) <=100.00
										and GT.Init_Patient_Population is not null
			inner join  tbl_TIN_GPRO T  with(nolock)
									on 
										GT.Exam_TIN=T.TIN and T.is_GPRO=0
			inner join tbl_Lookup_Measure M with(nolock)
							on  
								M.Measure_num=GT.Measure_Num 
								and GT.CMS_Submission_Year=M.CMSYear 
								and M.ForCMSSubmission=1
			)
)
BEGIN

SET @IsMeasureDataExists=1;
END

ELSE IF(@CategoryId=2 AND @ISGPRO=1 AND EXISTS(select 1 from tbl_TIN_GPRO T with(nolock)
join tbl_IA_Users I with(nolock) on T.TIN=I.TIN 
join tbl_IA_User_Selected s with(nolock) on s.SelectedID=i.SelectedID
where I.CMSYear=@CMSYear and T.is_GPRO=1 and T.TIN=@Tin 
and ((@CMSYear >=2020 and IsGpro=1 and  s.attest=1) or @CMSYear<2020)))     --Change#2 ,--Change#3
BEGIN
SET @IsMeasureDataExists=1;
END
ELSE IF (
		  @CategoryId=2 
		  AND @ISGPRO=0 
		  AND EXISTS(select  1 from 
								tbl_IA_Users I  with(nolock)
								inner join 
								tbl_IA_User_Selected S  with(nolock)
										on 
											S.SelectedID =I.SelectedID 
												where I.CMSYear=@CMSYear 
													and I.NPI=@Npi
													and I.TIN 
													not in(select TIN 
							                                  from tbl_TIN_GPRO 
																where is_GPRO=1) 
																and I.TIN=@Tin
					  )
		)


BEGIN
SET @IsMeasureDataExists=1
END
ELSE IF(@CategoryId=3 AND @ISGPRO=1 AND EXISTS(select 1 from tbl_TIN_GPRO T with(nolock)
															join tbl_ACI_Users I with(nolock) on T.TIN=I.TIN
														    join tbl_User_Selected_ACI_Measures s  with(nolock) on s.Selected_Id=i.Selected_Id
															where I.CMSYear=@CMSYear and T.is_GPRO=1 and T.TIN=@Tin
															and ((@CmsYear>=2020 and I.IsGpro=1) or @CmsYear< 2020) --Chnage#1
												) 
	 )
BEGIN
SET @IsMeasureDataExists=1
END
ELSE IF(@CategoryId=3 AND @ISGPRO=0 AND EXISTS
											(	
										select 1 
													from tbl_ACI_Users I with(nolock)
												    join tbl_User_Selected_ACI_Measures S with(nolock)
															on
																S.Selected_Id =I.Selected_Id 
																	where I.CMSYear=@CMSYear 
																	and I.NPI =@Npi
																	 and I.TIN 
																	 not in(select TIN from tbl_TIN_GPRO with(nolock) where is_GPRO=1) 
																	 and I.TIN=@Tin
												)
		)

BEGIN
SET @IsMeasureDataExists=1
END
SELECT @IsMeasureDataExists as result ;
END


