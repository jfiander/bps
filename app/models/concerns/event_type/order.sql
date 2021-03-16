CASE
  WHEN event_types.event_category = 'public'     THEN '1' || event_types.title
  WHEN event_types.event_category = 'advanced_grade' THEN CASE
    WHEN event_types.title = 'seamanship'                 THEN '2a'
    WHEN event_types.title = 'boat_handling'              THEN '2b'
    WHEN event_types.title = 'piloting'                   THEN '3a'
    WHEN event_types.title = 'marine_navigation'          THEN '3b'
    WHEN event_types.title = 'advanced_piloting'          THEN '4a'
    WHEN event_types.title = 'advanced_marine_navigation' THEN '4b'
    WHEN event_types.title = 'junior_navigation'          THEN '5a'
    WHEN event_types.title = 'offshore_navigation'        THEN '5b'
    WHEN event_types.title = 'navigation'                 THEN '6a'
    WHEN event_types.title = 'celestial_navigation'       THEN '6b'
  END
  WHEN event_types.event_category = 'elective'   THEN '7' || event_types.title
  WHEN event_types.event_category = 'seminar'    THEN '8' || event_types.title
  WHEN event_types.event_category = 'meeting'    THEN '9' || event_types.title
END
