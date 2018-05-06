library("ggplot2")
setwd("C:/Users/windows_sucks/temporal_databases/testdb_tests/testdb_test_results")

test <- read.csv (file = "test_results_1000.csv", header = FALSE, sep = ",", dec = ".")
str(test)
table <- data.frame (db=test$V1, category=test$V2, query=test$V3, iteration=test$V4, time=test$V5)
table
table$category[ grepl("ts_", table$query) ] <- "select"

# by db
testdb <- table[table$db == "testdb", ]
testdb_history <- table[table$db == "testdb_history", ]
# without select history
testdb_history_exclude_select_history <- testdb_history[ testdb_history$category != "select history", ]

# by select
testdb_select <- testdb[testdb$category == "select", ]
mean (testdb_select$time)
testdb_history_select <- testdb_history[ testdb_history$category == "select", ]
mean (testdb_history_select$time)

select <- table[ table$category == "select", ]
# by select history
testdb_history_select_history <- testdb_history[ testdb_history$category == "select history", ]
mean (testdb_history_select_history$time)
# by insert
testdb_insert <- testdb[testdb$category == "insert", ]
mean (testdb_insert$time)
testdb_history_insert <- testdb_history[testdb_history$category == "insert", ]
mean (testdb_history_insert$time)

insert <- table[table$category == "insert", ]
# by update
testdb_update <- testdb[testdb$category == "update", ]
mean (testdb_update$time)
testdb_history_update <- testdb_history[testdb_history$category == "update", ]
mean (testdb_history_update$time)

update <- table[table$category == "update", ]
# by delete
testdb_delete <- testdb[testdb$category == "delete", ]
mean (testdb_delete$time)
testdb_history_delete <- testdb_history[testdb_history$category == "delete", ]
mean (testdb_history_delete$time)

delete <- table[table$category == "delete", ]
# nrow() je rovnaky

# avg
mean (testdb$time)
mean (testdb_history$time)
# rozpyl a smerodatna odchylka
rozptyl <- mean (testdb$time^2) - mean (testdb$time)^2
rozptyl
rozptyl_history <- mean (testdb_history$time^2) - mean (testdb_history$time)^2
rozptyl_history
smerodatna_odchylka <- sqrt (rozptyl)
smerodatna_odchylka
smerodatna_odchylka_history <- sqrt (rozptyl_history)
smerodatna_odchylka_history
#median
median(testdb$time)
median(testdb_history$time)


# elapsed time over query categories
boxplot(testdb$time ~ testdb$category, ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "testdb: distribution of times of queries")
stripchart (testdb$time ~ testdb$category, vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

boxplot(testdb_history$time ~ testdb_history$category, ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "testdb_history: distribution of times of queries")
stripchart (testdb_history$time ~ testdb_history$category, vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

# elapsed time over updates
boxplot(update$time ~ update$db, ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "update: distribution of times")
stripchart (update$time ~ update$db, vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

# elapsed time over selects
boxplot(select$time ~ select$db, ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "select: distribution of times")
stripchart (select$time ~ select$db, vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

# elapsed time over inserts
boxplot(insert$time ~ insert$db, ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "insert: distribution of times")
stripchart (insert$time ~ insert$db, vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

# elapsed time over deletes
boxplot(delete$time ~ delete$db, ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "delete: distribution of times")
stripchart (delete$time ~ delete$db, vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

########################################################################################################
# krajsie boxploty
qplot(testdb$category, testdb$time, data=testdb, geom=c("boxplot", "jitter"), 
      fill=testdb$category, main="testdb: distribution of times of queries",
      xlab="", ylab="elapsed time [ms]")

qplot(testdb_history$category, testdb_history$time, data=testdb_history, geom=c("boxplot", "jitter"), 
      fill=testdb_history$category, main="testdb_history: distribution of times of queries",
      xlab="", ylab="elapsed time [ms]")

# elapsed time over updates
qplot(update$db, update$time, data = update, ylab='elapsed time [ms]', main = "update: distribution of times", 
      geom=c("boxplot", "jitter"), fill=update$db)

# elapsed time over selects
qplot(select$db, select$time, data = select, ylab='elapsed time [ms]', main = "select: distribution of times", 
      geom=c("boxplot", "jitter"), fill=select$db)

# elapsed time over inserts
qplot(insert$db, insert$time, data = insert, ylab='elapsed time [ms]', main = "insert: distribution of times", 
      geom=c("boxplot", "jitter"), fill=insert$db)

# elapsed time over deletes
qplot(delete$db, delete$time, data = delete, ylab='elapsed time [ms]', main = "delete: distribution of times", 
      geom=c("boxplot", "jitter"), fill=delete$db)


# farebne histogramy

ggplot(data=testdb, aes(testdb$time)) + 
  geom_histogram( breaks=seq(min(table$time), max(table$time), by =0.5), 
                 col="red", 
                 aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "green", high = "red")

ggplot(data=testdb_history, aes(testdb_history$time)) + 
  geom_histogram( breaks=seq(min(table$time), max(table$time), by =0.5), 
                  col="red", 
                  aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "green", high = "red")

ggplot(data=testdb_history_exclude_select_history, aes(testdb_history_exclude_select_history$time)) + 
  geom_histogram( breaks=seq(min(table$time), max(table$time), by =0.5), 
                  col="red", 
                  aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "green", high = "red")

# histogramy s rovnakou y osou
n <- 3000

ggplot(data=testdb, aes(testdb$time)) + 
  geom_histogram(breaks=seq(min(table$time), max(table$time), by = 0.5), 
                 col="red", 
                 aes(fill=..count..), 
                 alpha = 1) + 
  scale_fill_gradient("Count", low = "green", high = "red") +
  labs(title="Histogram for testdb") +
  labs(x="time", y="Count") + 
  xlim(c(0,max(table$time))) +
  ylim(c(0,n))

ggplot(data=testdb_history, aes(testdb_history$time)) + 
  geom_histogram(breaks=seq(min(table$time), max(table$time), by = 0.5), 
                 col="red", 
                 aes(fill=..count..), 
                 alpha = 1) + 
  scale_fill_gradient("Count", low = "green", high = "red") +
  labs(title="Histogram for testdb_history") +
  labs(x="time", y="Count") + 
  xlim(c(0,max(table$time))) +
  ylim(c(0,n))

ggplot(data=testdb_history_exclude_select_history, aes(testdb_history_exclude_select_history$time)) + 
  geom_histogram(breaks=seq(min(table$time), max(table$time), by = 0.5), 
                 col="red", 
                 aes(fill=..count..), 
                 alpha = 1) + 
  scale_fill_gradient("Count", low = "green", high = "red") +
  labs(title="Histogram for testdb_history excluding qieries: select history") +
  labs(x="time", y="Count") + 
  xlim(c(0,max(table$time))) +
  ylim(c(0,n))

