from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, window, avg, count
from pyspark.sql.types import *

spark = SparkSession.builder \
    .appName("WeatherAggregation") \
    .master("spark://spark:7077") \
    .config("spark.jars.packages",
            "org.apache.spark:spark-sql-kafka-0-10_2.12:3.4.1") \
    .getOrCreate()

schema = StructType([
    StructField("temperature", DoubleType()),
    StructField("windspeed", DoubleType()),
    StructField("temp_f", DoubleType()),
    StructField("high_wind_alert", BooleanType()),
    StructField("time", StringType())
])

df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "kafka:9092") \
    .option("subscribe", "weather_transformed") \
    .load()

parsed = df.select(from_json(col("value").cast("string"), schema).alias("data")) \
           .select("data.*") \
           .withColumn("event_time", col("time").cast("timestamp"))

agg = parsed.groupBy(
    window(col("event_time"), "1 minute")
).agg(
    avg("temperature").alias("avg_temp_c"),
    count(col("high_wind_alert")).alias("alert_count")
)

query = agg.writeStream \
    .outputMode("complete") \
    .format("console") \
    .start()

query.awaitTermination()

agg.writeStream \
    .format("csv") \
    .option("path", "hdfs://namenode:9000/user/jovyan/weather_agg") \
    .option("checkpointLocation", "/tmp/weather_checkpoint") \
    .outputMode("append") \
    .start()
