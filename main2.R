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

setkey(sales, week, month, year, StoreId, ItemId, base.week.sales)
week.sales <- sales[, .(promotion.id=max(promotion_id), week.sale=sum(StoreDemandQuantity)),
                    by=key(sales)]
setkey(week.sales, promotion.id)
promotionlevels <- promotions$desc
promotions$promotion.desc <- factor(promotions$desc, levels = promotionlevels)
promotions$desc <- NULL
setkey(promotions, id)
week.sales <- week.sales[promotions]
week.sales$week <- NULL
week.sales$year <- NULL
week.sales$promotion.id <- NULL

# factorizacion
# week.sales$promotion.desc <- as.factor(week.sales$desc)
week.sales$StoreId <- as.factor(week.sales$StoreId)
week.sales$ItemId <- as.factor(week.sales$ItemId)
week.sales$desc <- NULL
week.sales$month <- as.factor(week.sales$month)
rm(promotions)

week.sales[, `:=`(log.sales=log10(1+week.sale), log.base=log10(1+base.week.sales),
                  mult.resid=week.sale/base.week.sales)]

# dbDisconnect(forecastdb)
# week.sales[ ,c("week","year", "base.week.sales", "promotion.id", "week.sale", "log.base", "mult.resid") := NULL]
week.sales$month <- factor(week.sales$month)

modelo.2 <- glm(log.sales ~ month + StoreId + ItemId + promotion.desc, data=week.sales)

