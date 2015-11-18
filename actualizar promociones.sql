UPDATE dailysales
       JOIN promotions_scope
         ON dailysales.item_id = promotions_scope.item_id
            AND dailysales.store_id = promotions_scope.store_id
            AND dailysales.calendar_id >= promotions_scope.promotion_start
            AND dailysales.calendar_id <= promotions_scope.promotion_end
SET    dailysales.promotion_id = promotions_scope.promotion_id;