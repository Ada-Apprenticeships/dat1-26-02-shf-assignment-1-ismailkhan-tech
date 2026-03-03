.open fittrackpro.db
.mode box

-- 2.1 
--date time (now) is used to capture a timestamp
INSERT INTO payments
(member_id, amount, payment_date, payment_method, payment_type)
VALUES 
(11, 50.00, datetime('now'), 'Credit Card', 'Monthly membership fee');


-- 2.2 
SELECT
    strftime('%Y-%m', payment_date) AS month,--extracts year-month format for grouping 
    SUM(amount) AS total_revenue--SUM adds up all payment amounts per month
FROM payments
WHERE payment_type = 'Monthly membership fee'
AND payment_date BETWEEN '2024-11-01' AND '2025-02-28 23:59:59'
GROUP BY strftime('%Y-%m', payment_date)-- GROUP BY creates separate totals for each month
ORDER BY month;

-- 2.3 
--filters to return all payments where payment_type = 'Day pass'
SELECT
    payment_id,
    amount,
    payment_date,
    payment_method
FROM payments
WHERE payment_type = 'Day pass';

