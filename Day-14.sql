USE HOSPITALS;

-- Show all staff members and their schedule information (including those with no schedule entries).

SELECT * 
FROM STAFF S
LEFT JOIN STAFF_SCHEDULE ST
ON S.STAFF_ID = ST.STAFF_ID

-- List all services from services_weekly and their corresponding staff (show services even if no staff assigned).
SELECT * 
FROM SERVICES_WEEKLY SW
LEFT JOIN STAFF S
ON SW.SERVICE = S.SERVICE;

-- Display all patients and their service's weekly statistics 
SELECT
    P.PATIENT_ID,
    P.NAME,
    SW.WEEK,
    SW.SERVICE
FROM PATIENTS P
LEFT JOIN SERVICES_WEEKLY SW 
    ON SW.SERVICE = P.SERVICE
GROUP BY 
    P.PATIENT_ID, P.NAME,
    SW.WEEK, SW.SERVICE;

--  Create a staff utilisation report showing all staff members (staff_id, staff_name, role, service) 
-- and the count of weeks they were present (from staff_schedule). Include staff members even if they have no schedule records.
-- Order by weeks present descending.   

SELECT
  s.staff_id,
  s.staff_name,
  s.role,
  s.service,
  COALESCE(
    COUNT(DISTINCT CASE WHEN ss.present = 1 THEN ss.week END),
    0
  ) AS weeks_present
FROM staff s
LEFT JOIN staff_schedule ss
  ON s.staff_id = ss.staff_id
GROUP BY
  s.staff_id,
  s.staff_name,
  s.role,
  s.service
ORDER BY weeks_present DESC;
 