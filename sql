
SELECT w.warehouse_id
FROM warehouse w
JOIN inventory i ON w.warehouse_id = i.warehouse_id
JOIN order_items oi ON oi.vehicle_id = i.vehicle_id
WHERE w.dc_id = :specifiedDcId AND oi.order_id = :orderId
GROUP BY w.warehouse_id
HAVING COUNT(oi.vehicle_id) = (
    SELECT COUNT(DISTINCT oi_inner.vehicle_id)
    FROM order_items oi_inner
    WHERE oi_inner.order_id = :orderId
)
AND MIN(COUNT(i.vin) >= SUM(oi.quantity)) = 1; give sample output 










SELECT w.warehouse_id
            FROM warehouse w
            JOIN inventory i ON w.warehouse_id = i.warehouse_id
            JOIN order_items oi ON oi.vehicle_id = i.vehicle_id
            WHERE w.dc_id = :specifiedDcId
              AND oi.order_id = :orderId
            GROUP BY w.warehouse_id
            HAVING COUNT(DISTINCT oi.vehicle_id) = (
                SELECT COUNT(DISTINCT oi_inner.vehicle_id)
                FROM order_items oi_inner
                WHERE oi_inner.order_id = :orderId
            )
              AND SUM(CASE WHEN i.vin IS NOT NULL THEN 1 ELSE 0 END) >= SUM(oi.quantity)
            LIMIT 1


------------

SELECT w.warehouse_id
FROM warehouse w
JOIN inventory i ON w.warehouse_id = i.warehouse_id
JOIN order_items oi ON oi.vehicle_id = i.vehicle_id
WHERE w.dc_id = :specifiedDcId
  AND oi.order_id = :orderId
GROUP BY w.warehouse_id
HAVING COUNT(DISTINCT i.vehicle_id) = COUNT(DISTINCT oi.vehicle_id)
   AND SUM(i.quantity) >= (
       SELECT SUM(oi_inner.quantity)
       FROM order_items oi_inner
       WHERE oi_inner.order_id = :orderId
   )
ORDER BY w.warehouse_id ASC

            ----------------------


WITH RequiredVehicles AS (
    SELECT oi.vehicle_id, SUM(oi.quantity) AS total_required
    FROM order_items oi
    WHERE oi.order_id = :orderId
    GROUP BY oi.vehicle_id
),
WarehouseInventory AS (
    SELECT w.warehouse_id, i.vehicle_id, SUM(i.quantity) AS total_available
    FROM warehouse w
    JOIN inventory i ON w.warehouse_id = i.warehouse_id
    WHERE w.dc_id = :specifiedDcId
    GROUP BY w.warehouse_id, i.vehicle_id
),
MatchingWarehouses AS (
    SELECT wi.warehouse_id
    FROM WarehouseInventory wi
    JOIN RequiredVehicles rv ON wi.vehicle_id = rv.vehicle_id
    GROUP BY wi.warehouse_id
    HAVING COUNT(wi.vehicle_id) = (SELECT COUNT(*) FROM RequiredVehicles)
       AND SUM(wi.total_available) >= SUM(rv.total_required)
)
SELECT warehouse_id
FROM MatchingWarehouses
ORDER BY warehouse_id ASC
LIMIT 1;

LIMIT 1;
