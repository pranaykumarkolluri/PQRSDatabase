-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPGetNonGproCMSSubmittedTins]
	@CMSYear int,
	@FaciliyUserName varchar(256),
@UserRole int,  -- 1.Facility 2.Physician 3.ACRStaff
@NPIs varchar(10)
AS
BEGIN
declare @ACRStaffTINS table(	TIN varchar(9),Npi varchar(10)		)
declare @FacilityTINs table(	TIN varchar(9)		)
	declare @Resultset table(Tin varchar(9)
						,Npi varchar(10)
						,Category varchar(10))

IF(@UserRole =1)
BEGIN
insert into @FacilityTINs
exec [dbo].[sp_getFacilityTIN] @FaciliyUserName


INSERT INTO @ACRStaffTINS
select distinct T.Exam_TIN  AS TIN, t.Physician_NPI as Npi from tbl_Physician_Aggregation_Year t 
                         INNER JOIN @FacilityTINs f on  t.CMS_Submission_Year=@CMSYear 						                                and t.Exam_TIN=f.TIN
UNION
select distinct t.TIN,t.NPI as Npi from tbl_IA_Users t 
                         INNER JOIN @FacilityTINs f on  t.CMSYear=@CMSYear AND T.NPI IS NOT NULL 					                                and t.TIN=f.TIN														
UNION
select distinct t.TIN,t.NPI as Npi from tbl_ACI_Users t 
                         INNER JOIN @FacilityTINs f on  t.CMSYear=@CMSYear 
						                                and t.TIN=f.TIN	
														AND T.NPI IS NOT NULL	

END
ELSE IF(@UserRole=2)
BEGIN

 insert into @ACRStaffTINS 
							exec SPGetNpisofTin_VW @NPIs
print('')
END
ELSE IF(@UserRole=3)
BEGIN

insert into @ACRStaffTINS			
select distinct T.Exam_TIN  AS TIN,t.Physician_NPI as NPI from tbl_Physician_Aggregation_Year t  WHERE CMS_Submission_Year=@CMSYear                        
UNION
select distinct t.TIN,T.NPI AS NPI from tbl_IA_Users t  WHERE CMSYear=@CMSYear and t.NPI is not null                    
UNION
select distinct t.TIN,T.NPI AS NPI from tbl_ACI_Users t WHERE CMSYear=@CMSYear  and t.NPI is not null 


END

						
			
										

declare @Categorys varchar(10)
--declare @Npi varchar(10)
							
DECLARE 
    @Tin VARCHAR(9),
	@Npi varchar(10)

DECLARE cursor_TinNpis CURSOR
FOR SELECT *
       
    FROM 
 @ACRStaffTINS

OPEN cursor_TinNpis;

FETCH NEXT FROM cursor_TinNpis INTO 
    @Tin
	,@Npi
    

WHILE @@FETCH_STATUS = 0
    BEGIN	   
       select  @Categorys=  COALESCE(@Categorys + ',', '') + CAST(c.Category_Id AS VARCHAR(5))
							 from @ACRStaffTINS a join tbl_CI_Source_UniqueKeys c on a.TIN=c.Tin and a.Npi=c.Npi where 
							--t.is_GPRO=0
							 c.CmsYear=@CMSYear
							and ( c.Npi=@Npi)
							and c.IsMSetIdActive=1
							and c.Tin=@Tin
							if(SUBSTRING (@Categorys, 1, 1)=',')
							begin
							set @Categorys= right(@Categorys, len(@Categorys)-1)
							end
							insert into @Resultset
							select @Tin as Tin
							,@Npi as Npi
							, @Categorys as Category
							set @Categorys=''
        FETCH NEXT FROM cursor_TinNpis INTO 
            @Tin
			,@Npi
            
    END;

CLOSE cursor_TinNpis;

DEALLOCATE cursor_TinNpis;

select * from @Resultset
END
