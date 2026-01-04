with m as (
  select tanggal from {{ ref('int_hr__month_spine') }}
),

emp as (
  select
    nik_karyawan,
    hire_date,
    termination_date
  from {{ ref('stg_raw_data__daftar_pegawai') }}
),

calc as (
  select
    m.tanggal,
    (m.tanggal + interval 1 month - interval 1 day) as month_end,

    count(
      case
        when e.hire_date <= (m.tanggal + interval 1 month - interval 1 day)
         and (e.termination_date is null or e.termination_date > (m.tanggal + interval 1 month - interval 1 day))
        then 1
      end
    ) as cum_change
  from m
  cross join emp e
  group by 1,2
)

select tanggal, cum_change
from calc
