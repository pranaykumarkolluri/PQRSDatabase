﻿



CREATE VIEW [dbo].[PHYSICIAN_TIN_VW]
AS
	select NPI,TIN,TIN_DESCRIPTION,REGISTRY_NAME,IS_ENROLLED,
	--CONVERT(BIT,0) as IS_ACTIVE --for testing
	IS_ACTIVE
      ,DEACTIVATION_DATE from NRDR..[PHYSICIAN_TIN_VW]





