
-- Offer Type & Channel Performance SQL
WITH campaign_kpis AS (
    SELECT
        cs.campaign_id,
        c.channel,
        c.offer_type,
        (CAST(cs.clicks AS FLOAT) / NULLIF(cs.opens, 0)) AS ctr,
        (CAST(cs.conversions AS FLOAT) / NULLIF(cs.reached_users, 0)) AS conversion_rate,
        (CAST(c.campaign_cost AS FLOAT) / NULLIF(cs.conversions, 0)) AS cac,
        ((IFNULL(t.revenue, 0) - c.campaign_cost) * 1.0 / c.campaign_cost) AS roi
    FROM (
        SELECT
            campaign_id,
            COUNT(*) AS impressions,
            COUNT(DISTINCT customer_id) AS reached_users,
            SUM(opened) AS opens,
            SUM(clicked) AS clicks,
            SUM(converted) AS conversions
        FROM campaign_interactions
        GROUP BY campaign_id
    ) cs
    JOIN campaigns c ON cs.campaign_id = c.campaign_id
    LEFT JOIN (
        SELECT campaign_id, SUM(amount) AS revenue
        FROM transactions
        GROUP BY campaign_id
    ) t ON cs.campaign_id = t.campaign_id
)

SELECT
    channel,
    offer_type,
    COUNT(*) AS campaigns_count,
    AVG(ctr) AS avg_ctr,
    AVG(conversion_rate) AS avg_conversion_rate,
    AVG(cac) AS avg_cac,
    AVG(roi) AS avg_roi
FROM campaign_kpis
GROUP BY channel, offer_type
ORDER BY avg_roi DESC;
