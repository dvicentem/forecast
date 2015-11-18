source('dbconection.R')
library('reshape2')
library('data.table')

query <- 'select * from promotions'
promotions <- data.table(dbGetQuery(forecastdb, query))
query <- readQuery('sales_extraction.sql')
sales <- data.table(dbGetQuery(forecastdb, query))
sales[, year.week:=paste(year(full_date),sprintf('%02d',week(full_date)), sep='.')]
week.sales <- sales[, .(demand=sum(StoreDemandQuantity), promotion_id=sum(promotion_id)), by= .(year.week, StoreId, ItemId)]

sales.series <- dcast.data.table(week.sales, year.week~StoreId + ItemId,
                      fun=sum, value.var = c("demand"))

promotions.series <- dcast.data.table(week.sales, year.week~StoreId + ItemId,
                                 fun=sum, value.var = c("promotion_id"))

timestamps.series <- sales.series$year.week
sales.series$year.week <- NULL
filtered.series <- data.table(apply(as.matrix(sales.series), 2, function(x) 
  filter(x, method = 'convolution', sides = 1, c(.5,.32,.18))))
filtered.series[is.na(filtered.series)] <- 0.0
log.residuals <- log(1+sales.series) - log(1+filtered.series)
log.residuals$year.week <- timestamps.series
log.residuals <- melt.data.table(log.residuals, id.vars = 'year.week', variable.factor = FALSE, value.name = 'mult.resid')
setkey(log.residuals, year.week, variable)
promotions.series <- melt.data.table(promotions.series, id.vars = 'year.week', variable.factor = FALSE, value.name = 'promotion_id')
setkey(promotions.series, year.week, variable)

log.residuals.promotions <- promotions.series[log.residuals]

#first sales
min(sales$year.week)

