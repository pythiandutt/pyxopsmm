CREATE TABLE IF NOT EXISTS o6s.metrics_hourly (
    timestamp DateTime,
    client_name LowCardinality(String),
    server_name LowCardinality(String),
    target_name LowCardinality(String),
    metric_name LowCardinality(String),
    label_name  LowCardinality(String),
    retention_days UInt16 DEFAULT 365,
    -- Aggregate States
    avg_metrics AggregateFunction(avgMap, Map(String, Float64)),
    max_metrics AggregateFunction(maxMap, Map(String, Float64)),
    min_metrics AggregateFunction(minMap, Map(String, Float64)),
    -- Keeps the most recent metadata string/JSON for the hour
    latest_metadata AggregateFunction(argMax, JSON, DateTime64(3)),
    updated_at DateTime64 DEFAULT now64(3)
) 
ENGINE = ReplacingMergeTree(updated_at)
PARTITION BY toYYYYMM(timestamp)
ORDER BY (client_name, server_name, target_name, metric_name, label_name, timestamp)
TTL timestamp + INTERVAL retention_days DAY;