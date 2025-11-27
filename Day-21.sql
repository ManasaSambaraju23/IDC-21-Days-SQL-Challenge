USE HOSPITALS;
-- Create a CTE to calculate service statistics, then query from it.
WITH svc_stats AS (
  SELECT
    service,
    SUM(patients_admitted)      AS total_admitted,
    SUM(patients_refused)       AS total_refused,
    ROUND(AVG(patient_satisfaction), 2) AS avg_satisfaction,
    COUNT(DISTINCT week)        AS weeks_reported
  FROM services_weekly
  GROUP BY service
),
staff_meta AS (
  SELECT
    service,
    COUNT(*) AS total_staff
  FROM staff
  GROUP BY service
),
staff_presence AS (
  SELECT
    s.service,
    COUNT(DISTINCT ss.week) AS weeks_with_staff_present
  FROM staff_schedule ss
  JOIN staff s ON ss.staff_id = s.staff_id
  WHERE ss.present = 1                 
  GROUP BY s.service
)
SELECT
  ss.service,
  COALESCE(sv.total_admitted, 0)      AS total_admitted,
  COALESCE(sv.total_refused, 0)       AS total_refused,
  COALESCE(sv.avg_satisfaction, 0)    AS avg_satisfaction,
  COALESCE(sv.weeks_reported, 0)      AS weeks_reported,
  COALESCE(sm.total_staff, 0)         AS total_staff,
  COALESCE(sp.weeks_with_staff_present, 0) AS weeks_with_staff_present
FROM (
  SELECT service FROM services_weekly
  UNION
  SELECT service FROM staff
) ss(service)
LEFT JOIN svc_stats sv ON sv.service = ss.service
LEFT JOIN staff_meta sm ON sm.service = ss.service
LEFT JOIN staff_presence sp ON sp.service = ss.service
ORDER BY total_admitted DESC;

-- Use multiple CTEs to break down a complex query into logical steps.

WITH
normalized_schedule AS (
  SELECT
    ss.staff_id,
    s.service,
    ss.week,
    CASE
      WHEN ss.present = 1 THEN 1
      WHEN ss.present = '1' THEN 1
      WHEN LOWER(TRIM(ss.present)) IN ('yes','y','true','t') THEN 1
      ELSE 0
    END AS is_present
  FROM staff_schedule ss
  JOIN staff s ON ss.staff_id = s.staff_id
),
svc_week AS (
  SELECT
    service,
    week,
    SUM(patients_admitted) AS patients_admitted,
    SUM(patients_refused)  AS patients_refused,
    AVG(patient_satisfaction) AS avg_patient_satisfaction
  FROM services_weekly
  GROUP BY service, week
),
svc_stats AS (
  SELECT
    service,
    SUM(patients_admitted) AS total_admitted,
    SUM(patients_refused)  AS total_refused,
    ROUND(AVG(avg_patient_satisfaction), 2) AS overall_avg_satisfaction,
    COUNT(DISTINCT week) AS weeks_reported
  FROM svc_week
  GROUP BY service
),
staff_counts AS (
  SELECT
    service,
    COUNT(DISTINCT staff_id) AS total_staff
  FROM staff
  GROUP BY service
),
staff_presence AS (
  SELECT
    service,
    COUNT(DISTINCT week) AS weeks_with_staff_present
  FROM normalized_schedule
  WHERE is_present = 1
  GROUP BY service
),
service_combined AS (
  SELECT
    ss.service,
    ss.total_admitted,
    ss.total_refused,
    ss.overall_avg_satisfaction,
    ss.weeks_reported,
    COALESCE(scnt.total_staff, 0) AS total_staff,
    COALESCE(sp.weeks_with_staff_present, 0) AS weeks_with_staff_present
  FROM svc_stats ss
  LEFT JOIN staff_counts scnt ON scnt.service = ss.service
  LEFT JOIN staff_presence sp ON sp.service = ss.service
)
SELECT
  service,
  total_admitted,
  total_refused,
  overall_avg_satisfaction,
  weeks_reported,
  total_staff,
  weeks_with_staff_present,
  ROUND(
    CASE WHEN weeks_reported = 0 THEN NULL
         ELSE (weeks_with_staff_present / weeks_reported) * 100 END,
    2
  ) AS pct_staff_presence
FROM service_combined
ORDER BY total_admitted DESC;

-- Build a CTE for staff utilization and join it with patient data.
WITH
staff_week AS (
  SELECT
    s.staff_id,
    s.service,
    COUNT(DISTINCT ss.week) AS weeks_present
  FROM staff s
  LEFT JOIN staff_schedule ss
    ON s.staff_id = ss.staff_id
    AND (
         ss.present = 1
         OR ss.present = '1'
         OR LOWER(TRIM(COALESCE(ss.present, ''))) IN ('yes','y','true','t')
    )
  GROUP BY s.staff_id, s.service
),
staff_util_service AS (
  SELECT
    sw.service,
    COUNT(*) AS total_staff,                             
    COALESCE(SUM(sw.weeks_present), 0) AS total_staff_weeks_present,
    COALESCE(ROUND(AVG(sw.weeks_present), 2), 0) AS avg_weeks_present_per_staff
  FROM staff_week sw
  GROUP BY sw.service
),
service_presence_weeks AS (
  SELECT
    s.service,
    COUNT(DISTINCT ss.week) AS weeks_with_staff_present
  FROM staff_schedule ss
  JOIN staff s ON ss.staff_id = s.staff_id
  WHERE (
         ss.present = 1
         OR ss.present = '1'
         OR LOWER(TRIM(COALESCE(ss.present, ''))) IN ('yes','y','true','t')
  )
  GROUP BY s.service
),
service_reported_weeks AS (
  SELECT
    service,
    COUNT(DISTINCT week) AS weeks_reported
  FROM services_weekly
  GROUP BY service
)
SELECT
  p.patient_id,
  p.name                              AS patient_name,
  p.service                           AS patient_service,
  p.arrival_date,
  COALESCE(sus.total_staff, 0)        AS total_staff_assigned,
  COALESCE(sus.avg_weeks_present_per_staff, 0) AS avg_weeks_present_per_staff,
  COALESCE(sus.total_staff_weeks_present, 0)   AS total_staff_weeks_present,
  COALESCE(spw.weeks_with_staff_present, 0)    AS weeks_with_staff_present,
  COALESCE(sr.weeks_reported, 0)      AS weeks_reported,
  CASE WHEN COALESCE(sr.weeks_reported, 0) = 0 THEN NULL
       ELSE ROUND(COALESCE(spw.weeks_with_staff_present, 0) / sr.weeks_reported * 100, 2)
  END AS pct_weeks_with_staff_present
FROM patients p
LEFT JOIN staff_util_service sus
  ON sus.service = p.service
LEFT JOIN service_presence_weeks spw
  ON spw.service = p.service
LEFT JOIN service_reported_weeks sr
  ON sr.service = p.service
ORDER BY p.patient_id;

-- Create a comprehensive hospital performance dashboard using CTEs. Calculate: 1) Service-level metrics (total admissions,
-- refusals, avg satisfaction), 2) Staff metrics per service (total staff, avg weeks present), 
-- 3) Patient demographics per service (avg age, count). Then combine all three CTEs to create a final report 
-- showing service name, all calculated metrics, and an overall performance score (weighted average of admission rate and satisfaction). 
--  Order by performance score descending.

WITH
svc_stats AS (
  SELECT
    service,
    COALESCE(SUM(patients_admitted), 0) AS total_admitted,
    COALESCE(SUM(patients_refused), 0)  AS total_refused,
    ROUND(AVG(patient_satisfaction), 2) AS avg_satisfaction,
    COUNT(DISTINCT week) AS weeks_reported
  FROM services_weekly
  GROUP BY service
),
staff_week AS (
  SELECT
    s.staff_id,
    s.service,
    COUNT(DISTINCT ss.week) AS weeks_present
  FROM staff s
  LEFT JOIN staff_schedule ss
    ON s.staff_id = ss.staff_id
    AND (
         ss.present = 1
         OR ss.present = '1'
         OR LOWER(TRIM(COALESCE(ss.present, ''))) IN ('yes','y','true','t')
    )
  GROUP BY s.staff_id, s.service
),
staff_metrics AS (
  SELECT
    sw.service,
    COUNT(DISTINCT sw.staff_id) AS total_staff,
    COALESCE(ROUND(AVG(sw.weeks_present), 2), 0) AS avg_weeks_present_per_staff,
    COALESCE(SUM(sw.weeks_present), 0) AS total_staff_weeks_present
  FROM staff_week sw
  GROUP BY sw.service
),
patient_demo AS (
  SELECT
    p.service,
    COUNT(*) AS patient_count,
    ROUND(AVG(p.age), 2) AS avg_age
  FROM patients p
  GROUP BY p.service
)
SELECT
  s.service,
  s.total_admitted,
  s.total_refused,
  s.avg_satisfaction,
  CASE
    WHEN (s.total_admitted + s.total_refused) = 0 THEN 0
    ELSE ROUND( s.total_admitted * 100.0 / (s.total_admitted + s.total_refused), 2 )
  END AS admission_rate_pct,
  COALESCE(sm.total_staff, 0)                 AS total_staff,
  COALESCE(sm.avg_weeks_present_per_staff, 0) AS avg_weeks_present_per_staff,
  COALESCE(pd.patient_count, 0)               AS patient_count,
  COALESCE(pd.avg_age, NULL)                  AS avg_patient_age,
  ROUND(
    (
      (CASE WHEN (s.total_admitted + s.total_refused) = 0 THEN 0
            ELSE s.total_admitted * 100.0 / (s.total_admitted + s.total_refused) END) * 0.4
    )
    +
    (COALESCE(s.avg_satisfaction, 0) * 0.6)
  , 2) AS overall_performance_score
FROM svc_stats s
LEFT JOIN staff_metrics sm ON sm.service = s.service
LEFT JOIN patient_demo pd    ON pd.service = s.service
ORDER BY overall_performance_score DESC, s.total_admitted DESC;

