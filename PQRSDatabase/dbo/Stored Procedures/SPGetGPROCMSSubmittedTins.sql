-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPGetGPROCMSSubmittedTins]
	@CMSYear int,
	@FaciliyUserName varchar(256),
@UserRole int,  -- 1.Facility 2.Physician 3.ACRStaff
@NPI varchar(10)
AS
BEGIN
	
	declare @ACRStaffTINS table(	
						TIN varchar(9)		
						)
	declare @FacilityTINs table(	
						TIN varchar(9)		
						)

						declare @GproTins table(Tin varchar(9))
						declare @Resultset table(Tin varchar(9),Category varchar(10))

									
IF(@UserRole =1)
BEGIN
insert into @FacilityTINs
exec [dbo].[sp_getFacilityTIN] @FaciliyUserName


INSERT INTO @ACRStaffTINS
select distinct Exam_TIN AS TIN from tbl_TIN_Aggregation_Year t 
                         inner join @FacilityTINs f on  t.CMS_Submission_Year=@CMSYear 						                                and t.Exam_TIN=f.TIN
UNION
select distinct t.TIN from tbl_IA_Users t 
                         inner join @FacilityTINs f on  t.CMSYear=@CMSYear and NPI is null 						                                and t.TIN=f.TIN														
UNION
select distinct t.TIN from tbl_ACI_Users t 
                         inner join @FacilityTINs f on  t.CMSYear=@CMSYear  and NPI is null 
						                                and t.TIN=f.TIN	

END
ELSE IF(@UserRole=2)
BEGIN

 insert into @ACRStaffTINS 
							exec SPGetNpisofTin_VW @NPI
print('')
END
ELSE IF(@UserRole=3)
BEGIN

insert into @ACRStaffTINS			
select distinct T.Exam_TIN  AS TIN from tbl_TIN_Aggregation_Year t  WHERE CMS_Submission_Year=@CMSYear                        
UNION
select distinct t.TIN from tbl_IA_Users t  WHERE CMSYear=@CMSYear   and NPI is null                   
UNION
select distinct t.TIN from tbl_ACI_Users t WHERE CMSYear=@CMSYear and NPI is null 


END

	--insert into @GproTins 
 --   select distinct a.TIN
 --   from tbl_TIN_GPRO t join @ACRStaffTINS a on t.TIN=a.TIN where 
	--t.is_GPRO=1
								
							
										

declare @Categorys varchar(10)
							
DECLARE 
    @Tin VARCHAR(9)
    --@list_price   DECIMAL;

DECLARE cursor_Tins CURSOR
FOR SELECT *
       
    FROM 
 @ACRStaffTINS

OPEN cursor_Tins;

FETCH NEXT FROM cursor_Tins INTO 
    @Tin
    

WHILE @@FETCH_STATUS = 0
    BEGIN
	    		
       select @Categorys=  COALESCE(@Categorys + ',', '') + CAST(c.Category_Id AS VARCHAR(5))
							 from tbl_CI_Source_UniqueKeys c where 
							--t.is_GPRO=1
							 c.CmsYear=@CMSYear
							and (c.Npi=''or c.Npi is null)
							and c.IsMSetIdActive=1
							and c.Tin=@Tin
							if(SUBSTRING (@Categorys, 1, 1)=',')
							begin
							set @Categorys= substring(@Categorys, 2, len(@Categorys)-1)
							end
							insert into @Resultset
							select @Tin as Tin, @Categorys as Category
							set @Categorys=''
        FETCH NEXT FROM cursor_Tins INTO 
            @Tin
            
    END;

CLOSE cursor_Tins;

DEALLOCATE cursor_Tins;

select * from @Resultset

END

