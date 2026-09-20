-- KPI baseline (Q1 2026)
SELECT COUNT(*) total_txns, SUM(amount_ngn) total_value,
  ROUND(100.0*SUM(CASE WHEN transaction_status='Successful' THEN 1 ELSE 0 END)/COUNT(*),1) success_rate,
  ROUND(100.0*SUM(CASE WHEN transaction_status IN ('Failed','Reversed') THEN 1 ELSE 0 END)/COUNT(*),1) fail_rev_rate,
  ROUND(100.0*SUM(CASE WHEN risk_review_flag='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) risk_rate,
  ROUND(100.0*SUM(CASE WHEN channel IN ('Mobile App','Web','USSD') THEN 1 ELSE 0 END)/COUNT(*),1) digital_share,
  ROUND(100.0*SUM(CASE WHEN international_transaction='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) intl_share,
  ROUND(1.0*COUNT(*)/COUNT(DISTINCT customer_id),1) txns_per_customer
FROM transactions;
