--Find the first engage tag assigned to each student

WITH FirstEngageTag
AS (SELECT
  STH.client_id,
  STH.crms_number,
  STH.tag_type,
  STH.tag_value,
  ROW_NUMBER() OVER (PARTITION BY STH.client_id, STH.crms_number
  ORDER BY STH.client_ID, STH.crms_number, STH.date_created ASC) seq,
  STH.date_created

FROM ZZ_crms_student_tag_history STH

WHERE tag_type = 'engage')

SELECT
  *
FROM FirstEngageTag FET
WHERE FET.seq = 1