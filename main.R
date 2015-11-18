source('dbconection.R')
library('reshape2')
library('data.table')

query <- readQuery('item_success_in_category.sql')
item.success.in.category <- data.table(dbGetQuery(forecastdb, query))
query <- readQuery('store_cat_avg_item_week_sale.sql')
store.cat.avg.item.week.sale <- data.table(dbGetQuery(forecastdb, query))
query <- 'select * from promotions'
promotions <- data.table(dbGetQuery(forecastdb, query))
query <- readQuery('sales_extraction.sql')
sales <- data.table(dbGetQuery(forecastdb, query))
setkey(sales, StoreId, ItemCategory1)
setkey(store.cat.avg.item.week.sale, StoreId, ItemCategory1)

sales <- sales[store.cat.avg.item.week.sale]

setkey(sales, ItemCategory1, ItemId)
setkey(item.success.in.category, ItemCategory1, ItemId)

sales <- sales[item.success.in.category]
sales[,base.week.sales:=category_average_week_sales * item_success]
sales$category_average_week_sales <- NULL
sales$item_success <- NULL
rm(item.success.in.category, store.cat.avg.item.week.sale)

setkey(sales, week, month, year, StoreId, ItemId, ItemCategory1, base.week.sales)
week.sales <- sales[, .(promotion.id=max(promotion_id), week.sale=sum(StoreDemandQuantity)),
                    by=key(sales)]
setkey(week.sales, promotion.id)

# promotions$valor <- 1
# promotions <- dcast(promotions, id~desc)
# promotions[is.na(promotions)] <- 0

setkey(promotions, id)
week.sales <- week.sales[promotions]
promotions.levels <- promotions$desc
rm(promotions)

# factorizacion

week.sales$StoreId <- as.factor(week.sales$StoreId)
week.sales$ItemId <- as.factor(week.sales$ItemId)
week.sales$month <- as.factor(week.sales$month)
week.sales$promotion.id <- NULL
week.sales$promotion <- factor(week.sales$desc, levels=promotions.levels)
week.sales$desc <- NULL
week.sales$ItemCategory1 <- as.factor(week.sales$ItemCategory1)
# dbDisconnect(forecastdb)

#sobrantes
week.sales$week <- NULL
week.sales$year <- NULL
week.sales$base.week.sales <- NULL
week.sales$ItemId <- NULL

#logs
week.sales$week.sale <- log(1+week.sales$week.sale)

modelo.week.sales <- glm(week.sale ~ ., data=week.sales)
