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
LIMIT 1;
