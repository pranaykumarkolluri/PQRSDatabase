-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<For generating QM XML exams for gpro  and non gpro>
--#1 Raju G
--#1 No need to check GPRO condition in tbl_Physician_Aggregation_Year table
--#2 Raju G
--#2 No need to check GPRO condition in tbl_TIN_Aggregation_Year table
-- =============================================
CREATE PROCEDURE [dbo].[spgetQMXML_examscount_TINGpro_NonGpro]
	
AS 
BEGIN
	
--1. Full year Gpro(Tin Level) -107
select count ( distinct TIN) from  tbl_TIN_Aggregation_Year tinaggr
                             inner  join tbl_TIN_GPRO gpros on 
                               tinaggr.Exam_TIN = gpros.TIN
                               inner join  tbl_Lookup_Measure mes on tinaggr.Measure_Num = mes.Measure_num
                             -- join   tbl_Tin_NPI_90Days_Check checks on tinaggr.Exam_TIN = checks.TIN
                               where tinaggr.SelectedForCMSSubmission = 1
                              and (tinaggr.Init_Patient_Population is not  null)
                               and tinaggr.CMS_Submission_Year = 2017
                               and mes.CMSYear = 2017
                               and gpros.is_GPRO=1
                             -- and tinaggr.GPRO = 1 #2
                               and tinaggr.Is_90Days = 0
							   and tinaggr.Exam_TIN not in 
							   (
							   		   select TIN from tbl_Tin_NPI_90Days_Check where ( NPI='' or NPI is null) and is90Days_Checked =1 and  CMSYear=2017
							   )
							   
	--2.Full YEAR Non Gpro -197 files
select Exam_TIN,Physician_NPI from(
select distinct aggr.Exam_TIN , aggr.Physician_NPI from   tbl_Physician_Aggregation_Year aggr
                                join  tbl_TIN_GPRO  gpros on
                                 aggr.Exam_TIN = gpros.TIN
                                join   tbl_Lookup_Measure mes on aggr.Measure_Num = mes.Measure_num
                               -- join  tbl_Tin_NPI_90Days_Check checks on aggr.Physician_NPI = checks.NPI
                                where aggr.SelectedForCMSSubmission = 1
                               -- and aggr.GPRO = 0  #1
                                and gpros.is_GPRO=0 
                               and aggr.CMS_Submission_Year = 2017
                                and  mes.CMSYear = 2017
                            --   and checks.TIN = aggr.Exam_TIN
                             --  and checks.is90Days_Checked = 1
                                and aggr.Is_90Days = 0
								 
								 
 and not exists (
  
  -- 90days Tin/Npi Records -197 Files
							select NPI,TIN	from tbl_Tin_NPI_90Days_Check check90Days
                                     where check90Days.NPI <> '' and check90Days.is90Days_Checked = 1
                                     and  check90Days.CMSYear = 2017 
									 and aggr.Exam_TIN=TIN and aggr.Physician_NPI=NPI)
									 ) as Result						   
							   
	-------------------------------------------------------------------------------------------------------------------						   
							   
-- 3.90days Gpro -28 files						   
							select count ( distinct tinaggr.Exam_TIN) from  tbl_TIN_Aggregation_Year tinaggr
                             inner  join tbl_TIN_GPRO gpros on 
                               tinaggr.Exam_TIN = gpros.TIN
                               inner join  tbl_Lookup_Measure mes on tinaggr.Measure_Num = mes.Measure_num
                              join   tbl_Tin_NPI_90Days_Check checks on tinaggr.Exam_TIN = checks.TIN
                               where tinaggr.SelectedForCMSSubmission = 1
                              and (tinaggr.Init_Patient_Population is not  null)
                               and tinaggr.CMS_Submission_Year = 2017
                               and mes.CMSYear = 2017
                               and gpros.is_GPRO=1  
							   and checks.CMSYear = 2017
                              and  checks.is90Days_Checked = 1
                           --   and tinaggr.GPRO = 1   #2
                               and tinaggr.Is_90Days = 1  
							   
							   






--4.90 days Non Gpro -27 files

select count (distinct aggr.Physician_NPI) from   tbl_Physician_Aggregation_Year aggr
                                join  tbl_TIN_GPRO  gpros on
                                 aggr.Exam_TIN = gpros.TIN
                                join   tbl_Lookup_Measure mes on aggr.Measure_Num = mes.Measure_num
                                join  tbl_Tin_NPI_90Days_Check checks on aggr.Physician_NPI = checks.NPI
                                where aggr.SelectedForCMSSubmission = 1
                            --    and aggr.GPRO = 0 #1
                                and gpros.is_GPRO=0
                               and aggr.CMS_Submission_Year = 2017
                                and  mes.CMSYear = 2017
                               and checks.TIN = aggr.Exam_TIN
                               and checks.is90Days_Checked = 1
                                and aggr.Is_90Days = 1									 
							   
							   
							   
END
