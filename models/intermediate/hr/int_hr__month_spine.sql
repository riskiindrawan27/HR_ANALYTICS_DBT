with bounds as (
    select
      date_trunc('month', min(hire_date)) as min_month,
      date_trunc(
        'month',
        greatest(
          max(hire_date),
          max(coalesce(termination_date, hire_date))
        )
      ) as max_month
    from {{ ref('stg_raw_data__daftar_pegawai') }}
),

spine as (
    select
      gs as tanggal
    from bounds,
    generate_series(min_month, max_month, interval 1 month) as t(gs)
)

select tanggal from spine

