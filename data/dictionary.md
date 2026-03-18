# Veri Sözlüğü

Bu dosya projede kullanılan tabloların sütun açıklamalarını içerir.

---

## games_paid_users

Ham kullanıcı verisi.

| Sütun | Tip | Açıklama |
|---|---|---|
| `user_id` | INTEGER | Kullanıcı benzersiz kimlik numarası |
| `game_name` | VARCHAR | Kullanıcının oynadığı oyun adı |
| `language` | VARCHAR | Kullanıcının platform dil tercihi |
| `has_older_device_model` | BOOLEAN | Eski cihaz modeli kullanıp kullanmadığı |
| `age` | INTEGER | Kullanıcının yaşı |

---

## games_payments

Ham ödeme verisi.

| Sütun | Tip | Açıklama |
|---|---|---|
| `user_id` | INTEGER | Kullanıcı benzersiz kimlik numarası (FK) |
| `game_name` | VARCHAR | Ödemenin yapıldığı oyun adı (FK) |
| `payment_date` | DATE | Ödeme tarihi |
| `revenue_amount_usd` | NUMERIC | Ödeme tutarı (USD) |

---

## games_clean

`games_paid_users` ve `games_payments` tablolarının birleştirilmiş ve temizlenmiş hali.

| Sütun | Tip | Açıklama |
|---|---|---|
| `user_id` | INTEGER | Kullanıcı benzersiz kimlik numarası |
| `game_name` | VARCHAR | Oyun adı |
| `language` | VARCHAR | Dil tercihi |
| `has_older_device_model` | BOOLEAN | Eski cihaz kullanımı |
| `age` | INTEGER | Kullanıcı yaşı |
| `payment_date` | DATE | Ödeme tarihi |
| `revenue_amount_usd` | NUMERIC | Ödeme tutarı (USD) |

> Ham verideki 1 tekrarlayan satır kaldırılmıştır. (3.026 → 3.025 satır)

---

## monthly_metrics

Her aya ait SaaS metriklerinin hesaplanmış hali.

| Sütun | Tip | Açıklama |
|---|---|---|
| `payment_month` | DATE | İlgili ay (ayın ilk günü) |
| `mrr` | NUMERIC | Monthly Recurring Revenue — önceki ay da ödeme yapan kullanıcıların toplam geliri |
| `paid_users` | INTEGER | O ay ödeme yapan benzersiz kullanıcı sayısı |
| `arppu` | NUMERIC | Average Revenue Per Paying User — MRR / Paid Users |
| `new_paid_users` | INTEGER | O ay ilk kez ödeme yapan kullanıcı sayısı |
| `new_mrr` | NUMERIC | Yeni kullanıcıların o ayki toplam geliri |
| `churned_users` | INTEGER | Bir önceki ay ödeme yapıp bu ay yapmayan kullanıcı sayısı |
| `churned_revenue` | NUMERIC | Churn olan kullanıcıların bir önceki aydaki toplam geliri |
| `expansion_mrr` | NUMERIC | Mevcut kullanıcılardan önceki aya göre artan gelir farkı |
| `contraction_mrr` | NUMERIC | Mevcut kullanıcılardan önceki aya göre azalan gelir farkı |

---

## Metrik Tanımları

| Metrik | Formül |
|---|---|
| **Churn Rate** | Churned Users / Önceki Ay Paid Users |
| **Revenue Churn Rate** | Churned Revenue / Önceki Ay MRR |
| **Customer LT** | MAX(payment_date) - MIN(payment_date) — gün cinsinden |
| **Customer LTV** | Kullanıcı başına toplam revenue_amount_usd |
