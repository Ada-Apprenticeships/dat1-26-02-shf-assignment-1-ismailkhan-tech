.open fittrackpro.db
.mode box

-- 3.1 
--Find equipment due for maintenance in the next 30 days
--BETWEEN includes start date and end date (covers the 30 day window)
SELECT
    equipment_id,
    name,
    next_maintenance_date
FROM equipment
WHERE next_maintenance_date
BETWEEN '2025-01-01' AND date('2025-01-01', '+30 days') -- adds 30 days to the start date
ORDER BY next_maintenance_date;

--3.2
SELECT
type AS equipment_type,
COUNT(*) AS count
FROM equipment
GROUP BY type; --Creates one row per equipment type

-- 3.3 
SELECT
type AS equipment_type,
ROUND(AVG(julianday('now') - julianday(purchase_date)), 1) AS avg_age_days --julianday() required as it converts dates to continous day numbers for artihemetic operations ( SQLITE does not let me directly subtract the dates)
FROM equipment
GROUP BY type
ORDER BY type;

