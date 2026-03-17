CREATE TABLE IF NOT EXISTS o6s.alerts (
    -- Identification
    -- Use UUID for a 'true' unique ref, or UInt64 if you want to increment manually
    alert_id UUID DEFAULT generateUUIDv4(),  
    -- Timestamps (Converted from Epoch)
    -- ClickHouse handles DateTime best for time-series analysis
    insert_at DateTime DEFAULT toDateTime(epoch_insert_sec),
    run_at DateTime DEFAULT toDateTime(epoch_run_sec),
    epoch_insert_sec UInt64,
    epoch_run_sec UInt64,
    -- Extracted Labels (High performance filtering)
    client_name LowCardinality(String),
    server_name LowCardinality(String),
    target_name LowCardinality(String),
    check_name  LowCardinality(String),
    -- Other Data
    return_value Int32,
    am_request_id String,
    ticket_status String,
    total_hours Float64 DEFAULT 0,
    -- Collections and Blobs
    tags Array(String),
    payload String, -- Keep as raw JSON string
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(insert_at)
ORDER BY (client_name, server_name, target_name, check_name, insert_at)
TTL insert_at + INTERVAL 1 YEAR;