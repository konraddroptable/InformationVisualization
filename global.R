library(dplyr)

parseFrame <- function(frm, ...){
  x <- frm[grepl(pattern = "Total", x = frm$category) &
             grepl("[^Total Population]", frm$category), ]
  
  x$category <- gsub("Total|[ +]", "", x$category)
  mainRel <- c("Christianity", "Judaism", "Islam", "Buddhism", "Hindu", "Non.Religious")
  x[!(x$category %in% mainRel), "category"] <- "Other"
  x$Number.of.people <- as.numeric(gsub(pattern = ",", replacement = "", x = x$Number.of.people))
  
  
  ret <- dplyr::group_by(x, ...) %>%
    dplyr::summarise(Population = sum(Number.of.people),
                     Percentage = sum(Percentage))
  
  return(ret)
}

df.n <- parseFrame(read.csv("WRP_national_mod.csv", sep = ",", check.names = TRUE, stringsAsFactors = FALSE),
                   year, country, category)
df.r <- parseFrame(read.csv("WRP_regional_mod.csv", sep = ",", check.names = TRUE, stringsAsFactors = FALSE),
                   year, region, category)
df.g <- parseFrame(read.csv("WRP_global_mod.csv", sep = ",", check.names = TRUE, stringsAsFactors = FALSE),
                   year, category)

code <- read.csv("codes.csv", sep = ";", stringsAsFactors = FALSE)

names(df.n) <- names(df.r)
df <- rbind(df.r, df.n)

### Map plot
df.joined <- dplyr::inner_join(x = df.n, y = code, by = c("region" = "id"))
df.map <- dplyr::group_by(df.joined, year, region, code2, code3, continent) %>%
  dplyr::filter(Percentage == max(Percentage))

df.map.table1 <- df.joined[, c("year", "category", "Population", "continent")] %>%
  dplyr::group_by(year, category, continent) %>%
  dplyr::summarise(Pop = sum(Population)) %>%
  dplyr::mutate(id = paste(year, continent, sep = ""))

df.map.table2 <- dplyr::group_by(df.map.table1, year, continent, id) %>%
  dplyr::summarize(Pop = sum(Pop))

df.map.table <- dplyr::inner_join(df.map.table1, df.map.table2, by = "id")
df.map.table <- df.map.table[, c("year.x", "category", "continent.x", "Pop.x", "Pop.y")]
names(df.map.table) <- c("year", "category", "continent", "Pop.x", "Pop.y")
df.map.table$Percent <- as.numeric(df.map.table$Pop.x / df.map.table$Pop.y)

df.map.table.summary <- dplyr::group_by(df.map.table, year, continent) %>%
  dplyr::filter(Percent >= max(Percent))

