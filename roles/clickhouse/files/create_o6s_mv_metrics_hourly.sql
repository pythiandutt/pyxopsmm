CREATE MATERIALIZED VIEW IF NOT EXISTS o6s.mv_metrics_hourly
TO o6s.metrics_hourly AS
SELECT
    toStartOfHour(timestamp) AS timestamp,
    client_name,
    server_name,
    target_name,
    metric_name,
    label_name,
    is_cumulative,
    -- We'll set a longer default for the summary table
    365 AS retention_days,
    avgMapState(metrics) AS avg_metrics,
    maxMapState(metrics) AS max_metrics,
    minMapState(metrics) AS min_metrics,
    argMaxState(metadata, o6s.metrics.timestamp) AS latest_metadata
FROM o6s.metrics
GROUP BY client_name, server_name, target_name, metric_name, is_cumulative, label_name, timestamp;
