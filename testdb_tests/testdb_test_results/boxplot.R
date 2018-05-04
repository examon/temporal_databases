library("ggplot2")

test <- read.csv (file = "test_results_100.csv", header = FALSE, sep = ",", dec = ".")
n <- 150
str(test)
table <- data.frame (db=test$V1, category=test$V2, query=test$V3, iteration=test$V4, time=test$V5)
table

testdb <- table[table$db == "testdb", ]
testdb
testdb_history <- table[table$db == "testdb_history", ]
testdb_history

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
boxplot(table$time ~ table$db, subset = table$category=="update", ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "update: distribution of times of queries")
stripchart (table$time ~ table$db, subset = table$category=="update", vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

# elapsed time over selects
boxplot(table$time ~ table$db, subset = table$category=="select", ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "select: distribution of times of queries")
stripchart (table$time ~ table$db, subset = table$category=="select", vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

# elapsed time over inserts
boxplot(table$time ~ table$db, subset = table$category=="insert", ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "insert distribution of times of queries")
stripchart (table$time ~ table$db, subset = table$category=="insert", vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

# elapsed time over deletes
boxplot(table$time ~ table$db, subset = table$category=="delete", ylab='elapsed time [ms]', ylim = c(0, max(table$time)), main = "delete distribution of times of queries")
stripchart (table$time ~ table$db, subset = table$category=="delete", vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 0.5, add = TRUE)

########################################################################################################
# krajsie boxploty
qplot(testdb$category, testdb$time, data=testdb, geom=c("boxplot", "jitter"), 
      fill=testdb$category, main="testdb: distribution of times of queries",
      xlab="", ylab="elapsed time [ms]")

qplot(testdb_history$category, testdb_history$time, data=testdb_history, geom=c("boxplot", "jitter"), 
      fill=testdb_history$category, main="testdb_history: distribution of times of queries",
      xlab="", ylab="elapsed time [ms]")

# elapsed time over updates
qplot(table$db, table$time, data = table[table$category == "update", ], ylab='elapsed time [ms]', main = "update: distribution of times of queries", geom=c("boxplot", "jitter"), 
      fill=table$db)

# elapsed time over selects
qplot(table$db, table$time, data = table[table$category == "select", ], ylab='elapsed time [ms]', main = "update: distribution of times of queries", geom=c("boxplot", "jitter"), 
      fill=table$db)

# elapsed time over inserts
qplot(table$db, table$time, data = table[table$category == "insert", ], ylab='elapsed time [ms]', main = "update: distribution of times of queries", geom=c("boxplot", "jitter"), 
      fill=table$db)

# elapsed time over deletes
qplot(table$db, table$time, data = table[table$category == "delete", ], ylab='elapsed time [ms]', main = "update: distribution of times of queries", geom=c("boxplot", "jitter"), 
      fill=table$db)


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

# histogramy s rovnakou y osou

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

