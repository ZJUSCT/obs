select query,
        query_duration_ms
from system.query_log
where query_kind = 'Select'
order by query_start_time desc
limit 10;