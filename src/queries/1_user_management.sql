.open fittrackpro.db
.mode box

-- 1.1
SELECT 
    member_id,
    first_name,
    last_name,
    email,
    join_date
FROM members;


-- 1.2
--Used WHERE to ensure only one row is affected
UPDATE members
SET
    phone_number = '07000 100005',
    email= 'emily.jones.updated@email.com'
WHERE member_id = 5;


-- 1.3
SELECT COUNT(*) AS total_members
FROM members;


-- 1.4
-- INNER JOIN used so only members with registrations are included
--GROUP BY required so COUNT works on each individual member
SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    COUNT(ca.class_attendance_id) AS registration_count
FROM members m
JOIN class_attendance ca 
ON m.member_id = ca.member_id
GROUP BY m.member_id
ORDER BY registration_count DESC
LIMIT 1;

-- 1.5
--LEFT JOIN used to incude member with 0 registrations
--If theres no match in class_attendance, COUNT will return 0
SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    COUNT(ca.class_attendance_id) AS registration_count
FROM members m
LEFT JOIN class_attendance ca 
    ON m.member_id = ca.member_id
GROUP BY m.member_id
ORDER BY registration_count ASC
LIMIT 1;


-- 1.6
--Subquery is used to identify members with atleast 2 attended classes
--HAVING is used as the filtering is done after GROUP BY
SELECT COUNT(*) AS total_count
FROM(
    SELECT member_id
    FROM class_attendance
    WHERE attendance_status = 'Attended'
    GROUP BY member_id
    HAVING COUNT(*) >= 2
);



