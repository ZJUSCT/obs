SELECT toStartOfInterval(
    Timestamp,
    toIntervalMillisecond($__interval_ms * 6)
  ) as timestamp,
  replaceRegexpOne(
    LogAttributes ['url.path'],
    '^/([^/]+)/.*',
    '\\1'
  ) AS repo,
  COUNT(*)
FROM default.otel_logs
WHERE (
    Timestamp >= $__fromTime
    AND Timestamp <= $__toTime
  )
  AND (
    ResourceAttributes ['cloud.region'] = 'zjusct-falcon'
  )
  AND (ResourceAttributes ['host.name'] = 'zjumirror')
  AND (ResourceAttributes ['service.name'] = 'nginx')
  AND (LogAttributes ['log.file.name'] = 'otel.log')
  AND (
    match(LogAttributes ['url.path'], '^/([^/]+)/.*')
  )
GROUP BY ALL,
ORDER BY COUNT(*) DESC
LIMIT 5 BY COUNT(*);