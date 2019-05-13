from keras.models import Sequential, model_from_json
from keras.layers import Dense, Conv2D, Flatten, MaxPooling2D
import matplotlib.pyplot as plt
from keras.datasets import mnist
from keras.utils import to_categorical
import numpy as np
import loader
import random

import requests
from bs4 import BeautifulSoup
import urllib.request 
from PIL import Image
from datetime import datetime
import time

def preprocess_data(size):
    training_size = int(size * 0.9)
    all_data = loader.load_data(size)
    random.shuffle(all_data)
    training_data = all_data[:training_size]
    validation_data = all_data[training_size:]
    
    return (np.array([x[1] for x in training_data]), np.array([x[-1][0] for x in training_data])), \
            (np.array([x[1] for x in validation_data]), np.array([x[-1][0] for x in validation_data]))

def fetch_image(timestamp, target):
    date = datetime.fromtimestamp(timestamp)
    params = {
        'site': 'ONT',
        'year': date.year,
        'month': date.month,
        'day': date.day,
        'hour': date.hour,
        'minute': date.minute,
        'duration': 2,
        'image_type': f'PRECIPET_{target.upper()}_WEATHEROFFICE'
    }
    try:
        response = requests.session().get('http://climate.weather.gc.ca/radar/index_e.html', params=params)
        html = BeautifulSoup(response.content, 'html.parser')
        image_url = html.body.main.span.img['src']
        image_base = 'http://climate.weather.gc.ca'
        urllib.request.urlretrieve(image_base+image_url, f'/Users/caoshuheng 1/Desktop/{str(int(timestamp))}.jpg')
        imageObject = Image.open(f'/Users/caoshuheng 1/Desktop/{str(int(timestamp))}.jpg')
        cropped = imageObject.crop((300,100,450,250))
        snow_img = cropped.convert('RGB')

        return np.array(snow_img.getdata()).reshape(snow_img.size[0], snow_img.size[1], 3)
    except:
        print("ERROR: {}".format(str(int(timestamp))))


def cnn_training(cached = True):
    (X_train, y_train), (X_test, y_test) = preprocess_data(10000)

    for i, v in np.ndenumerate(y_train):
        if v == 0:
            y_train[i] = 0
        elif v <= 4:
            y_train[i] = 1
        
    for i, v in np.ndenumerate(y_test):
        if v == 0:
            y_test[i] = 0
        elif v <= 4:
            y_test[i] = 1

    #one-hot encode target column
    y_train = to_categorical(y_train)
    y_test = to_categorical(y_test)

    if cached:
        # load json and create model
        json_file = open('/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/cnn_model2.json', 'r')
        loaded_model_json = json_file.read()
        json_file.close()
        model = model_from_json(loaded_model_json)
        # load weights into new model
        model.load_weights("/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/cnn_model2.h5")
        print("Loaded model from disk")
    else:
        #create model
        model = Sequential()

        #add model layers
        model.add(Conv2D(64, kernel_size=7, activation='relu', input_shape=(150, 150, 3)))
        model.add(MaxPooling2D(pool_size=(5, 5)))
        model.add(Conv2D(32, kernel_size=7, activation='relu'))
        model.add(MaxPooling2D(pool_size=(5, 5)))
        model.add(Flatten())
        model.add(Dense(128))
        model.add(Dense(2, activation='softmax'))

        print("new model created")

    model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    model.fit(X_train[:5000], y_train[:5000],validation_data=(X_test, y_test), epochs=10)
    model.fit(X_train, y_train,validation_data=(X_test, y_test), epochs=30)

    # save automatically
    # serialize model to JSON
    model_json = model.to_json()
    with open("/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/cnn_model2.json", "w") as json_file:
        json_file.write(model_json)
    # serialize weights to HDF5
    model.save_weights("/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/cnn_model2.h5")
    print("Saved model to disk")

def cnn_predicting(data = None):
    if data is None:
        data = fetch_image(int(time.time()), "snow")
    # load json and create model
    json_file = open('/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/cnn_model2.json', 'r')
    loaded_model_json = json_file.read()
    json_file.close()
    model = model_from_json(loaded_model_json)
    # load weights into new model
    model.load_weights("/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/cache/cnn_model2.h5")
    print("Loaded model from disk")
   
    model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    res = model.predict_classes(data)
    return res
