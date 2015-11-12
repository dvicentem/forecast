SELECT item_quantities1.ItemCategory1,
       item_quantities1.ItemId,
       item_quantities1.item_quantity / avg_sales_by_item.avg_sale_by_item
       item_success
FROM   (SELECT itemcategory1,
               AVG(item_quantity) avg_sale_by_item
        FROM   (SELECT itemcategory1,
                       ItemId,
                       Sum(storedemandquantity) item_quantity
                FROM   dailysales
                       JOIN items
                         ON item_id = items.id
                GROUP  BY 1,
                          2) item_quantities
        GROUP  BY 1) avg_sales_by_item
       JOIN (SELECT itemcategory1,
                    ItemId,
                    Sum(storedemandquantity) item_quantity
             FROM   dailysales
                    JOIN items
                      ON item_id = items.id
             GROUP  BY 1,
                       2) item_quantities1
         ON item_quantities1.itemcategory1 = avg_sales_by_item.itemcategory1;
