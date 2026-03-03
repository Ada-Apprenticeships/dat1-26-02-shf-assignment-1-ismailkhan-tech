.open fittrackpro.db
.mode column

-- 6.1 
INSERT INTO attendance
(member_id, location_id, check_in_time)
VALUES(7, 1, '2025-02-14 16:30:00');

-- 6.2 
SELECT
    date(check_in_time) AS visit_date, -- date() creates separate visit_date column by just taking the date
    check_in_time,
    check_out_time
FROM attendance
WHERE member_id = 5;
ORDER BY check_in_time DESC; -- better readablity

-- 6.3 
SELECT
    strftime('%w', check_in_time) AS day_of_week, -- Did this to get the day of week as number (0=Sunday - Saturday = 6 )
    COUNT(*) AS visit_count
    FROM attendance
    GROUP BY day_of_week
    ORDER BY visit_count DESC
    LIMIT 1;

-- 6.4 
SELECT
    l.name AS location_name,
    ROUND(AVG(daily_count), 1) AS avg_daily_attendance --Calculates average daily attendance for each location
FROM (
    SELECT  --Calculation for how many visits per day at each location
        location_id,
        date(check_in_time) AS visit_day,
        COUNT(*) AS daily_count
    FROM attendance
    GROUP BY location_id, visit_day --Need to group both location and day to get daily counts per location
)sub
JOIN locations l ON sub.location_id = l.location_id
GROUP BY l.location_id;
--So the subquery first calculates how many visits per day at each location
--Then outer query averages those daily counts