INSERT IGNORE
INTO   dailysales
       (
              item_id,
              store_id,
              calendar_id,
              storedemandquantity
       )
SELECT t1. item_id,
       t1.store_id,
       t1.calendar_id,
       0 storedemandquantity
FROM   (
                SELECT   item_id,
                         store_id,
                         min(calendar_id) min_date,
                         max(calendar_id) max_date
                FROM     dailysales
                GROUP BY 1,
                         2) tlimites
JOIN
       (
              SELECT calendar.id calendar_id,
                     items.id    item_id,
                     stores.id   store_id
              FROM   calendar,
                     items,
                     stores) t1
ON     t1.item_id = tlimites.item_id
AND    t1.`store_id` = tlimites.store_id
AND    t1.calendar_id >= tlimites.min_date
AND    t1.calendar_id <= tlimites.max_date;
       
