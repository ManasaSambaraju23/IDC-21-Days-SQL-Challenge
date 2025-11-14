USE HOSPITALS;
-- List all unique services in the patients table
SELECT DISTINCT(SERVICE) 
FROM PATIENTS;

-- Find all unique staff roles in the hospital.
SELECT DISTINCT(ROLE) 
FROM STAFF;

-- Get distinct months from the services_weekly table.
SELECT DISTINCT(MONTH) 
FROM services_weekly;

-- Find all unique combinations of service and event type from the services_weekly table where events are not null or none,
-- along with the count of occurrences for each combination. Order by count descending.
SELECT 
    SERVICE,
    EVENT,
    COUNT(*) AS OCCURRENCE_COUNT
FROM SERVICES_WEEKLY
WHERE EVENT IS NOT NULL 
  AND EVENT <> 'none'          
GROUP BY SERVICE, EVENT
ORDER BY OCCURRENCE_COUNT DESC;
