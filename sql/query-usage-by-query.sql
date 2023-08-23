WITH
warehouse_sizes AS (
    SELECT 'X-Small' AS warehouse_size, 1 AS credits_per_hour UNION ALL
    SELECT 'Small' AS warehouse_size, 2 AS credits_per_hour UNION ALL
    SELECT 'Medium'  AS warehouse_size, 4 AS credits_per_hour UNION ALL
    SELECT 'Large' AS warehouse_size, 8 AS credits_per_hour UNION ALL
    SELECT 'X-Large' AS warehouse_size, 16 AS credits_per_hour UNION ALL
    SELECT '2X-Large' AS warehouse_size, 32 AS credits_per_hour UNION ALL
    SELECT '3X-Large' AS warehouse_size, 64 AS credits_per_hour UNION ALL
    SELECT '4X-Large' AS warehouse_size, 128 AS credits_per_hour
),
queries AS (
    SELECT
        qh.query_id,
        qh.query_text,
        qh.execution_time/(1000*60*60)*wh.credits_per_hour AS query_cost
    FROM snowflake.account_usage.query_history AS qh
    INNER JOIN warehouse_sizes AS wh
        ON qh.warehouse_size=wh.warehouse_size
    WHERE
        start_time >= CURRENT_DATE - 30
)
SELECT
    query_text,
    SUM(query_cost) AS total_query_cost_last_30d
FROM queries
GROUP BY query_text
ORDER BY total_query_cost_last_30d DESC
