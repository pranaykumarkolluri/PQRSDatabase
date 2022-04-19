
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- =============================================
CREATE PROCEDURE [dbo].[SPGetSubmittoCMSTinsCount]
@CMSYear int,
@FaciliyUserName varchar(256),
@UserRole int,  -- 1.Facility 2.Physician 3.ACRStaff
@NPI varchar(10)
AS
BEGIN
	declare @ACRStaffTINS table(	
						TIN varchar(9)		
						)
	declare @GPROTINS table(	
						TIN varchar(9)		
						)

declare @NONGPROTINS table(	
						TIN varchar(9)	,
						NPI varchar(10)	
						)

declare @FacilityTINs table ( TIN varchar(9))

declare @Resultval table(TotalGproTins int,	CMSSubmittedGproTins int,			
TotalNonGproTins int,CMSSubmittedNonGproTins int)
declare @gprotincount int,@NonGprotincount int,@gprotinSubmittedcount int, @NongprotinSubmittedcount int
			
IF(@UserRole =1)
BEGIN

insert into @FacilityTINs
 exec [dbo].[sp_getFacilityTIN] @FaciliyUserName

INSERT INTO @GPROTINS
select distinct Exam_TIN AS TIN from tbl_TIN_Aggregation_Year t 
                         inner join @FacilityTINs f on  t.CMS_Submission_Year=@CMSYear 						                                and t.Exam_TIN=f.TIN
UNION
select distinct t.TIN from tbl_IA_Users t 
                         inner join @FacilityTINs f on  t.CMSYear=@CMSYear and NPI is null				                                and t.TIN=f.TIN														
UNION
select distinct t.TIN from tbl_ACI_Users t 
                         inner join @FacilityTINs f on  t.CMSYear=@CMSYear 
						                                and t.TIN=f.TIN	
														and NPI is null		
														

INSERT INTO @NONGPROTINS
select distinct T.Exam_TIN  AS TIN ,T.Physician_NPI as NPI from tbl_Physician_Aggregation_Year t 
                         INNER JOIN @FacilityTINs f on  t.CMS_Submission_Year=@CMSYear 		
						 				                                and t.Exam_TIN=f.TIN
UNION
select distinct t.TIN,T.NPI from tbl_IA_Users t 
                         INNER JOIN @FacilityTINs f on  t.CMSYear=@CMSYear AND T.NPI IS NOT NULL 					                                and t.TIN=f.TIN														
UNION
select distinct t.TIN,t.NPI from tbl_ACI_Users t 
                         INNER JOIN @FacilityTINs f on  t.CMSYear=@CMSYear 
						                                and t.TIN=f.TIN	
														AND T.NPI IS NOT NULL															
																								
END
ELSE IF(@UserRole=2)
BEGIN

-- insert into @ACRStaffTINS 
--							exec SPGetNpisofTin_VW @NPI
print('')
END
ELSE IF(@UserRole=3)
BEGIN
			 --insert into @ACRStaffTINS 
				--			exec SPGetNpisofTin_VW ''

							
insert into @GPROTINS


select distinct T.Exam_TIN  AS TIN from tbl_TIN_Aggregation_Year t  WHERE CMS_Submission_Year=@CMSYear                        
UNION
select distinct t.TIN from tbl_IA_Users t  WHERE CMSYear=@CMSYear  and NPI is null               
UNION
select distinct t.TIN from tbl_ACI_Users t WHERE CMSYear=@CMSYear and NPI is null


insert into @NONGPROTINS
select distinct T.Exam_TIN  AS TIN,t.Physician_NPI as NPI from tbl_Physician_Aggregation_Year t  WHERE CMS_Submission_Year=@CMSYear                        
UNION
select distinct t.TIN,t.NPI from tbl_IA_Users t  WHERE CMSYear=@CMSYear  AND T.NPI IS NOT NULL                   
UNION
select distinct t.TIN,T.NPI from tbl_ACI_Users t WHERE CMSYear=@CMSYear   AND T.NPI IS NOT NULL 
                      

END





							select @gprotincount= count(*) from  @GPROTINS a 
							select @NonGprotincount= count(*) from @NONGPROTINS

							select  @gprotinSubmittedcount= count( distinct a.Tin) from @GPROTINS a join tbl_CI_Source_UniqueKeys c on a.TIN=c.Tin where 
							
							 c.CmsYear=@CMSYear
							and (c.Npi=''or c.Npi is null)
							and c.IsMSetIdActive=1

							;with NongproCte as
							(
							select  distinct  c.Tin, c.Npi from @NONGPROTINS a join tbl_CI_Source_UniqueKeys c on a.TIN=c.Tin and a.NPI=c.Npi where 
							--t.is_GPRO=0
						    c.CmsYear=@CMSYear
							and  c.Npi is not null
							and c.IsMSetIdActive=1	
							)
							select @NongprotinSubmittedcount = COUNT(*) from NongproCte

							insert into @Resultval	
							select @gprotincount,@gprotinSubmittedcount,@NonGprotincount,@NongprotinSubmittedcount
							--select (convert(varchar(10),@gprotinSubmittedcount)+'/'+convert(varchar(10), @gprotincount)),
							--convert(varchar(10),@NongprotinSubmittedcount)+'/'+convert(varchar(10), @NonGprotincount)
							
							select * from @Resultval


							
END

