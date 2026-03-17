CREATE MATERIALIZED VIEW IF NOT EXISTS o6s.mv_alerts_daily
TO o6s.alerts_daily
AS SELECT
    toDate(insert_at) AS day,
    client_name,
    server_name,
    target_name,
    check_name,
    countState(*) AS incident_count,
    sumState(total_hours) AS total_hours
FROM o6s.alerts
GROUP BY client_name, server_name, target_name, check_name, day;