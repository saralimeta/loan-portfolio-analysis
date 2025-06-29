-- Retrieve all active loans due between Jan–Mar 2023
SELECT
    LOAN_UUID AS loan_id,
    CURRENT_PRINCIPAL_OUTSTANDING AS amount_to_be_repaid,
    TO_CHAR(LOAN_END_DATE, 'YYYY-MM-DD') AS due_date
FROM
    loan_data
WHERE
    LOAN_END_DATE BETWEEN '2023-01-01' AND '2023-03-31'
    AND CURRENT_PRINCIPAL_OUTSTANDING > 0;

-- Calculate loan tenor statistics for March 2023 originations
SELECT
    AVG(original_loan_end_date - contract_date) AS mean_tenor_days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY original_loan_end_date - contract_date) AS median_tenor_days
FROM
    loan_data
WHERE
    contract_date >= '2023-03-01'
    AND contract_date < '2023-04-01';

-- Count of customers with outstanding loan balances
SELECT COUNT(DISTINCT CLIENT_UUID) AS customers_with_remaining_balance
FROM loan_data
WHERE CURRENT_PRINCIPAL_OUTSTANDING > 0;

-- Monthly trend of loan originations and customer acquisition
SELECT
  TO_CHAR(CONTRACT_DATE, 'YYYY-MM') AS month,
  COUNT(DISTINCT CLIENT_UUID) AS distinct_customers,
  SUM(INITIAL_LOAN_AMOUNT) AS total_amount_originated
FROM loan_data
GROUP BY month
ORDER BY month;

-- Monthly default rate by customer segment
SELECT
    TO_CHAR(CONTRACT_DATE, 'YYYY-MM') AS loan_month,
    SEGMENT,
    SUM(CASE WHEN DAYS_PAST_DUE > 90 THEN CURRENT_PRINCIPAL_OUTSTANDING ELSE 0 END) AS defaulted_outstanding,
    SUM(INITIAL_LOAN_AMOUNT) AS total_initial_loan,
    ROUND(
        SUM(CASE WHEN DAYS_PAST_DUE > 90 THEN CURRENT_PRINCIPAL_OUTSTANDING ELSE 0 END) /
        NULLIF(SUM(INITIAL_LOAN_AMOUNT), 0), 4
    ) AS default_rate
FROM loan_data
GROUP BY loan_month, SEGMENT
ORDER BY loan_month, SEGMENT;

-- Total outstanding balance that is not in default (DAYS_PAST_DUE < 90)
SELECT
    SUM(CURRENT_PRINCIPAL_OUTSTANDING) AS total_outstanding
FROM loan_data
WHERE DAYS_PAST_DUE < 90;

-- Weekly breakdown of business types originating loans

SELECT
  TO_CHAR(DATE_TRUNC('month', contract_date), 'YYYY-MM') AS month,
  TO_CHAR(DATE_TRUNC('week', contract_date), 'YYYY-MM-DD') AS week_start,
  COUNT(CASE WHEN company_type = 'single' THEN 1 END) AS number_of_sole_prop,
  COUNT(CASE WHEN company_type = 'corporation' THEN 1 END) AS number_of_corporations
FROM loan_data
GROUP BY month, week_start
ORDER BY month, week_start;

-- Cohort analysis – repayment performance of cohorts by month

WITH first_loans AS (
  SELECT
    client_uuid,
    MIN(DATE_TRUNC('month', contract_date)) AS cohort_month
  FROM loan_data
  GROUP BY client_uuid
),
cohort_loans AS (
  SELECT
    fl.cohort_month,
    l.client_uuid,
    SUM(l.initial_loan_amount) AS total_initial_loan,
    SUM(l.current_principal_outstanding) AS total_outstanding,
    (SUM(l.current_principal_outstanding) / NULLIF(SUM(l.initial_loan_amount), 0)) AS client_outstanding_pct
  FROM loan_data l
  JOIN first_loans fl ON l.client_uuid = fl.client_uuid
  WHERE DATE_TRUNC('month', l.contract_date) = fl.cohort_month
  GROUP BY fl.cohort_month, l.client_uuid
)
SELECT
  TO_CHAR(cohort_month, 'YYYY-MM') AS cohort_month,
  ROUND(AVG(client_outstanding_pct)::NUMERIC, 4) AS avg_outstanding_pct,
  ROUND(SUM(total_outstanding) / NULLIF(SUM(total_initial_loan), 0), 4) AS agg_outstanding_pct,
  COUNT(DISTINCT client_uuid) AS distinct_customers
FROM cohort_loans
GROUP BY cohort_month
ORDER BY cohort_month;

-- Origination trend split by new vs repeat customers

WITH first_loans AS (
  SELECT
    client_uuid,
    MIN(contract_date) AS first_loan_date
  FROM loan_data
  GROUP BY client_uuid
),
tagged_loans AS (
  SELECT
    l.*,
    CASE 
      WHEN l.contract_date = f.first_loan_date THEN 'New'
      ELSE 'Repeat'
    END AS customer_type
  FROM loan_data l
  JOIN first_loans f ON l.client_uuid = f.client_uuid
),
monthly_originations AS (
  SELECT
    TO_CHAR(DATE_TRUNC('month', contract_date), 'YYYY-MM') AS month,
    customer_type,
    SUM(initial_loan_amount) AS origination
  FROM tagged_loans
  GROUP BY 1, 2
)

SELECT
  month,
  COALESCE(SUM(CASE WHEN customer_type = 'New' THEN origination END), 0) AS new_origination,
  COALESCE(SUM(CASE WHEN customer_type = 'Repeat' THEN origination END), 0) AS repeat_origination
FROM monthly_originations
GROUP BY month
ORDER BY month;

-- Risk Analysis: Identify industries with highest default rates

SELECT
    industry,
    SUM(CASE WHEN days_past_due > 90 THEN current_principal_outstanding ELSE 0 END) AS defaulted_outstanding,
    SUM(initial_loan_amount) AS total_initial_loan,
    ROUND(
        SUM(CASE WHEN days_past_due > 90 THEN current_principal_outstanding ELSE 0 END) /
        NULLIF(SUM(initial_loan_amount), 0), 4
    ) AS default_rate
FROM loan_data
GROUP BY industry
ORDER BY default_rate DESC;










