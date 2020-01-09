CASE
  WHEN event_category = 'public'     THEN '1' || title
  WHEN event_category = 'advanced_grade' THEN CASE
    WHEN title = 'seamanship'                 THEN '2a'
    WHEN title = 'boat_handling'              THEN '2b'
    WHEN title = 'marine_navigation'          THEN '3a'
    WHEN title = 'piloting'                   THEN '3b'
    WHEN title = 'advanced_piloting'          THEN '4a'
    WHEN title = 'advanced_marine_navigation' THEN '4b'
    WHEN title = 'junior_navigation'          THEN '5a'
    WHEN title = 'offshore_navigation'        THEN '5b'
    WHEN title = 'navigation'                 THEN '6a'
    WHEN title = 'celestial_navigation'       THEN '6b'
  END
  WHEN event_category = 'elective'   THEN '7' || title
  WHEN event_category = 'seminar'    THEN '8' || title
  WHEN event_category = 'meeting'    THEN '9' || title
END
