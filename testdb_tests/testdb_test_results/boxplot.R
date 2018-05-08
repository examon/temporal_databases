library("ggplot2")
setwd("C:/Users/windows_sucks/temporal_databases/testdb_tests/testdb_test_results")

files <- list.files(pattern = "*.csv")
data <- list()
table <- list()
for (i in files) {
  data[[i]] <- read.csv (file = i, header = FALSE, sep = ",", dec = ".")
  table[[i]] <- data.frame (db=data[[i]]$V1, category=data[[i]]$V2, query=data[[i]]$V3, iteration=data[[i]]$V4, time=data[[i]]$V5)
  table[[i]]$category[ grepl("ts_", table[[i]]$query) ] <- "select"
}

table[["test_results_1000.csv"]]$test <- "1000"
table[["test_results_200.csv"]]$test <- "200"
tables <- rbind(table[["test_results_1000.csv"]], table[["test_results_200.csv"]])
# renaming
levels(tables$db)[levels(tables$db)=="testdb"] <- "netemporální data"
levels(tables$db)[levels(tables$db)=="testdb_history"] <- "temporální data"
names(tables)[names(tables)=="db"]  <- "Databáze"
names(tables)[names(tables)=="time"]  <- "cas v ms"
levels(tables$test)[levels(tables$test)=="200"] <- "200 iterací"
levels(tables$test)[levels(tables$test)=="1000"] <- "1000 iterací"
names(tables)[names(tables)=="test"]  <- "pocet testu"
names(tables)[names(tables)=="category"]  <- "kategorie dotazu"

head(tables)

# Plot the bar chart.
plot(1,type='n',xlim=c(0,35000),ylim=c(0.0,max(tables$`cas v ms`)),xlab='Count', ylab='elapsed time [ms]')
title(main = list("Chování"))
lines(tables[tables$`pocet testu`=="200",]$`cas v ms`, type = "l", col="green", lwd=2)
lines(tables[tables$`pocet testu`=="1000",]$`cas v ms`, type = "l", col="red", lwd=2)
legend("topright", inset=.02, title="Pocet testu",
       lty=1, bty='n', c("200","1000"), col = c("green", "red"), horiz=TRUE, cex=0.8)

#########################################################

# average for 200 and 1000 itrs
means200 <- aggregate(`cas v ms` ~ `kategorie dotazu`, tables[tables$`pocet testu`=="200",], mean)
means200$`pocet testu` <- '200'

means1000 <- aggregate(`cas v ms` ~ `kategorie dotazu`, tables[tables$`pocet testu`=="1000",], mean)
means1000$`pocet testu` <- '1000'
means <- rbind(means200, means1000)

ggplot(means, aes(x = `kategorie dotazu`, fill = `pocet testu`, y = `cas v ms`)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(label = format(`cas v ms`, digits = 3), y = 25), position = position_dodge(width = 1), size=5.5) +
  labs(title="Prumery trvání dotazu pro netemporální a temporální data (200 + 1000 testu)") +
  theme(legend.title = element_text(size=16, face="bold")) +
  theme(legend.text = element_text(size = 16, face = "bold")) +
  theme(#axis.title.x = element_text(face="bold", size=16),
    axis.text.x  = element_text(size=16, face="bold"),
    axis.text.y = element_text(size=16, face="bold"))


###################################################################3
# average for 200/1000 itrs

x <- "1000" # pocet iteracii

means_testdb <- aggregate(`cas v ms` ~ `kategorie dotazu`, 
                          tables[tables$`pocet testu`==x & 
                          tables$Databáze == "netemporální data",], mean)
means_testdb$Databáze <- 'netemporální data'
means_testdb_history <- aggregate(`cas v ms` ~ `kategorie dotazu`, 
                          tables[tables$`pocet testu`==x &
                          tables$Databáze == "temporální data" & 
                          tables$`kategorie dotazu` != "select history",], mean)
means_testdb_history$Databáze <- 'temporální data'
means <- rbind(means_testdb, means_testdb_history)

ggplot(means, aes(x = `kategorie dotazu`, fill = Databáze, y = `cas v ms`)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(label = format(`cas v ms`, digits = 3), y = 25), position = position_dodge(width = 1), size=5.5) +
  labs(title=paste("Prumery trvání dotazu pro netemporální a temporální data (",x,"testu)")) +
  theme(legend.title = element_text(size=16, face="bold")) +
  theme(legend.text = element_text(size = 16, face = "bold")) +
  theme(#axis.title.x = element_text(face="bold", size=16),
    axis.text.x  = element_text(size=16, face="bold"),
    axis.text.y = element_text(size=16, face="bold"))


###################################################33
# boxploty

x <- "200" # pocet iteracii

table <- tables[tables$`pocet testu` == x, ]
mean (table$`cas v ms`)
median(table$`cas v ms`)
rozptyl <- mean (table$`cas v ms`^2) - mean (table$`cas v ms`)^2
rozptyl
smerodatna_odchylka <- sqrt (rozptyl)
smerodatna_odchylka
# by db
testdb <- table[table$Databáze == "netemporální data", ]
mean (testdb$`cas v ms`)
median(testdb$`cas v ms`)
rozptyl <- mean (testdb$`cas v ms`^2) - mean (testdb$`cas v ms`)^2
rozptyl
smerodatna_odchylka <- sqrt (rozptyl)
smerodatna_odchylka

testdb_history <- table[table$Databáze == "temporální data", ]
# without select history
testdb_history_exclude_select_history <- testdb_history[ testdb_history$`kategorie dotazu` != "select history", ]
mean(testdb_history_exclude_select_history$`cas v ms`)
median(testdb_history_exclude_select_history$`cas v ms`)
rozptyl <- mean (testdb_history_exclude_select_history$`cas v ms`^2) - mean (testdb_history_exclude_select_history$`cas v ms`)^2
rozptyl
smerodatna_odchylka <- sqrt (rozptyl)
smerodatna_odchylka
########################3

# by select
testdb_select <- testdb[testdb$`kategorie dotazu` == "select", ]
mean (testdb_select$`cas v ms`)
median(testdb_select$`cas v ms`)

testdb_history_select <- testdb_history[ testdb_history$`kategorie dotazu` == "select", ]
mean (testdb_history_select$`cas v ms`)
median(testdb_history_select$`cas v ms`)

select <- table[ table$`kategorie dotazu` == "select", ]

# by select history
testdb_history_select_history <- testdb_history[ testdb_history$`kategorie dotazu` == "select history", ]
mean (testdb_history_select_history$`cas v ms`)
median(testdb_history_select_history$`cas v ms`)

# by insert
testdb_insert <- testdb[testdb$`kategorie dotazu` == "insert", ]
mean (testdb_insert$`cas v ms`)
median(testdb_insert$`cas v ms`)

testdb_history_insert <- testdb_history[testdb_history$`kategorie dotazu` == "insert", ]
mean (testdb_history_insert$`cas v ms`)
median (testdb_history_insert$`cas v ms`)

insert <- table[table$`kategorie dotazu` == "insert", ]

# by update
testdb_update <- testdb[testdb$`kategorie dotazu` == "update", ]
mean (testdb_update$`cas v ms`)
median(testdb_update$`cas v ms`)

testdb_history_update <- testdb_history[testdb_history$`kategorie dotazu` == "update", ]
mean (testdb_history_update$`cas v ms`)
median(testdb_history_update$`cas v ms`)

update <- table[table$`kategorie dotazu` == "update", ]

# by delete
testdb_delete <- testdb[testdb$`kategorie dotazu` == "delete", ]
mean (testdb_delete$`cas v ms`)
median(testdb_delete$`cas v ms`)

testdb_history_delete <- testdb_history[testdb_history$`kategorie dotazu` == "delete", ]
mean (testdb_history_delete$`cas v ms`)
median(testdb_history_delete$`cas v ms`)

delete <- table[table$`kategorie dotazu` == "delete", ]
# nrow() je rovnaky


########################################################################################################
# krajsie boxploty

# porovnanie select history 200 a 1000
ggplot(tables[tables$`kategorie dotazu`=="select history",], aes(x=`pocet testu`, y=`cas v ms`, color=`pocet testu`)) + 
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2)) +
  stat_summary(fun.y=mean, geom="point", shape=18, size=3, color="red") +
  stat_summary(fun.y=median, geom="point", shape=18, size=3, color="green") +
  #stat_summary(fun.data=mean_sdl, mult=1, geom="pointrange", color="black") +
  labs(title=paste("Prumer, medián pro select history (200 a 1000 testu)")) +
  theme(legend.position="none") +
  theme(legend.title = element_text(size=16, face="bold")) +
  theme(legend.text = element_text(size = 16, face = "bold")) +
  theme(#axis.title.x = element_text(face="bold", size=16),
    axis.text.x  = element_text(size=16, face="bold"),
    axis.text.y = element_text(size=16, face="bold"))

ggplot(testdb, aes(x=`kategorie dotazu`, y=`cas v ms`, color=`kategorie dotazu`)) + 
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2)) +
  stat_summary(fun.y=mean, geom="point", shape=18, size=3, color="red") +
  stat_summary(fun.y=median, geom="point", shape=18, size=3, color="green") +
  #stat_summary(fun.data=mean_sdl, mult=1, geom="pointrange", color="black") +
  labs(title=paste("Prumer, medián pro netemporální data (",x,"testu)")) +
  theme(legend.position="none") +
  theme(legend.title = element_text(size=16, face="bold")) +
  theme(legend.text = element_text(size = 16, face = "bold")) +
  theme(#axis.title.x = element_text(face="bold", size=16),
        axis.text.x  = element_text(size=16, face="bold"),
        axis.text.y = element_text(size=16, face="bold"))

ggplot(testdb_history, aes(x=`kategorie dotazu`, y=`cas v ms`, color=`kategorie dotazu`)) + 
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2)) +
  stat_summary(fun.y=mean, geom="point", shape=18, size=3, color="red") +
  stat_summary(fun.y=median, geom="point", shape=18, size=3, color="green") +
  #stat_summary(fun.data=mean_sdl, mult=1, geom="pointrange", color="black") +
  labs(title=paste("Prumer, medián pro temporální data (",x,"testu)")) +
  theme(legend.position="none") +
  theme(legend.title = element_text(size=16, face="bold")) +
  theme(legend.text = element_text(size = 16, face = "bold")) +
  theme(#axis.title.x = element_text(face="bold", size=16),
    axis.text.x  = element_text(size=16, face="bold"),
    axis.text.y = element_text(size=16, face="bold"))

# elapsed time over updates

ggplot(update, aes(x=Databáze, y=`cas v ms`, color=Databáze)) + 
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2)) +
  stat_summary(fun.y=mean, geom="point", shape=18, size=3, color="red") +
  stat_summary(fun.y=median, geom="point", shape=18, size=3, color="green") +
  labs(title=paste("Porovnání výsledku update dotazu (",x,"testu)")) +
  theme(legend.position="none") +
  theme(legend.title = element_text(size=16, face="bold")) +
  theme(legend.text = element_text(size = 16, face = "bold")) +
  theme(#axis.title.x = element_text(face="bold", size=16),
    axis.text.x  = element_text(size=16, face="bold"),
    axis.text.y = element_text(size=16, face="bold"))

# elapsed time over selects

ggplot(select, aes(x=Databáze, y=`cas v ms`, color=Databáze)) + 
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2)) +
  stat_summary(fun.y=mean, geom="point", shape=18, size=3, color="red") +
  stat_summary(fun.y=median, geom="point", shape=18, size=3, color="green") +
  labs(title=paste("Porovnání výsledku select dotazu (",x,"testu)")) +
  theme(legend.position="none") +
  theme(legend.title = element_text(size=16, face="bold")) +
  theme(legend.text = element_text(size = 16, face = "bold")) +
  theme(#axis.title.x = element_text(face="bold", size=16),
    axis.text.x  = element_text(size=16, face="bold"),
    axis.text.y = element_text(size=16, face="bold"))

# elapsed time over inserts

ggplot(insert, aes(x=Databáze, y=`cas v ms`, color=Databáze)) + 
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2)) +
  stat_summary(fun.y=mean, geom="point", shape=18, size=3, color="red") +
  stat_summary(fun.y=median, geom="point", shape=18, size=3, color="green") +
  labs(title=paste("Porovnání výsledku insert dotazu (",x,"testu)")) +
  theme(legend.position="none") +
  theme(legend.title = element_text(size=16, face="bold")) +
  theme(legend.text = element_text(size = 16, face = "bold")) +
  theme(#axis.title.x = element_text(face="bold", size=16),
    axis.text.x  = element_text(size=16, face="bold"),
    axis.text.y = element_text(size=16, face="bold"))

# elapsed time over deletes

ggplot(delete, aes(x=Databáze, y=`cas v ms`, color=Databáze)) + 
  geom_boxplot() +
  geom_jitter(position=position_jitter(0.2)) +
  stat_summary(fun.y=mean, geom="point", shape=18, size=3, color="red") +
  stat_summary(fun.y=median, geom="point", shape=18, size=3, color="green") +
  labs(title=paste("Porovnání výsledku delete dotazu (",x,"testu)")) +
  theme(legend.position="none") +
  theme(legend.title = element_text(size=16, face="bold")) +
  theme(legend.text = element_text(size = 16, face = "bold")) +
  theme(#axis.title.x = element_text(face="bold", size=16),
    axis.text.x  = element_text(size=16, face="bold"),
    axis.text.y = element_text(size=16, face="bold"))


###################################################################################
# farebne histogramy

ggplot(data=testdb, aes(testdb$`cas v ms`)) + 
  geom_histogram( breaks=seq(min(table$`cas v ms`), max(table$`cas v ms`), by =0.5), 
                  col="red", 
                  aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "green", high = "red")

ggplot(data=testdb_history, aes(testdb_history$`cas v ms`)) + 
  geom_histogram( breaks=seq(min(table$`cas v ms`), max(table$`cas v ms`), by =0.5), 
                  col="red", 
                  aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "green", high = "red")

ggplot(data=testdb_history_exclude_select_history, aes(testdb_history_exclude_select_history$`cas v ms`)) + 
  geom_histogram( breaks=seq(min(table$`cas v ms`), max(table$`cas v ms`), by =0.5), 
                  col="red", 
                  aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "green", high = "red")

#############################################################
# fareb. histogramy s rovnakou y osou

n <- 3000

ggplot(data=testdb, aes(testdb$`cas v ms`)) + 
  geom_histogram(breaks=seq(min(table$`cas v ms`), max(table$`cas v ms`), by = 0.5), 
                 col="red", 
                 aes(fill=..count..), 
                 alpha = 1) + 
  scale_fill_gradient("Count", low = "green", high = "red") +
  labs(title="Histogram for testdb") +
  labs(x="time", y="Count") + 
  xlim(c(0,max(table$`cas v ms`))) +
  ylim(c(0,n))

ggplot(data=testdb_history, aes(testdb_history$`cas v ms`)) + 
  geom_histogram(breaks=seq(min(table$`cas v ms`), max(table$`cas v ms`), by = 0.5), 
                 col="red", 
                 aes(fill=..count..), 
                 alpha = 1) + 
  scale_fill_gradient("Count", low = "green", high = "red") +
  labs(title="Histogram for testdb_history") +
  labs(x="time", y="Count") + 
  xlim(c(0,max(table$`cas v ms`))) +
  ylim(c(0,n))

ggplot(data=testdb_history_exclude_select_history, aes(testdb_history_exclude_select_history$`cas v ms`)) + 
  geom_histogram(breaks=seq(min(table$`cas v ms`), max(table$`cas v ms`), by = 0.5), 
                 col="red", 
                 aes(fill=..count..), 
                 alpha = 1) + 
  scale_fill_gradient("Count", low = "green", high = "red") +
  labs(title="Histogram for testdb_history excluding qieries: select history") +
  labs(x="time", y="Count") + 
  xlim(c(0,max(table$`cas v ms`))) +
  ylim(c(0,n))

