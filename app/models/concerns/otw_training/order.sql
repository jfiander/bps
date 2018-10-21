CASE
  WHEN boc_level = 'Inland Navigator'           THEN '1' || name
  WHEN boc_level = 'Coastal Navigator'          THEN '2' || name
  WHEN boc_level = 'Advanced Coastal Navigator' THEN '3' || name
  WHEN boc_level = 'Offshore Navigator'         THEN '4' || name
END
