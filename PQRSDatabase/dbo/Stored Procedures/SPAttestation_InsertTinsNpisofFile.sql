-- =============================================
-- Author:		Raju Gaddam
-- Create date: 21-Dec-17
-- Description:	Inserting Attested TIN NPIs of User
-- =============================================
CREATE PROCEDURE [dbo].[SPAttestation_InsertTinsNpisofFile]
@FileId int,
@UserId int


AS
BEGIN
DECLARE @CreatedBy varchar(100);
DECLARE @FACILITYTINS_NPIS TABLE(first_name varchar(100),lastname varchar(100),npi varchar(11),tin varchar(10),is_active bit, deactivation_date datetime,is_enrolled bit)


SELECT top 1 @CreatedBy=UserName FROM tbl_Users WHERE UserID=@UserId 
INSERT INTO @FACILITYTINS_NPIS EXEC sp_getFacilityPhysicianNPIsTINs  @CreatedBy
insert into tbl_Attestation_TINNPIS
(
FileId
,TIN
,NPI
,CreateDate
,CreatedBy
)
--select distinct  @FileId,F.TIN,F.NPI,GETDATE(),@UserId  from @FACILITYTINS_NPIS F inner join tbl_TIN_GPRO G
--on G.TIN=F.tin where G.is_GPRO=0
select distinct  @FileId,F.TIN,F.NPI,GETDATE(),@UserId  from @FACILITYTINS_NPIS F 
END

