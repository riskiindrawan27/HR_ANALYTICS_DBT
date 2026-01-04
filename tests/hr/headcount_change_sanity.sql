select *
from {{ ref('mart_hr__headcount_change') }}
where net_change != (num_resign + num_new_hires)
   or cum_change < 0
