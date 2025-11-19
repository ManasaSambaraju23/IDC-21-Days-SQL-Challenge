USE HOSPITALS;

-- Join patients, staff, and staff_schedule to show patient service and staff availability.
SELECT
  p.patient_id,
  p.name       AS patient_name,
  p.service    AS patient_service,
  s.staff_id,
  s.staff_name,
  ss.week,
  ss.present
FROM patients p
LEFT JOIN staff s
  ON p.service = s.service              
LEFT JOIN staff_schedule ss
  ON s.staff_id = ss.staff_id           
ORDER BY p.patient_id, s.staff_id, ss.week;

-- Combine services_weekly with staff and staff_schedule for comprehensive service analysis.
SELECT
  sw.service,
  sw.week,
  sw.patients_admitted,
  sw.event,
  COALESCE(ss.present_staff_count, 0) AS present_staff_count
FROM services_weekly sw
LEFT JOIN (
  SELECT
    s.service,
    ss.week,
    COUNT(DISTINCT ss.staff_id) AS present_staff_count
  FROM staff_schedule ss
  JOIN staff s ON ss.staff_id = s.staff_id
  WHERE ss.present = 1         -- change this if your "present" flag is 'Yes'/'Y' etc.
  GROUP BY s.service, ss.week
) ss
  ON ss.service = sw.service
 AND ss.week    = sw.week
ORDER BY sw.service, sw.week;

-- Create a multi-table report showing patient admissions with staff information.

SELECT
  p.patient_id,
  p.name                       AS patient_name,
  p.service                    AS patient_service,
  p.arrival_date,
  sw.week                      AS latest_service_week,
  sw.patients_admitted,
  COALESCE(staff_meta.total_staff, 0)            AS total_staff_in_service,
  COALESCE(staff_meta.weeks_with_staff_present, 0) AS weeks_with_staff_present,
  COALESCE(staff_meta.staff_names, '')           AS staff_names
FROM patients p
LEFT JOIN (
  SELECT sw1.service, sw1.week, sw1.patients_admitted
  FROM services_weekly sw1
  JOIN (
    SELECT service, MAX(week) AS max_week
    FROM services_weekly
    GROUP BY service
  ) t ON t.service = sw1.service AND t.max_week = sw1.week
) sw ON sw.service = p.service
LEFT JOIN (
  SELECT
    s.service,
    COUNT(*) AS total_staff,
    COUNT(DISTINCT CASE WHEN ss.present = 1 THEN ss.week END) AS weeks_with_staff_present,
    GROUP_CONCAT(DISTINCT s.staff_name ORDER BY s.staff_name SEPARATOR ', ') AS staff_names
  FROM staff s
  LEFT JOIN staff_schedule ss ON s.staff_id = ss.staff_id
  GROUP BY s.service
) staff_meta ON staff_meta.service = p.service
ORDER BY p.patient_id;

-- Create a comprehensive service analysis report for week 20 showing: service name, total patients admitted that week, 
-- total patients refused, average patient satisfaction, count of staff assigned to service, 
-- and count of staff present that week. Order by patients admitted descending.

SELECT
  sw.service,
  COALESCE(sw.patients_admitted, 0)        AS patients_admitted,
  COALESCE(sw.patients_refused, 0)         AS patients_refused,
  COALESCE(ROUND(sw.patient_satisfaction, 2), 0) AS avg_patient_satisfaction,
  COALESCE(st.total_staff, 0)              AS total_staff_assigned,
  COALESCE(present.staff_present_count, 0) AS staff_present_count_week20
FROM services_weekly sw
LEFT JOIN (
  SELECT service, COUNT(*) AS total_staff
  FROM staff
  GROUP BY service
) st ON st.service = sw.service
LEFT JOIN (
  SELECT s.service,
         COUNT(DISTINCT ss.staff_id) AS staff_present_count
  FROM staff_schedule ss
  JOIN staff s ON ss.staff_id = s.staff_id
  WHERE ss.week = 20
    AND ss.present = 1
  GROUP BY s.service
) present ON present.service = sw.service
WHERE sw.week = 20
ORDER BY patients_admitted DESC;
