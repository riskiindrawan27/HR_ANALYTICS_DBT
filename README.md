# HR Analytics - Technical Test
## Posisi: Data Analytics Engineer

Proyek ini merupakan implementasi sistem analitik HR menggunakan `dbt-core` untuk mengembangkan metrik perubahan jumlah pegawai (headcount) dan tingkat retensi pegawai.

---

## 📋 Deskripsi Proyek

Repo ini berisi data model HR Analytics yang dibangun dengan pendekatan modular menggunakan **dbt (data build tool)** dan **DuckDB** sebagai database engine. Proyek ini mengimplementasikan dua metrik utama:

1. **Headcount Change** - Perubahan jumlah pegawai dari bulan ke bulan
2. **Retention Rate** - Tingkat retensi pegawai bulanan

---

## 🏗️ Arsitektur Data Model

Proyek ini mengikuti best practice data modeling dengan tiga tahapan transformasi:

### 1. **Staging Layer** (`models/staging/`)
Membersihkan dan menstandarisasi data mentah dari sumber data.

- `stg_raw_data__daftar_pegawai`: Membersihkan data pegawai dari CSV mentah

### 2. **Intermediate Layer** (`models/intermediate/`)
Menerapkan logika bisnis dan transformasi data.

- `int_hr__month_spine`: Membuat spine tanggal bulanan untuk analisis time-series
- `int_hr__monthly_events`: Agregasi event hiring dan terminasi per bulan
- `int_hr__monthly_headcount`: Kalkulasi kumulatif perubahan headcount

### 3. **Mart Layer** (`models/mart/`)
Model final yang siap digunakan untuk analisis dan pelaporan.

- `mart_hr__headcount_change`: Metrik komprehensif perubahan headcount
- `mart_hr__retention_rate`: Metrik tingkat retensi pegawai

---

## 📊 Metrik dan Spesifikasi

### 1. Metrik `headcount_change`

**Deskripsi:** Menghitung perubahan jumlah pegawai dari bulan ke bulan.

**Kolom yang dihasilkan:**
- `tanggal`: Periode bulan dalam format tanggal ISO 8601, selalu ditulis sebagai awal bulan (YYYY-MM-01)
- `num_resign`: Jumlah pegawai yang resign, ditulis sebagai bilangan negatif
- `num_new_hires`: Jumlah pegawai baru, ditulis sebagai bilangan positif
- `cum_change`: Jumlah total pegawai pada bulan tersebut setelah menghitung resign dan hire
- `net_change`: Hasil kalkulasi dari `num_resign` + `num_new_hires`
- `bouncing_hires`: Jumlah pegawai yang resign pada bulan yang sama saat direkrut
- `previous_cum_change`: Nilai `cum_change` pada bulan sebelumnya
- `dim`: Kategorisasi periode waktu (Monthly)

**Contoh Output:**
```
TANGGAL      NUM_RESIGN  NUM_NEW_HIRES  CUM_CHANGE  NET_CHANGE  BOUNCING_HIRES  PREVIOUS_CUM_CHANGE
2006-09-01   0           3              39          3           0               36
2018-05-01   0           5              114         5           0               109
```

### 2. Metrik `retention_rate`

**Deskripsi:** Menghitung tingkat retensi pegawai bulanan.

**Kolom yang dihasilkan:**
- `tanggal`: Periode bulan dalam format tanggal ISO 8601, selalu ditulis sebagai awal bulan (YYYY-MM-01)
- `previous_cum_change`: Nilai `cum_change` pada bulan sebelumnya (dari metrik `headcount_change`)
- `retaining`: Hasil kalkulasi jumlah pegawai yang bertahan (previous_cum_change + num_resign + bouncing_hires)
- `retention_rate`: Persentase retensi (retaining / previous_cum_change)
- `dim`: Kategorisasi periode waktu (Monthly)

**Contoh Output:**
```
TANGGAL      PREVIOUS_CUM_CHANGE  RETAINING  RETENTION_RATE  DIM
2006-06-01   35                   35         1.000000        Monthly
2025-10-01   247                  244        0.987854        Monthly
2025-05-01   236                  234        0.991525        Monthly
```

---

## 📁 Struktur Proyek

```
hr_analytics/
├── models/
│   ├── staging/
│   │   └── hr/
│   │       ├── staging_hr.yml
│   │       └── stg_raw_data__daftar_pegawai.sql
│   ├── intermediate/
│   │   └── hr/
│   │       ├── int_hr__month_spine.sql
│   │       ├── int_hr__monthly_events.sql
│   │       └── int_hr__monthly_headcount.sql
│   └── mart/
│       └── hr/
│           ├── mart_hr.yml
│           ├── mart_hr__headcount_change.sql
│           └── mart_hr__retention_rate.sql
├── seeds/
│   └── raw_data/
│       ├── daftar_pegawai.csv
│       └── seeds.yml
├── tests/
│   └── hr/
│       ├── headcount_change_sanity.sql
│       └── retention_rate_range.sql
├── dbt_project.yml
├── packages.yml
└── README.md
```

---

## 🚀 Cara Menjalankan Proyek

### Prasyarat

- Python 3.8+
- dbt-core
- dbt-duckdb adapter

### Instalasi

1. **Clone repository:**
```bash
git clone <url-repo-anda>
cd hr_analytics_dbt/hr_analytics
```

2. **Install dbt dan dependencies:**
```bash
pip install dbt-core dbt-duckdb
```

3. **Install dbt packages:**
```bash
dbt deps
```

4. **Konfigurasi `profiles.yml`:**

Buat atau edit file `profiles.yml` di direktori `~/.dbt/` (Windows: `C:\Users\<username>\.dbt\profiles.yml`) dengan konfigurasi berikut:

```yaml
hr_analytics:
  outputs:
    dev:
      type: duckdb
      path: ./ae_test_case.duckdb
      threads: 4

  target: dev
```

**Penjelasan konfigurasi:**
- `hr_analytics`: Nama profile yang harus sesuai dengan `profile` di `dbt_project.yml`
- `type: duckdb`: Menggunakan DuckDB sebagai database engine
- `path`: Lokasi file database DuckDB (relatif terhadap direktori proyek)
- `threads`: Jumlah thread untuk eksekusi paralel
- `target: dev`: Environment default yang akan digunakan

### Menjalankan Pipeline

1. **Load data seed:**
```bash
dbt seed
```

2. **Jalankan semua models:**
```bash
dbt run
```

3. **Jalankan tests:**
```bash
dbt test
```

4. **Generate dan lihat dokumentasi:**
```bash
dbt docs generate
dbt docs serve
```

---

## 📝 Sumber Data

Data yang digunakan berasal dari file `daftar_pegawai.csv` yang berisi informasi pegawai dengan struktur:

| Kolom              | Deskripsi                                              |
|--------------------|--------------------------------------------------------|
| `NIK_KARYAWAN`     | ID unik pegawai                                        |
| `PERUSAHAAN`       | Nama perusahaan/divisi                                 |
| `HIRE_DATE`        | Tanggal pegawai bergabung                              |
| `TERMINATION_DATE` | Tanggal pegawai resign (null untuk pegawai aktif)      |
| `STATUS`           | Status kepegawaian                                     |

---

## 🧪 Quality Assurance

Proyek ini dilengkapi dengan data quality tests untuk memastikan integritas data:

- **headcount_change_sanity**: Validasi logika kalkulasi headcount
- **retention_rate_range**: Memastikan retention rate berada dalam range yang valid (0-1)

---

## 🔧 Konfigurasi

Konfigurasi materialization di `dbt_project.yml`:
- **Staging models**: Materialized sebagai `view`
- **Intermediate models**: Materialized sebagai `view`
- **Mart models**: Materialized sebagai `table` untuk performa query optimal

---

## 📦 Dependencies

- [dbt_utils](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/): Macro dan utilities umum untuk proyek dbt


---

## 📚 Referensi

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [DuckDB Documentation](https://duckdb.org/docs/)

---

## 👨‍💻 Pengembang

Proyek ini dikembangkan sebagai bagian dari Technical Test untuk posisi Data Analytics Engineer.

**Tech Stack:**
- dbt-core
- DuckDB
- SQL
- Python
