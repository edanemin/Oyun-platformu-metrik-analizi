# 🎮 Oyun Platformu Metrik Analizi
### SaaS Revenue & User Analytics | PostgreSQL + Tableau Public

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-E97627?style=for-the-badge&logo=tableau&logoColor=white)

> **İş Sorusu:** Bir oyun platformu Mart–Aralık 2022 döneminde neden büyümeden küçülmeye geçti? Hangi kullanıcı segmenti en değerli?

---

## Live Dashboard & Video Sunum

🔗 **[Tableau Public'te Görüntüle →](https://public.tableau.com/views/FinalProject-2_17727198022740/Dashboard1)**

---

## Repo Yapısı

```
 oyun-platformu-metrik-analizi
 ┣  sql/
 ┃ ┣  01_data_cleaning.sql     
 ┃ ┣  02_data_cleaning_2.sql   
 ┃ ┗  03_metrics.sql            
 ┣  assets/
 ┃ ┗  dashboard.png            
 ┣  data/
 ┃ ┗  dictionary.md             
 ┗  README.md
```

---

## Proje Özeti

| | |
|---|---|
| **Veri** | 3.026 kullanıcı kaydı |
| **Dönem** | Mart 2022 – Aralık 2022 |
| **Kaynak** | `games_payment` + `games_paid_users` |
| **Çıktı** | `games_clean` + `monthly_metrics` |
| **Araçlar** | PostgreSQL, Tableau Public |

---

## Temel Bulgular

### Gelir Trendi

| Metrik | Değer |
|---|---|
| Başlangıç MRR (Nisan 2022) | $1,851 |
| Zirve MRR (Ekim 2022) | $6,809 |
| Toplam Dönem Geliri | ~$43,000 |
| Kasım 2022 Net MRR Değişimi | **−$2,043** ⚠️ |

### Kasım 2022 Kırılma Noktası

Kasım 2022, platformun büyümeden küçülmeye geçtiği kritik aydır:

- **Yeni kullanıcı (27) < Kaybedilen kullanıcı (71)** — ilk kez gerçekleşti
- **Revenue Churn Rate > User Churn Rate** tüm dönem boyunca: kaybedilen kullanıcılar platform ortalamasının *üzerinde* harcama yapıyordu
- Kasım'dan itibaren Churned Revenue baskın gelir bileşeni haline geldi

### En Değerli Segment

| Yaş Grubu | LTV | Ortalama LT | Not |
|---|---|---|---|
| < 18 yaş | ~$199 | ~114 gün | En yüksek LTV |
| 18–25 yaş | ~$197 | ~100 gün | En uzun LT |
| 25+ yaş | Daha düşük | Daha kısa | — |

> **Ek bulgu:** İngilizce dilini tercih eden kullanıcılar da en yüksek LTV ve LT değerlerine sahip segment içinde yer aldı.

---

## Teknik Detaylar

### PostgreSQL — `sql/01_data_cleaning.sql`
Ham verilerin VIEW olarak birleştirilmesi:
- `LEFT JOIN` ile `games_paid_users` + `games_payments` birleştirildi
- `user_id` ve `game_name` üzerinden eşleştirme yapıldı
- `games_pay` adlı VIEW oluşturuldu

### PostgreSQL — `sql/02_data_cleaning_2.sql`
Temizlenmiş tablonun oluşturulması:
- `SELECT DISTINCT *` ile 1 tekrarlayan satır temizlendi (3.026 → 3.025)
- `games_clean` adlı kalıcı tablo oluşturuldu
- `payment_date` sütununa göre sıralandı

### PostgreSQL — `sql/03_metrics.sql`
Tarih dönüşümü ve tüm SaaS metriklerinin hesaplanması:

Kullanılan teknikler: `ALTER TABLE`, `CTE (10 adet)`, `WINDOW FUNCTIONS (LAG, LEAD)`, `COALESCE`, `ROUND`, `INTERVAL`, `NULLIF`

### Tableau Public
- `IF-ELSE` blokları → Dinamik KPI kartları
- `LOOKUP(-1)` → Churn Rate hesabı
- `DATEDIFF` → Customer Lifetime görselleştirme
- `FIXED LOD` → LTV ve LT
- Cross-datasource parametreler + Actions/Filters ile etkileşimli filtreler

---

## İş Önerileri

| # | Öneri | Gerekçe |
|---|---|---|
| 1 | **Churn Yönetimi** | Kasım kırılmasının kök nedeni araştırılmalı; yüksek harcamalı kullanıcılara özel tutundurma programı kurulmalı |
| 2 | **Genç Segment & Dil Odağı** | <18 ve 18–25 yaş + İngilizce kullanıcılar en yüksek LTV/LT; bu gruba özel kampanyalar önceliklendirilmeli |
| 3 | **Expansion MRR Büyütme** | Mevcut kullanıcıdan daha fazla gelir için üst/çapraz satış stratejileri geliştirilmeli |
| 4 | **Erken Uyarı Sistemi** | Revenue Churn > User Churn sinyali izlenmeli; yüksek değerli kullanıcılar için churn risk skorlaması kurulmalı |

---

## 👩‍💻 Yazar

**Eda Nilsun Emin** · Mart 2026  
🔗 [LinkedIn](https://linkedin.com/in/eda-nilsun-emin-51225810b)

---
