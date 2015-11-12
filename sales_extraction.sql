SELECT `dailysales`.`StoreDemandQuantity`,
       `promotions`.`id` promotion_id,
       `promotions`.`desc`,
       `calendar`.`full_date`,
       `calendar`.`week`,
       `calendar`.`month`,
       `calendar`.`year`,
       `stores`.`StoreId`,
       `items`.`ItemId`,
       `items`.`ItemCategory1`
FROM   `dailysales`
       JOIN `promotions`
         ON `dailysales`.`promotion_id` = `promotions`.`id`
       JOIN `calendar`
         ON `dailysales`.`calendar_id` = `calendar`.`id`
       JOIN `stores`
         ON `dailysales`.`store_id` = `stores`.`id`
       JOIN `items`
         ON `dailysales`.`item_id` = `items`.`id`;