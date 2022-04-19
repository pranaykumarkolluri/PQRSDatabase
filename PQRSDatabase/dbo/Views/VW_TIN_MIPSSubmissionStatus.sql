
CREATE VIEW [dbo].[VW_TIN_MIPSSubmissionStatus]
AS
     SELECT DISTINCT
            p.TIN,
            CASE
                WHEN T.TIN IS NOT NULL
                THEN 'Yes'
                ELSE 'No'
            END AS 'SubmittedtoMIPS'
     FROM NRDR..PHYSICIAN_TIN_VW P
          LEFT JOIN tbl_TIN_GPRO T ON p.TIN = T.TIN COLLATE DATABASE_DEFAULT;

