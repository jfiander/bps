CASE
  WHEN committee_name = 'executive'  THEN '1'
  WHEN committee_name = 'auditing'   THEN '2'
  WHEN committee_name = 'nominating' THEN '3'
  WHEN committee_name = 'rules'      THEN '4'
END
