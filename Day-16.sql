USE HOSPITALS;

-- Find patients who are in services with above-average staff count.
SELECT
  p.patient_id,
  p.name,
  p.service,
  sps.staff_count
FROM patients p
JOIN (
  SELECT service, COUNT(*) AS staff_count
  FROM staff
  GROUP BY service
) sps ON p.service = sps.service
WHERE sps.staff_count > (
  SELECT AVG(staff_count) 
  FROM (
    SELECT COUNT(*) AS staff_count
    FROM staff
    GROUP BY service
  ) AS svc_counts
)
ORDER BY sps.staff_count DESC, p.patient_id;

-- List staff who work in services that had any week with patient satisfaction below 70.
SELECT
  s.staff_id,
  s.staff_name,
  s.service
FROM staff s
WHERE EXISTS (
  SELECT 1
  FROM services_weekly sw
  WHERE sw.service = s.service
    AND sw.patient_satisfaction IS NOT NULL
    AND sw.patient_satisfaction < 70
)
ORDER BY s.staff_id;

-- Show patients from services where total admitted patients exceed 1000.
SELECT
    p.patient_id,
    p.name,
    p.service
FROM patients p
WHERE p.service IN (
    SELECT service
    FROM services_weekly
    GROUP BY service
    HAVING SUM(patients_admitted) > 1000
)
ORDER BY p.patient_id;

-- Find all patients who were admitted to services that had at least one week where patients were refused AND 
-- the average patient satisfaction for that service was below the overall hospital average satisfaction. 
-- Show patient_id, name, service, and their personal satisfaction score.
SELECT
  p.patient_id,
  p.name,
  p.service,
  p.SATISFACTION AS personal_satisfaction
FROM patients p
JOIN (
  SELECT
    service
  FROM services_weekly
  WHERE patient_satisfaction IS NOT NULL
  GROUP BY service
  HAVING SUM(patients_refused) > 0
     AND AVG(patient_satisfaction) < (
       SELECT AVG(patient_satisfaction)
       FROM services_weekly
       WHERE patient_satisfaction IS NOT NULL
     )
) s ON p.service = s.service
WHERE p.SATISFACTION IS NOT NULL
ORDER BY p.service, p.patient_id;