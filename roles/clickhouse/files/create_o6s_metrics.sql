CREATE TABLE IF NOT EXISTS o6s.metrics (
    timestamp DateTime64(3),
    client_name LowCardinality(String),
    server_name LowCardinality(String),
    target_name LowCardinality(String),
    metric_name LowCardinality(String),
    label_name  LowCardinality(String),
    is_cumulative UInt8,              -- 0 for Snap, 1 for Counter
    retention_days UInt16 DEFAULT 14, -- Default 2 weeks for raw data
    metrics Map(String, Float64),     -- Numbers only
    metadata JSON                     -- Strings, Dates, Booleans
)
ENGINE = MergeTree()
ORDER BY (client_name, server_name, target_name, metric_name, label_name, timestamp)
TTL timestamp + INTERVAL retention_days DAY WHERE retention_days > 0;
