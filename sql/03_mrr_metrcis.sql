-- ADIM 3: Veri tipi dönüşümü + Tüm SaaS Metrik Hesaplamaları
-- MRR, New MRR, Expansion MRR, Contraction MRR
-- Churned Users/Revenue, Paid Users, ARPPU
-- Teknik: CTE + Window Functions (LAG, LEAD)
-- ============================================================

-- Ödeme tarih kolonu DATE tipine çevirme
ALTER TABLE games_clean
ALTER COLUMN payment_date TYPE DATE
USING payment_date::DATE;

-- MONTHLY METRICS — TEK SORGU
WITH

-- 1. TEMEL: Her kullanıcının aylık ödemesi
user_months AS (
    SELECT
        user_id,
        DATE_TRUNC('month', payment_date)::DATE AS payment_month,
        SUM(revenue_amount_usd)                 AS monthly_revenue
    FROM games_clean
    GROUP BY user_id, DATE_TRUNC('month', payment_date)),

-- 2. Önceki ve sonraki ay bilgisi
user_months_with_lag AS (
    SELECT
        um.user_id,
        um.payment_month,
        um.monthly_revenue,
        LAG(um.payment_month) OVER (
            PARTITION BY um.user_id
            ORDER BY um.payment_month)          AS prev_payment_month,
        LAG(um.monthly_revenue) OVER (
            PARTITION BY um.user_id
            ORDER BY um.payment_month)          AS prev_monthly_revenue,
        LEAD(um.payment_month) OVER (
            PARTITION BY um.user_id
            ORDER BY um.payment_month)          AS next_payment_month
    FROM user_months um),

-- 3. MRR — Önceki ay da ödeme yapan kullanıcılar
mrr AS (
    SELECT
        payment_month,
        SUM(monthly_revenue)                    AS mrr
    FROM user_months_with_lag
    WHERE prev_payment_month = payment_month - INTERVAL '1 month'
    GROUP BY payment_month),

-- 4. PAID USERS — Her ay ödeme yapan unique kullanıcı sayısı
paid_users AS (
    SELECT
        payment_month,
        COUNT(DISTINCT user_id)                 AS paid_users
    FROM user_months
    GROUP BY payment_month

    UNION ALL

    SELECT
        DATE '2023-01-01'                       AS payment_month,
        0                                       AS paid_users),

-- 5. NEW PAID USERS — İlk kez ödeme yapan kullanıcılar
new_paid_users AS (
    SELECT
        payment_month,
        COUNT(DISTINCT user_id)                 AS new_paid_users
    FROM user_months_with_lag
    WHERE prev_payment_month IS NULL
    GROUP BY payment_month),

-- 6. NEW MRR — Yeni kullanıcıların o ayki geliri
new_mrr AS (
    SELECT
        payment_month,
        SUM(monthly_revenue)                    AS new_mrr
    FROM user_months_with_lag
    WHERE prev_payment_month IS NULL
    GROUP BY payment_month),

-- 7. CHURNED USERS — Ay atlayan veya son aydan önce kaybedilen kullanıcılar
churned_users AS (
    SELECT
        (payment_month + INTERVAL '1 month')::DATE AS payment_month,
        COUNT(DISTINCT user_id)                    AS churned_users
    FROM user_months_with_lag
    WHERE next_payment_month > payment_month + INTERVAL '1 month'
       OR (next_payment_month IS NULL
           AND payment_month < (SELECT MAX(payment_month) FROM user_months))
    GROUP BY payment_month),

-- 8. CHURNED REVENUE — Churn olan kullanıcıların o ayki geliri
churned_revenue AS (
    SELECT
        (payment_month + INTERVAL '1 month')::DATE AS payment_month,
        SUM(monthly_revenue)                       AS churned_revenue
    FROM user_months_with_lag
    WHERE next_payment_month > payment_month + INTERVAL '1 month'
       OR (next_payment_month IS NULL
           AND payment_month < (SELECT MAX(payment_month) FROM user_months))
    GROUP BY payment_month),

-- 9. EXPANSION MRR — Bu ay daha fazla ödeyen kullanıcıların fark geliri
expansion_mrr AS (
    SELECT
        payment_month,
        SUM(monthly_revenue - prev_monthly_revenue) AS expansion_mrr
    FROM user_months_with_lag
    WHERE prev_payment_month = payment_month - INTERVAL '1 month'
      AND monthly_revenue > prev_monthly_revenue
    GROUP BY payment_month),

-- 10. CONTRACTION MRR — Bu ay daha az ödeyen kullanıcıların fark geliri
contraction_mrr AS (
    SELECT
        payment_month,
        SUM(monthly_revenue - prev_monthly_revenue) AS contraction_mrr
    FROM user_months_with_lag
    WHERE prev_payment_month = payment_month - INTERVAL '1 month'
      AND monthly_revenue < prev_monthly_revenue
    GROUP BY payment_month)

-- FINAL: Tüm metrikleri tek tabloda birleştir
SELECT
    pu.payment_month,
    COALESCE(m.mrr,               0) AS mrr,
    pu.paid_users,
    COALESCE(
        ROUND(
            COALESCE(m.mrr, 0) /
            NULLIF(pu.paid_users, 0), 2)
    , 0)                             AS arppu,
    COALESCE(np.new_paid_users,   0) AS new_paid_users,
    COALESCE(nm.new_mrr,          0) AS new_mrr,
    COALESCE(cu.churned_users,    0) AS churned_users,
    COALESCE(cr.churned_revenue,  0) AS churned_revenue,
    COALESCE(ex.expansion_mrr,    0) AS expansion_mrr,
    COALESCE(co.contraction_mrr,  0) AS contraction_mrr
FROM paid_users pu
LEFT JOIN mrr              m  ON pu.payment_month = m.payment_month
LEFT JOIN new_paid_users   np ON pu.payment_month = np.payment_month
LEFT JOIN new_mrr          nm ON pu.payment_month = nm.payment_month
LEFT JOIN churned_users    cu ON pu.payment_month = cu.payment_month
LEFT JOIN churned_revenue  cr ON pu.payment_month = cr.payment_month
LEFT JOIN expansion_mrr    ex ON pu.payment_month = ex.payment_month
LEFT JOIN contraction_mrr  co ON pu.payment_month = co.payment_month
ORDER BY pu.payment_month;
