CREATE TABLE IF NOT EXISTS o6s.alerts_daily (
    day Date,
    client_name LowCardinality(String),
    server_name LowCardinality(String),
    target_name LowCardinality(String),
    check_name LowCardinality(String),
    incident_count AggregateFunction(count, UInt64),
    total_hours AggregateFunction(sum, Float64)
)
ENGINE = AggregatingMergeTree()
ORDER BY (client_name, server_name, target_name, check_name, day);