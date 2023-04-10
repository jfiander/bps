CASE
  WHEN boc_level = 'Inland Navigator'           THEN CONCAT('1', name)
  WHEN boc_level = 'Coastal Navigator'          THEN CONCAT('2', name)
  WHEN boc_level = 'Advanced Coastal Navigator' THEN CONCAT('3', name)
  WHEN boc_level = 'Offshore Navigator'         THEN CONCAT('4', name)
END
