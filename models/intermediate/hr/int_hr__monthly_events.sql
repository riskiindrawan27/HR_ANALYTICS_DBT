with emp as (
    select
      nik_karyawan,
      date_trunc('month', hire_date) as hire_month,
      case when termination_date is not null
        then date_trunc('month', termination_date)
        else null
      end as term_month
    from {{ ref('stg_raw_data__daftar_pegawai') }}
),

events as (
    select
      m.tanggal,
      -count(case when e.term_month = m.tanggal then 1 end) as num_resign,

      count(case when e.hire_month = m.tanggal then 1 end) as num_new_hires,

      count(
        case
          when e.hire_month = m.tanggal and e.term_month = m.tanggal
          then 1
        end
      ) as bouncing_hires,

      'Monthly' as dim
    from {{ ref('int_hr__month_spine') }} m
    left join emp e
      on e.hire_month = m.tanggal
      or e.term_month = m.tanggal
    group by 1
)

select * from events
