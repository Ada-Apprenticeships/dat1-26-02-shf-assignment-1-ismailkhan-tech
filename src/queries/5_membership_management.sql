.open fittrackpro.db
.mode column

-- 5.1 
SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    ms.membership_type AS membership_type,
    m.join_date
FROM memberships ms
JOIN members m ON ms.member_id = m.member_id
WHERE ms.status = 'Active';

-- 5.2 
SELECT
    ms.membership_type AS membership_type,
    ROUND(AVG(
        (julianday(check_out_time) - julianday(check_in_time)) * 24 * 60),1)
        AS avg_visit_duration_minutes -- made new line to make it more visible, instead of one long line
    FROM attendance a 
    JOIN memberships ms ON a.member_id = ms.member_id 
    WHERE a.check_out_time IS NOT NULL -- only completed visits
    GROUP BY ms.membership_type;
   
-- 5.3 
SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    m.email,
    ms.end_Date
FROM memberships ms
JOIN members m ON ms.member_id = m.member_id
WHERE strftime('%Y', ms.end_date) = '2025'; -- this gets the year to match all dates in 2025
