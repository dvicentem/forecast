SELECT ItemCategory1,
       StoreId,
       AVG(quantity) category_average_week_sales
FROM   (SELECT item_id,
               ItemCategory1,
               StoreId,
               YEAR,
               calendar.week,
               Sum(StoreDemandQuantity) quantity
        FROM   calendar
               JOIN dailysales
                 ON dailysales.calendar_id = calendar.id
               JOIN items
                 ON dailysales.item_id = items.id
                 JOIN stores ON stores.id=dailysales.store_id
        GROUP  BY 1,
                  2,
                  3,
                  4,
                  5) t1
GROUP  BY 1,
          2