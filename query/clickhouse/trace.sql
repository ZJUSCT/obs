-- variables
SELECT ResourceAttributes ['cloud.region'] AS cloud_region
FROM otel_traces
WHERE (
    Timestamp >= $__fromTime
    AND Timestamp <= $__toTime
  )
  AND (NOT empty(cloud_region))
GROUP BY cloud_region;
SELECT ResourceAttributes ['host.name'] AS host_name
FROM otel_traces
WHERE (
    Timestamp >= $__fromTime
    AND Timestamp <= $__toTime
  )
  AND (NOT empty(host_name))
  AND (
    '$cloud_region' = 'ALL'
    OR ResourceAttributes ['cloud.region'] = '$cloud_region'
  )
GROUP BY host_name;
SELECT ResourceAttributes ['service.name'] AS service_name
FROM otel_logs
WHERE (
    Timestamp >= $__fromTime
    AND Timestamp <= $__toTime
  )
  AND (NOT empty(service_name))
  AND (
    '$cloud_region' = 'ALL'
    OR ResourceAttributes ['cloud.region'] = '$cloud_region'
  )
  AND (
    '$host_name' = 'ALL'
    OR ResourceAttributes ['host.name'] = '$host_name'
  )
GROUP BY service_name;
SELECT TraceId
FROM "default"."otel_traces"
WHERE (
    Timestamp >= $__fromTime
    AND Timestamp <= $__toTime
  )
  AND (ParentSpanId = '')
  AND (ServiceName = '$service_name')
ORDER BY Timestamp DESC,
  Duration DESC
LIMIT 10;