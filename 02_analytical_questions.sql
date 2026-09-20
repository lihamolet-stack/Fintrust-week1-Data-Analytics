-- Q1 value by segment (repeat with c.city and c.monthly_income_band)
SELECT c.customer_segment, COUNT(*) txns, SUM(t.amount_ngn) value, AVG(t.amount_ngn) avg_amt
FROM transactions t JOIN customers c USING (customer_id) GROUP BY 1 ORDER BY 3 DESC;

-- Q2 transaction type and channel
SELECT transaction_type, COUNT(*), SUM(amount_ngn), AVG(amount_ngn) FROM transactions GROUP BY 1 ORDER BY 3 DESC;
SELECT channel, COUNT(*), SUM(amount_ngn), AVG(amount_ngn) FROM transactions GROUP BY 1 ORDER BY 3 DESC;

-- Q3 monthly trend
SELECT DATE_TRUNC('month', txn_ts) m, COUNT(*), SUM(amount_ngn) FROM txn GROUP BY 1 ORDER BY 1;

-- Q4 status rates by channel
SELECT channel, COUNT(*) txns,
  ROUND(100.0*SUM(CASE WHEN transaction_status='Failed'   THEN 1 ELSE 0 END)/COUNT(*),1) failed,
  ROUND(100.0*SUM(CASE WHEN transaction_status='Reversed' THEN 1 ELSE 0 END)/COUNT(*),1) reversed,
  ROUND(100.0*SUM(CASE WHEN transaction_status='Pending'  THEN 1 ELSE 0 END)/COUNT(*),1) pending
FROM transactions GROUP BY 1 ORDER BY failed DESC;

-- Q5 engagement vs activity
WITH p AS (
  SELECT c.customer_id,
    CASE WHEN digital_engagement_score<50 THEN 'Low' WHEN digital_engagement_score<75 THEN 'Medium' ELSE 'High' END band,
    COUNT(*) n, SUM(t.amount_ngn) v
  FROM customers c JOIN transactions t USING (customer_id) GROUP BY 1,2)
SELECT band, COUNT(*), AVG(n), AVG(v) FROM p GROUP BY 1;

-- Q6 risk review flag rate (repeat for channel, transaction_status, international_transaction)
SELECT transaction_type, COUNT(*) txns,
  ROUND(100.0*SUM(CASE WHEN risk_review_flag='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) flag_pct
FROM transactions GROUP BY 1 ORDER BY 3 DESC;

SELECT CASE WHEN amount_ngn<10000 THEN '1 Under 10k' WHEN amount_ngn<50000 THEN '2 10k-50k'
            WHEN amount_ngn<200000 THEN '3 50k-200k' ELSE '4 200k+' END band,
  COUNT(*) txns,
  ROUND(100.0*SUM(CASE WHEN risk_review_flag='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) flag_pct
FROM transactions GROUP BY 1 ORDER BY 1;

-- Q7 dormant / restricted accounts still transacting
SELECT c.account_status, COUNT(DISTINCT c.customer_id) customers, COUNT(*) txns, SUM(t.amount_ngn) value
FROM transactions t JOIN customers c USING (customer_id) GROUP BY 1;
