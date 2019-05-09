import requests
import pickle
from datetime import datetime

key = "10e08d045423d75673a8129ff5ad26c5"
latitude = 43.6518927
longitude = -79.381713

for time in range(1534809600, 1546318800, 60 * 60):
    URL = f"https://api.darksky.net/forecast/{key}/{latitude},{longitude},{time}"
    r = requests.get(url=URL)
    data = r.json()
    try:
        current = data["currently"]
        hourlyData = data["hourly"]["data"]
        wholeDay = data["daily"]["data"][0]
        
        print(f"successfully load data for {datetime.utcfromtimestamp(time).strftime('%Y-%m-%d %H:%M:%S')}, timestamp: {time}")
        with open(f"past data/{time}.txt", "wb") as myFile:
            pickle.dump({"current":current, "hourly":hourlyData, "daily":wholeDay}, myFile)
    except:
        print(f"failed load data for {datetime.utcfromtimestamp(time).strftime('%Y-%m-%d %H:%M:%S')}, timestamp: {time}")



