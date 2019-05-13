import pickle
import os
import numpy as np
from PIL import Image

def load_data(size, cached = True):
    if cached and str(size) in os.listdir("/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/"):
        print("Loading data from cache ...")
        return pickle.load(open(f"/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/{size}", "rb"))

    res = []
    data_set, rain_set, snow_set =  set([int(filename[:-4]) for filename in os.listdir("/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/training data/past data/") if filename[-4:] == ".txt"]), \
                                    set([int(filename[:-4]) for filename in os.listdir("/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/training data/processed image data/rain") if filename[-4:] == ".jpg"]), \
                                    set([int(filename[:-4]) for filename in os.listdir("/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/training data/processed image data/snow") if filename[-4:] == ".jpg"])
    # we may loss or have some bad data for certain days
    valid_set = data_set & rain_set & snow_set
    fail = 0
    for time in valid_set:
        if len(res) == size:
            with open(f'/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/{size}', 'wb') as f:
                pickle.dump(res, f)
            return res
        next_hour = time + 60 * 60
        if len(res) % 100 == 0:
            print(f"Successfully loaded {len(res)} / {len(res)+fail} data")
        if next_hour in valid_set:
            try:
                rain_img = Image.open(f"/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/training data/processed image data/rain/{time}.jpg")
                snow_img = Image.open(f"/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/training data/processed image data/snow/{time}.jpg")
                rain_arr = np.array(rain_img.getdata()).reshape(rain_img.size[0], rain_img.size[1], 3)
                snow_arr = np.array(snow_img.getdata()).reshape(snow_img.size[0], snow_img.size[1], 3)
                cur_data = pickle.load(open(f"/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/training data/past data/{time}.txt", "rb"))["current"]
                nex_data = pickle.load(open(f"/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/training data/past data/{next_hour}.txt", "rb"))["current"]
                res.append((rain_arr, snow_arr, [convertIconToInt(cur_data["icon"]), cur_data["precipIntensity"], cur_data["precipProbability"], cur_data["temperature"], cur_data["humidity"], cur_data["pressure"], \
                            cur_data["windSpeed"], cur_data["cloudCover"], cur_data["uvIndex"], cur_data["visibility"] ], [convertIconToInt(nex_data["icon"]), nex_data["temperature"]]))
            except:
                fail += 1

    with open(f'/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/{size}', 'wb') as f:
        pickle.dump(res, f)
    return res

def convertIconToInt(icon):
    if icon in ["clear-day", "clear-night"]:
        return 0
    elif icon == "rain":
        return 1
    elif icon in ["snow", "sleet"]:
        return 2
    elif icon == "wind":
        return 3
    elif icon in ["cloudy", "fog", "partly-cloudy-day", "partly-cloudy-night"]:
        return 4
    else:
        raise Exception("Icon out of range")





