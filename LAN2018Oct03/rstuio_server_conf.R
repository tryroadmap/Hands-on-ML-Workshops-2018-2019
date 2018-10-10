install.packages("ggplot2", dependencies = TRUE)
install.packages("dplyr", dependencies = TRUE)
install.packages("sparklyr", dependencies = TRUE)
# install.packages(c("ggplot2", "dplyr", "sparklyr"), dependencies = TRUE) # rest omitted
install.packages(c("nycflights13", "Lahman"))



#============================================
# R Studio Beta
#============================================
# Connect to Spark
library(ggplot2)
library(dplyr)
library(sparklyr)

spark_install(version = "2.1.0")
sc <- spark_connect(master = "local", version = "2.1.0")


flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
airlines_tbl <- copy_to(sc, nycflights13::airlines, 'airlines')
airports_tbl <- copy_to(sc, nycflights13::airports, 'airports')

src_tbls(sc)

#solves memory limit issue on R, R Studio
#memory.limit()

delay <- flights_tbl %>%
  group_by(tailnum) %>%
  summarise(count = n(), dist = mean(distance), delay = mean(arr_delay)) %>%
  filter(count > 20, dist < 2000, !is.na(delay)) %>%
  collect

# plot delays
# for Rstudio beta
png("myplot.png")
myplot <- ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area(max_size = 2)


print(myplot)
dev.off()


#============================================
# Pipelining 1.1.02
#============================================

df <- flights_tbl %>%
  filter(!is.na(dep_delay)) %>%
  mutate(
    month = paste0("m", month),
    day = paste0("d", day)
  ) %>%
  select(dep_delay, sched_dep_time, month, day, distance)

ft_dplyr_transformer(sc, df)

ft_dplyr_transformer(sc, df) %>%
  ml_param("statement")


flights_pipeline <- ml_pipeline(sc) %>%
  ft_dplyr_transformer(
    tbl = df
    ) %>%
  ft_binarizer(
    input.col = "dep_delay",
    output.col = "delayed",
    threshold = 15
  ) %>%
  ft_bucketizer(
    input.col = "sched_dep_time",
    output.col = "hours",
    splits = c(400, 800, 1200, 1600, 2000, 2400)
  )  %>%
  ft_r_formula(delayed ~ month + day + hours + distance) %>%
  ml_logistic_regression()

flights_pipeline

partitioned_flights <- sdf_partition(
  flights_tbl,
  training = 0.01,
  testing = 0.01,
  rest = 0.98
)

fitted_pipeline <- ml_fit(
  flights_pipeline,
  partitioned_flights$training
)
fitted_pipeline

predictions <- ml_transform(
  fitted_pipeline,
  partitioned_flights$testing
)

predictions %>%
  group_by(delayed, prediction) %>%
  tally()


ml_save(
  flights_pipeline,
  "flights_pipeline",
  overwrite = TRUE
)

## NULL

ml_save(
  fitted_pipeline,
  "flights_model",
  overwrite = TRUE
)

## NULL

reloaded_model <- ml_load(sc, "flights_model")

new_df <- flights_tbl %>%
  filter(
    month == 7,
    day == 5
  )

ml_transform(reloaded_model, new_df)


spark_disconnect(sc)

#============================================
# R Studio 1.1.02
#============================================

Sys.setenv(SPARK_HOME="/usr/lib/spark")
config <- spark_config()
sc <- spark_connect(master = "yarn-client", config = config, version = '1.6.2')
#MemoryStore: MemoryStore started with capacity 366.3 MB


# Cache flights Hive table into Spark
tbl_cache(sc, 'flights')
flights_tbl <- tbl(sc, 'flights')

# Cache airlines Hive table into Spark
tbl_cache(sc, 'airlines')
airlines_tbl <- tbl(sc, 'airlines')

# Cache airports Hive table into Spark
tbl_cache(sc, 'airports')
airports_tbl <- tbl(sc, 'airports')



# Filter records and create target variable 'gain'
model_data <- flights_tbl %>%
  filter(!is.na(arrdelay) & !is.na(depdelay) & !is.na(distance)) %>%
  filter(depdelay > 15 & depdelay < 240) %>%
  filter(arrdelay > -60 & arrdelay < 360) %>%
  filter(year >= 2003 & year <= 2007) %>%
  left_join(airlines_tbl, by = c("uniquecarrier" = "code")) %>%
  mutate(gain = depdelay - arrdelay) %>%
  select(year, month, arrdelay, depdelay, distance, uniquecarrier, description, gain)

# Summarize data by carrier
model_data %>%
  group_by(uniquecarrier) %>%
  summarize(description = min(description), gain=mean(gain),
            distance=mean(distance), depdelay=mean(depdelay)) %>%
  select(description, gain, distance, depdelay) %>%
  arrange(gain)


#============================================
# END R Studio 1.1.02
#============================================

spark_disconnect(sc)
