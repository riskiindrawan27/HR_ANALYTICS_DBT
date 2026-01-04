with events as (
  select * from {{ ref('int_hr__monthly_events') }}
),
hc as (
  select * from {{ ref('int_hr__monthly_headcount') }}
),

final as (
  select
    e.tanggal,
    e.num_resign,
    e.num_new_hires,
    hc.cum_change,
    (e.num_resign + e.num_new_hires) as net_change,
    e.bouncing_hires,
    lag(hc.cum_change) over (order by e.tanggal) as previous_cum_change,
    e.dim
  from events e
  join hc
    on e.tanggal = hc.tanggal
)

select * from final
