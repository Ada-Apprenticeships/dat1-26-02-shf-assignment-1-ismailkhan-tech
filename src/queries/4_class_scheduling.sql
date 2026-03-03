.open fittrackpro.db
.mode column

-- 4.1 
SELECT DISTINCT --removes duplicates 
    c.class_id,
    c.name AS class_name,
    s.first_name || ' ' || s.last_name  AS instructor_name -- || concatenates strings
FROM classes c
JOIN class_schedule cs ON c.class_id = cs.class_id
JOIN staff s ON cs.staff_id = s.staff_id
ORDER BY c.class_id;

-- 4.2 
SELECT
    c.class_id,
    c.name,
    cs.start_time,
    cs.end_time,
    (c.capacity - COUNT(ca.class_attendance_id)) AS available_spots
FROM classes c 
JOIN class_schedule cs ON c.class_id = cs.class_id
LEFT JOIN class_attendance ca --LEFT join used so classes show even if nobody registed yet (shows full capacity)
    ON cs.schedule_id = ca.schedule_id
WHERE date(cs.start_time) = '2025-02-01' --
GROUP BY cs.schedule_id; --Used GROUP BY to count registration per individual session


-- 4.3 
INSERT INTO class_attendance
(schedule_id, member_id, attendance_status)
VALUES(1, 11, 'Registered');


-- 4.4 
DELETE FROM class_attendance --DELETE used instead of UPDATE becausr we want to completely remove the registration
WHERE schedule_id = 7
AND member_id = 3;

-- 4.5 
SELECT
    c.class_id,
    c.name AS class_name,
    COUNT(ca.class_attendance_id) AS registration_count
FROM classes C
JOIN class_schedule cs ON c.class_id = cs.class_id
JOIN class_attendance ca ON cs.schedule_id = ca.schedule_id
WHERE ca.attendance_status = 'Registered' --This filters to 'Registered' to count current registrations only
GROUP BY c.class_id
ORDER BY registration_count DESC
LIMIT 1;


-- 4.6 
SELECT
    ROUND(AVG(class_count), 1) AS avg_classes_per_member -- Subquery needed to first count classes per member, then collate an average of those counts
FROM (
    SELECT
    member_id,
    COUNT(*) AS class_count
    FROM class_attendance
    WHERE attendance_status IN ('Registered', 'Attended') -- Makes sure to include both 'Registered' and 'Attended' to see active participation
    GROUP BY member_id
);
