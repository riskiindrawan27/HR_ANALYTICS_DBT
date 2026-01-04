with hc as (
  select * from {{ ref('mart_hr__headcount_change') }}
),

final as (
  select
    tanggal,
    previous_cum_change,
    (previous_cum_change + num_resign + bouncing_hires) as retaining,

    case
      when previous_cum_change is null or previous_cum_change = 0 then null
      else (previous_cum_change + num_resign + bouncing_hires) * 1.0 / previous_cum_change
    end as retention_rate,

    dim
  from hc
  where previous_cum_change is not null
)

select * from final
