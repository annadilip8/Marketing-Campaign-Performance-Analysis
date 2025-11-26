
-- Campaign KPI Calculation SQL
WITH cs AS (
    SELECT
        campaign_id,
        COUNT(*) AS impressions,
        COUNT(DISTINCT customer_id) AS reached_users,
        SUM(opened) AS opens,
        SUM(clicked) AS clicks,
        SUM(converted) AS conversions
    FROM campaign_interactions
    GROUP BY campaign_id
),
rev AS (
    SELECT
        campaign_id,
        SUM(amount) AS revenue
    FROM transactions
    GROUP BY campaign_id
)

SELECT
    cs.campaign_id,
    c.channel,
    c.offer_type,
    cs.reached_users,
    cs.impressions,
    cs.opens,
    cs.clicks,
    cs.conversions,
    (CAST(cs.clicks AS FLOAT) / NULLIF(cs.opens, 0)) AS ctr,
    (CAST(cs.conversions AS FLOAT) / NULLIF(cs.reached_users, 0)) AS conversion_rate,
    (CAST(c.campaign_cost AS FLOAT) / NULLIF(cs.conversions, 0)) AS cac,
    ((IFNULL(rev.revenue, 0) - c.campaign_cost) * 1.0 / c.campaign_cost) AS roi
FROM cs
JOIN campaigns c ON cs.campaign_id = c.campaign_id
LEFT JOIN rev ON cs.campaign_id = rev.campaign_id
ORDER BY roi DESC;
