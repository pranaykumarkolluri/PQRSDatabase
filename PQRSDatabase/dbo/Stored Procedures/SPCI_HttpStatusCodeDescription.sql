CREATE PROCEDURE [dbo].[SPCI_HttpStatusCodeDescription]
	as
BEGIN
	select Http_Status_Code, Http_Status_Description from tbl_CI_lookup_Http_Response_Status
	union
	select distinct Status_Code as Http_Status_Code, '' as Http_Status_Description  from tbl_CI_ResponseData
	where Status_Code not in (select Http_Status_Code from tbl_CI_lookup_Http_Response_Status)
END