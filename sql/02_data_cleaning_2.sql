-- ADIM 2: Veri temizleme
-- Tekrarlayan satırların kaldırılması → games_clean tablosu
-- 3.026 satır → 3.025 satır (1 duplicate kaldırıldı)
-- ============================================================

CREATE TABLE games_clean AS (
    SELECT DISTINCT *
    FROM games_pay
)
ORDER BY payment_date;
