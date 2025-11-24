USE HOSPITALS;
-- Show each patient with their service's average satisfaction as an additional column.
SELECT
    p.patient_id,
    p.name,
    p.service,
    ROUND(sw.service_avg_satisfaction, 2) AS service_avg_satisfaction
FROM patients p
LEFT JOIN (
    SELECT 
        service,
        AVG(patient_satisfaction) AS service_avg_satisfaction
    FROM services_weekly
    WHERE patient_satisfaction IS NOT NULL
    GROUP BY service
) sw ON sw.service = p.service
ORDER BY p.patient_id;

-- Create a derived table of service statistics and query from it.
SELECT
  svc.service,
  svc.total_admitted,
  svc.total_refused,
  svc.avg_satisfaction,
  svc.weeks_reported,
  COALESCE(st.total_staff, 0)          AS total_staff,
  COALESCE(pres.staff_present_weeks,0) AS staff_present_weeks
FROM
(
  SELECT
    service,
    SUM(patients_admitted)      AS total_admitted,
    SUM(patients_refused)       AS total_refused,
    ROUND(AVG(patient_satisfaction), 2) AS avg_satisfaction,
    COUNT(DISTINCT week)        AS weeks_reported
  FROM services_weekly
  GROUP BY service
) AS svc
LEFT JOIN
(
  SELECT service, COUNT(*) AS total_staff
  FROM staff
  GROUP BY service
) AS st
  ON st.service = svc.service
LEFT JOIN
(
  SELECT s.service, COUNT(DISTINCT ss.week) AS staff_present_weeks
  FROM staff_schedule ss
  JOIN staff s ON ss.staff_id = s.staff_id
  WHERE ss.present = 1                -- change if present is stored as 'Yes' etc.
  GROUP BY s.service
) AS pres
  ON pres.service = svc.service
ORDER BY svc.total_admitted DESC;

-- Display staff with their service's total patient count as a calculated field.
SELECT
    s.staff_id,
    s.staff_name,
    s.service,
    COALESCE(svc.total_patients, 0) AS total_patients_in_service
FROM staff s
LEFT JOIN (
    SELECT 
        service,
        SUM(patients_admitted) AS total_patients
    FROM services_weekly
    GROUP BY service
) AS svc
    ON svc.service = s.service
ORDER BY total_patients_in_service DESC, s.staff_id;

-- Create a report showing each service with: service name, total patients admitted, the difference between 
-- their total admissions and the average admissions across all services, 
-- and a rank indicator ('Above Average', 'Average', 'Below Average'). Order by total patients admitted descending.
-- MySQL: service totals + difference from overall average + rank (tolerance-based)
SELECT
  s.service,
  s.total_admitted,
  ROUND(s.total_admitted - overall.avg_total, 2) AS diff_from_avg,
  CASE
    WHEN s.total_admitted  > overall.avg_total + 0.5 THEN 'Above Average'
    WHEN ABS(s.total_admitted - overall.avg_total) <= 0.5 THEN 'Average'
    ELSE 'Below Average'
  END AS rank_indicator
FROM (
  SELECT service, SUM(patients_admitted) AS total_admitted
  FROM services_weekly
  GROUP BY service
) AS s
CROSS JOIN (
  SELECT AVG(total_admitted) AS avg_total
  FROM (
    SELECT SUM(patients_admitted) AS total_admitted
    FROM services_weekly
    GROUP BY service
  ) AS t
) AS overall
ORDER BY s.total_admitted DESC;
