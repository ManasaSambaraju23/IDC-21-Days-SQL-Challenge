USE HOSPITALS;
-- Find all weeks in services_weekly where no special event occurred.

SELECT distinct WEEK FROM SERVICES_WEEKLY
WHERE EVENT IS NULL OR EVENT = 'none';

-- Count how many records have null or empty event values

SELECT COUNT(*) AS NO_EVENT_DAYS 
FROM SERVICES_WEEKLY 
WHERE EVENT IS NULL OR EVENT = 'none';

-- List all services that had at least one week with a special event.
SELECT DISTINCT SERVICE
FROM SERVICES_WEEKLY
WHERE EVENT IS NOT NULL
  AND EVENT <> 'none';
  
-- Analyze the event impact by comparing weeks with events vs weeks without events. 
-- Show: event status ('With Event' or 'No Event'), count of weeks, average patient satisfaction, and average staff morale.
-- Order by average patient satisfaction descending.

SELECT
  CASE
    WHEN EVENT IS NOT NULL
         AND EVENT <> 'none' THEN 'With Event'
    ELSE 'No Event'
  END AS event_status,
  COUNT(*) AS weeks_count,                         
  ROUND(AVG(PATIENT_SATISFACTION), 2) AS avg_patient_satisfaction,
  ROUND(AVG(STAFF_MORALE), 2) AS avg_staff_morale
FROM SERVICES_WEEKLY
GROUP BY
  CASE
    WHEN EVENT IS NOT NULL
       AND EVENT <> 'none' THEN 'With Event'
    ELSE 'No Event'
  END
ORDER BY avg_patient_satisfaction DESC;

