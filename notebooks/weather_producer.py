from kafka import KafkaProducer
import requests, json, time

API_URL = "https://api.open-meteo.com/v1/forecast"
LAT, LON = 52.52, 13.41
KAFKA_TOPIC = "weather_transformed"
KAFKA_BROKER = "kafka:9092"

def fetch_weather():
    params = {
        "latitude": LAT,
        "longitude": LON,
        "current_weather": "true"
    }
    r = requests.get(API_URL, params=params, timeout=10)
    r.raise_for_status()
    return r.json().get("current_weather", {})

def transform_weather(record):
    if "temperature" in record:
        record["temp_f"] = record["temperature"] * 9/5 + 32
    record["high_wind_alert"] = record.get("windspeed", 0) > 10
    return record

producer = KafkaProducer(
    bootstrap_servers=KAFKA_BROKER,
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

while True:
    weather = fetch_weather()
    if weather:
        producer.send(KAFKA_TOPIC, transform_weather(weather))
        producer.flush()
        print("Sent:", weather)
    time.sleep(30)
