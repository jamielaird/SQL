--Date of last outbound email by student

WITH LastOutEmail
AS (SELECT
  CC.client_id,
  CC.class,
  CC.in_out,
  CC.headline,
  CC.crms_number,
  CC.date_opened,
  ROW_NUMBER() OVER (PARTITION BY CC.client_id, CC.crms_number
  ORDER BY CC.client_id, CC.crms_number, CC.date_opened DESC) seq_rev
FROM dbo.ZZ_crms_communication CC
WHERE class = 'Email'
AND in_out = 'OUT')

SELECT
  *
FROM LastOutEmail
WHERE seq_rev = 1