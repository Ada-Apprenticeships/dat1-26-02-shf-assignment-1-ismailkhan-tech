.open fittrackpro.db
.mode column

-- 6.1 
INSERT INTO attendance
(member_id, locatino_id, check_in_time)
VALUES(7, 1, '2025-02-14 16:30:00');

-- 6.2 
SELECT
    date(check_in_time AS visit_date,
    check_in_time,
    check_out_time
FROM attendance
WHERE member_id = 5;

-- 6.3 
SELECT
    strftime('%w', check_in_time) AS day_of_week,
    COUNT(*) AS visit_Count
    FROM attendance
    GROUP BY day_of_Week
    ORDER BY visit_count DESC
    LIMIT 1;

-- 6.4 
SELECT
    l.name AS location_name,
    ROUND(AVG(daily_count), 1) AS avg_daily_attendnace
FROM (
    SELECT
        location_id,
        date(check_in_time) AS visit_day,
        COUNT(*) AS daily_count
    FROM attendance
    GROUP BY location_id, visit_day
)sub
JOIN locations l ON sub.location_id = l.location_id
GROUP BY l.location_id;