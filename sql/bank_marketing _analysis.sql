/*
Project: Bank Marketing Campaign Analysis
Database: PostgreSQL
Dataset: UCI Bank Marketing Dataset

Objective:
Analyze customer characteristics and campaign performance to identify
the factors associated with term-deposit subscriptions.

Main techniques:
- Aggregate functions
- CASE expressions
- Common table expressions
- Window functions
- Ranking
*/

--1. Overall term-deposite subscription rate

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE subscribed = 'yes'
    ) AS total_subscribers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE subscribed = 'yes'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS subscription_rate_percent
FROM bank_clean;

--2. Conversion rate by age group

SELECT
    CASE
        WHEN age < 30 THEN '18-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(
        CASE
            WHEN subscribed = 'yes' THEN 1
            ELSE 0
        END
    ) AS total_subscribers,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS subscription_rate_percent
FROM bank_clean
GROUP BY
    CASE
        WHEN age < 30 THEN '18-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        ELSE '60+'
    END
ORDER BY subscription_rate_percent DESC;

--3. Conversion rate by job

SELECT
    job,
    COUNT(*) AS total_customers,
    SUM(
        CASE
            WHEN subscribed = 'yes' THEN 1
            ELSE 0
        END
    ) AS total_subscribers,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS subscription_rate_percent
FROM bank_clean
GROUP BY job
ORDER BY subscription_rate_percent DESC;

--4. Average account balance by age group

SELECT
    CASE
        WHEN age < 30 THEN '18-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_customers,
    ROUND(AVG(balance), 2) AS average_balance
FROM bank_clean
GROUP BY
    CASE
        WHEN age < 30 THEN '18-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        ELSE '60+'
    END
ORDER BY average_balance DESC;

-- 5. Housing loan versus subscription

SELECT
    housing_loan,
    COUNT(*) AS total_customers,
    SUM(
        CASE
            WHEN subscribed = 'yes' THEN 1
            ELSE 0
        END
    ) AS total_subscribers,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS subscription_rate_percent
FROM bank_clean
GROUP BY housing_loan
ORDER BY subscription_rate_percent DESC;

-- 6. Personal loan versus subscription

SELECT
    personal_loan,
    COUNT(*) AS total_customers,
    SUM(
        CASE
            WHEN subscribed = 'yes' THEN 1
            ELSE 0
        END
    ) AS total_subscribers,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS subscription_rate_percent
FROM bank_clean
GROUP BY personal_loan
ORDER BY subscription_rate_percent DESC;

-- 7. Subscription performance by contact month

WITH monthly_performance AS (
    SELECT
        contact_month,
        CASE contact_month
            WHEN 'jan' THEN 1
            WHEN 'feb' THEN 2
            WHEN 'mar' THEN 3
            WHEN 'apr' THEN 4
            WHEN 'may' THEN 5
            WHEN 'jun' THEN 6
            WHEN 'jul' THEN 7
            WHEN 'aug' THEN 8
            WHEN 'sep' THEN 9
            WHEN 'oct' THEN 10
            WHEN 'nov' THEN 11
            WHEN 'dec' THEN 12
        END AS month_number,
        COUNT(*) AS total_contacts,
        COUNT(*) FILTER (
            WHERE subscribed = 'yes'
        ) AS total_subscribers
    FROM bank_clean
    GROUP BY contact_month
)

SELECT
    contact_month,
    total_contacts,
    total_subscribers,
    ROUND(
        100.0 * total_subscribers / NULLIF(total_contacts, 0),
        2
    ) AS subscription_rate_percent
FROM monthly_performance
ORDER BY month_number;

-- 8. Contact frequency versus conversion

WITH contact_frequency_groups AS (
    SELECT
        CASE
            WHEN campaign_contacts = 1 THEN '1 contact'
            WHEN campaign_contacts BETWEEN 2 AND 3 THEN '2-3 contacts'
            WHEN campaign_contacts BETWEEN 4 AND 6 THEN '4-6 contacts'
            ELSE '7+ contacts'
        END AS contact_frequency,
        subscribed
    FROM bank_clean
)

SELECT
    contact_frequency,
    COUNT(*) AS total_customers,
    SUM(
        CASE
            WHEN subscribed = 'yes' THEN 1
            ELSE 0
        END
    ) AS total_subscribers,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS subscription_rate_percent
FROM contact_frequency_groups
GROUP BY contact_frequency
ORDER BY subscription_rate_percent DESC;

-- 9. Previous campaign outcome analysis

SELECT
    previous_outcome,
    COUNT(*) AS total_customers,
    ROUND(AVG(previous_contacts), 2) AS average_previous_contacts,
    SUM(
        CASE
            WHEN subscribed = 'yes' THEN 1
            ELSE 0
        END
    ) AS total_subscribers,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS subscription_rate_percent
FROM bank_clean
GROUP BY previous_outcome
ORDER BY subscription_rate_percent DESC;

-- 10. Rank jobs by conversion rate

WITH job_performance AS (
    SELECT
        job,
        COUNT(*) AS total_customers,
        COUNT(*) FILTER (
            WHERE subscribed = 'yes'
        ) AS total_subscribers,
        100.0 * COUNT(*) FILTER (
            WHERE subscribed = 'yes'
        ) / NULLIF(COUNT(*), 0) AS subscription_rate
    FROM bank_clean
    WHERE job <> 'unknown'
    GROUP BY job
    HAVING COUNT(*) >= 100
)

SELECT
    job,
    total_customers,
    total_subscribers,
    ROUND(subscription_rate, 2) AS subscription_rate_percent,
    RANK() OVER (
        ORDER BY subscription_rate DESC
    ) AS performance_rank
FROM job_performance
ORDER BY performance_rank;

-- 11. Top 10% of customers by account balance

WITH customer_balance_ranking AS (
    SELECT
        age,
        job,
        marital,
        education,
        balance,
        subscribed,
        NTILE(10) OVER (
            ORDER BY balance DESC
        ) AS balance_decile
    FROM bank_clean
)

SELECT
    age,
    job,
    marital,
    education,
    balance,
    subscribed
FROM customer_balance_ranking
WHERE balance_decile = 1
ORDER BY balance DESC;

-- 12. Compare each job with the overall conversion rate

WITH overall_performance AS (
    SELECT
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS overall_subscription_rate
    FROM bank_clean
),

job_performance AS (
    SELECT
        job,
        COUNT(*) AS total_customers,
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS job_subscription_rate
    FROM bank_clean
    GROUP BY job
)

SELECT
    job_performance.job,
    job_performance.total_customers,
    ROUND(job_performance.job_subscription_rate, 2)
        AS job_subscription_rate_percent,
    ROUND(overall_performance.overall_subscription_rate, 2)
        AS overall_subscription_rate_percent,
    ROUND(
        job_performance.job_subscription_rate
        - overall_performance.overall_subscription_rate,
        2
    ) AS percentage_point_difference
FROM job_performance
CROSS JOIN overall_performance
ORDER BY percentage_point_difference DESC;

-- 13. Analyze customer segments by job and education

SELECT
    job,
    education,
    COUNT(*) AS total_customers,
    ROUND(AVG(balance), 2) AS average_balance,
    SUM(
        CASE
            WHEN subscribed = 'yes' THEN 1
            ELSE 0
        END
    ) AS total_subscribers,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS subscription_rate_percent
FROM bank_clean
GROUP BY job, education
HAVING COUNT(*) >= 100
ORDER BY
    subscription_rate_percent DESC,
    average_balance DESC;

-- 14. Create an age-group performance view

CREATE OR REPLACE VIEW vw_age_group_performance AS

SELECT
    CASE
        WHEN age BETWEEN 18 AND 29 THEN '18-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
		WHEN age >= 60 THEN '60+'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(
        CASE
            WHEN subscribed = 'yes' THEN 1
            ELSE 0
        END
    ) AS total_subscribers,
    ROUND(AVG(balance), 2) AS average_balance,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN subscribed = 'yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS subscription_rate_percent
FROM bank_clean
GROUP BY
    CASE
        WHEN age BETWEEN 18 AND 29 THEN '18-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
		WHEN age >= 60 THEN '60+'
        ELSE 'Unknown'
    END;

--Test
SELECT *
FROM vw_age_group_performance
ORDER BY subscription_rate_percent DESC;

-- 15. Create a Power BI dashboard-ready view

CREATE OR REPLACE VIEW vw_campaign_dashboard AS

SELECT
    age,

    CASE
        WHEN age BETWEEN 18 AND 29 THEN '18-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
		WHEN age >= 60 THEN '60+'
        ELSE 'Unknown'
    END AS age_group,

    job,
    marital,
    education,
    credit_default,
    balance,

    CASE
        WHEN balance < 0 THEN 'Negative balance'
        WHEN balance < 1000 THEN '0-999'
        WHEN balance < 5000 THEN '1,000-4,999'
        WHEN balance < 10000 THEN '5,000-9,999'
        ELSE '10,000+'
    END AS balance_group,

    housing_loan,
    personal_loan,
    contact_type,
    contact_day,
    contact_month,
    call_duration,
    campaign_contacts,
    days_since_previous,
    previous_contacts,
    previous_outcome,
    subscribed,

    CASE
        WHEN subscribed = 'yes' THEN 1
        ELSE 0
    END AS subscribed_flag

FROM bank_clean;

--Test
SELECT *
FROM vw_campaign_dashboard
LIMIT 10;

--Row count
SELECT COUNT(*) AS total_rows
FROM vw_campaign_dashboard;