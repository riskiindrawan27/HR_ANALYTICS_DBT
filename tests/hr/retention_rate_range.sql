select *
from {{ ref('mart_hr__retention_rate') }}
where retention_rate is not null
  and (retention_rate < 0 or retention_rate > 1)
