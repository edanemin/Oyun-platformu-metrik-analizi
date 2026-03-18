-- ADIM 1: Ham verilerin birleştirilmesi
-- games_paid_users + games_payments → games_pay view
-- ============================================================

CREATE VIEW games_pay AS (
    SELECT
        u.user_id,
        u.game_name,
        u.language,
        u.has_older_device_model,
        u.age,
        p.payment_date,
        p.revenue_amount_usd
    FROM project.games_paid_users u
    LEFT JOIN project.games_payments p
        ON u.user_id = p.user_id
        AND u.game_name = p.game_name
);
