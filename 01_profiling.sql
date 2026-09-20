-- FinTrust Week 1: data profiling (standard SQL; PostgreSQL syntax for dates)
CREATE VIEW txn AS
SELECT *, TO_TIMESTAMP(transaction_datetime,'MM/DD/YYYY HH24:MI') AS txn_ts
FROM transactions;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM transactions;

-- missing values
SELECT COUNT(*)-COUNT(device_type) AS null_device,
       COUNT(*)-COUNT(location)    AS null_location
FROM transactions;

-- duplicate keys (expect 0 rows)
SELECT customer_id FROM customers GROUP BY 1 HAVING COUNT(*) > 1;
SELECT transaction_id FROM transactions GROUP BY 1 HAVING COUNT(*) > 1;

-- orphan check (expect 0)
SELECT COUNT(*) FROM transactions t
LEFT JOIN customers c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- channel vs device consistency
SELECT channel, device_type, COUNT(*) FROM transactions GROUP BY 1,2 ORDER BY 1,3 DESC;

-- transaction location vs customer home city
SELECT ROUND(100.0*SUM(CASE WHEN t.location=c.city THEN 1 ELSE 0 END)/COUNT(*),1) AS pct_same_city
FROM transactions t JOIN customers c USING (customer_id);

-- date range and amount distribution
SELECT MIN(txn_ts), MAX(txn_ts) FROM txn;
SELECT MIN(amount_ngn), MAX(amount_ngn), AVG(amount_ngn),
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount_ngn) AS median
FROM transactions;
