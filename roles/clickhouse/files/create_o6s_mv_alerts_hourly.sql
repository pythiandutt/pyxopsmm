CREATE MATERIALIZED VIEW IF NOT EXISTS o6s.mv_alerts_hourly
TO o6s.alerts_hourly
AS SELECT
    toStartOfHour(insert_at) as hour,
    client_name,
    server_name,
    target_name,
    check_name,
    countState(*) as incident_count,
    sumState(total_hours) as total_hours
FROM o6s.alerts
GROUP BY client_name, server_name, target_name, check_name, hour;