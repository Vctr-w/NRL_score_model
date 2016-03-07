install.packages("ggplot2")
install.packages("reshape2")
install.packages("plyr")
install.packages("jsonlite")
install.packages("sqldf")
install.packages("gridExtra")
install.packages("forecast")
install.packages("quadprog")

#install.packages("RPostgreSQL")

library("forecast")
library("gridExtra")
library("ggplot2")
library("reshape2")
library("jsonlite")
library("plyr")
library("sqldf")
library("stats")
#library("RPostgreSQL")

#Unix
json_file <- "/home/vctr/Dropbox/Hack/Webscrape/NRL/NRL_seasondata.json"

#Windows
json_file <- "C:/Users/Victor/Dropbox/Hack/Webscrape/NRL/NRL_seasondata.json"

json_data <- fromJSON(paste(readLines(json_file), collapse = ""))

NRL_data = json_data$seasons

Special_rounds <- c("Finals Week 1", "Finals Week 2", "Finals Week 3", "Grand Final")

#NRL_normal_rounds <- NRL_data[!(NRL_data$Value %in% Special_rounds),]

NRL_playedrounds <- NRL_data[(NRL_data$PossessionSeconds != 0) & (NRL_data$RoundID != 0),]

Roundkey <- unique(NRL_playedrounds[c("Nickname", "SeasonYear", "RoundID")])

Roundkey <- 
  sqldf("SELECT *, (
          SELECT COUNT(*) 
          FROM Roundkey b 
          WHERE a.Nickname = b.Nickname 
            AND a.RoundID >= b.RoundID
        ) [RowID] 
        FROM Roundkey a")

NRL_playedrounds_keyed <- 
  sqldf("SELECT * 
          FROM NRL_playedrounds a 

          INNER JOIN Roundkey b 
            ON a.RoundID = b.RoundID 
              AND a.SeasonYear = b.SeasonYear
              AND a.Nickname = b.Nickname")

Teams <- unique(NRL_playedrounds_keyed$Nickname)

PDF = "C:\\Users\\Victor\\Dropbox\\victor's secret angels\\Points over time (Differencing).pdf"
pdf(file = PDF)

for (team in Teams) {
  d <- NRL_playedrounds_keyed[NRL_playedrounds_keyed$Nickname == team,]
  plot(ggplot(d, aes(x = RowID, y = Points, colour = Nickname, group = Nickname)) + geom_line())
  NRL_ts <- ts(d$Points)  
  d1 <- diff(NRL_ts, diff = 1)
  plot.ts(d1)
  d2 <- diff(NRL_ts, diff = 2)
  plot.ts(d2)
}

dev.off()

PDF = "C:\\Users\\Victor\\Dropbox\\victor's secret angels\\Points over time (ACF PACF).pdf"
pdf(file = PDF)

for (team in Teams) {
  d <- NRL_playedrounds_keyed[NRL_playedrounds_keyed$Nickname == team,]
  NRL_ts <- ts(d$Points)  
  d1 <- diff(NRL_ts, diff = 1)
  acf(d1, lag.max = 20)
  pacf(d1,lag.max = 20)
}

dev.off()

PDF = "C:\\Users\\Victor\\Dropbox\\victor's secret angels\\Points over time (Forecasting).pdf"
pdf(file = PDF)

for (team in Teams) {
  d <- NRL_playedrounds_keyed[NRL_playedrounds_keyed$Nickname == team,]
  NRL_ts <- ts(d$Points)  
  #plot(ggplot(d, aes(x = RowID, y = Points, colour = Nickname, group = Nickname)) + geom_line())
  NRL_arima <- arima(NRL_ts, c(0, 1, 1))
  NRL_forecast <- forecast.Arima(NRL_arima, h = 5)
  plot.forecast(NRL_forecast)
}

dev.off()


#do.call(grid.arrange, plots)





PCA_col <- c("Errors", "AllRunMetres", "PossessionPercentage", "BreaksTackle", "AllRuns",
             "KickMetres", "FieldGoals", "SendOffs", "PossessionSeconds",
             "Tries", "TryAssists", "MissedTackles", "Kicks", "Goals", "Offloads",
             "SinBins", "Tackles", "PenaltyGoals", "Conversions", "Penalties",
             "LinebreakAssists", "Kicks4020", "Points", "DummyHalfRuns", "Linebreaks")

#Removed ConversionsMissed and KickReturnMetres

PCA_col2 <- c("Errors", "AllRunMetres", "PossessionPercentage", "BreaksTackle", "AllRuns",
             "KickMetres", "FieldGoals", "SendOffs", "PossessionSeconds", "MissedTackles",
             "Kicks", "Offloads", "SinBins", "Tackles", "PenaltyGoals", "Penalties",
             "LinebreakAssists", "Kicks4020", "DummyHalfRuns", "Linebreaks")


NRL.pca <- prcomp(NRL_playedrounds_keyed[PCA_col], 
                  center = TRUE,
                  scale. = TRUE)

NRL.pca <- prcomp(NRL_playedrounds_keyed[PCA_col2], 
                  center = TRUE,
                  scale. = TRUE)


NRL.pca
summary(NRL.pca)
plot(NRL.pca)


tmp<-NRL_playedrounds_keyed[PCA_col]
names(tmp[, sapply(tmp, function(v) var(v, na.rm=TRUE)==0)])

NRL_response <- NRL_playedrounds_keyed[c("Nickname", "RowID", "Points")]





summary(json_data$seasons)




class(json_data$seasons)
typeof(json_data$seasons)

summary(json_data$seasons)
#Round 1
json_data$seasons[json_data$seasons$RoundID == 2,]