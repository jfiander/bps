CASE
  WHEN event_category = 'public'     THEN '1' || title
  WHEN event_category = 'advanced_grade' THEN CASE
    WHEN title = 'seamanship'                 THEN '2'
    WHEN title = 'boat_handling'              THEN '3'
    WHEN title = 'marine_navigation'          THEN '4'
    WHEN title = 'piloting'                   THEN '5'
    WHEN title = 'advanced_piloting'          THEN '6'
    WHEN title = 'advanced_marine_navigation' THEN '7'
    WHEN title = 'junior_navigation'          THEN '8'
    WHEN title = 'offshore_navigation'        THEN '9'
    WHEN title = 'navigation'                 THEN '10'
    WHEN title = 'celestial_navigation'       THEN '11'
  END
  WHEN event_category = 'elective'   THEN '12' || title
  WHEN event_category = 'seminar'    THEN '13' || title
  WHEN event_category = 'meeting'    THEN '14' || title
END
