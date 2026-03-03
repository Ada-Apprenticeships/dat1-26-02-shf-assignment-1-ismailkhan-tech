.open fittrackpro.db
.mode box

-- 7.1 
SELECT
    staff_id,
    first_name,
    last_name,
    position AS role
FROM staff
ORDER BY position; --Did this to group similar roles together, so its easier to read on the output

-- 7.2  
SELECT
    s.staff_id AS trainer_id,
    s.first_name || ' ' || s.last_name AS trainer_name, -- This Concatenates first and last names
    COUNT(pts.session_id) AS session_count
FROM staff s   
JOIN personal_training_sessions pts
    ON s.staff_id = pts.staff_id
WHERE s.position = 'Trainer' -- Only filters to this as the other positioins dont do personal training
AND pts.session_date
BETWEEN '2025-01-20' AND date('2025-01-20', '+30 days')
GROUP BY s.staff_id;

