test <- read.csv (file = "test_results_1.csv", header = FALSE, sep = ",", dec = ".")
str(test)
table <- data.frame (db=test$V1, category=test$V2, query=test$V3, iteration=test$V4, time=test$V5)
table

# filter category...
# avg
mean (table$time)
# rozpyl a smerodatna odchylka
rozptyl <- mean (table$time^2) - mean (table$time)^2
rozptyl
smerodatna_odchylka <- sqrt (rozptyl)
smerodatna_odchylka
#median
median(table$time)


# elapsed time over query categories
boxplot(table$time ~ table$category, subset = table$db=="testdb", ylab='elapsed time [ms]', main = "boxplot distribution of times of queries")
stripchart (table$time ~ table$category, subset = table$db=="testdb", vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 1.5, add = TRUE)

boxplot(table$time ~ table$category, subset = table$db=="testdb_history", ylab='elapsed time [ms]', main = "boxplot distribution of times of queries")
stripchart (table$time ~ table$category, subset = table$db=="testdb_history", vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 1.5, add = TRUE)

# elapsed time over updates
boxplot(table$time ~ table$db, subset = table$category=="update", ylab='elapsed time [ms]', main = "boxplot distribution of times of queries")
stripchart (table$time ~ table$db, subset = table$category=="update", vertical = TRUE, method = "jitter", pch = 21, col = "red", bg = "yellow", cex = 1.5, add = TRUE)
