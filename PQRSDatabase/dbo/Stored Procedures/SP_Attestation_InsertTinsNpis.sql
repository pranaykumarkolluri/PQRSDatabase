-- =============================================
-- Author:		Raju Gaddam
-- Create date: 21-Dec-17
-- Description:	Inserting Attested TIN NPIs of User
-- =============================================
CREATE PROCEDURE SP_Attestation_InsertTinsNpis
@FileId int,
@CreatedBy int,
@Attestation_TinNpis_Type Attestation_TinNpis_Type READONLY


AS
BEGIN
insert into tbl_Attestation_TINNPIS
(
FileId
,TIN
,NPI
,CreateDate
,CreatedBy
)
select @FileId,TIN,NPI,GETDATE(),@CreatedBy  from @Attestation_TinNpis_Type

END
