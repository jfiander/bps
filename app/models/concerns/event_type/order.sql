CASE
  WHEN event_category = 'public'     THEN '1' || title
  WHEN event_category = 'advanced_grade' THEN CASE
    WHEN title = 'seamanship'        THEN '2'
    WHEN title = 'piloting'          THEN '3'
    WHEN title = 'advanced_piloting' THEN '4'
    WHEN title = 'junior_navigation' THEN '5'
    WHEN title = 'navigation'        THEN '6'
  END
  WHEN event_category = 'elective'   THEN '7' || title
  WHEN event_category = 'seminar'    THEN '8' || title
  WHEN event_category = 'meeting'    THEN '9' || title
END
