import requests
from bs4 import BeautifulSoup
import urllib.request 
import time
from datetime import datetime
import queue
import threading




class Whether:

    date_queue = queue.Queue()
    session = requests.session()
    success = 0
    fetch_image_threads = []
    target = 'snow'
    exceptions = []

    def __init__(self, start, end, target):
        self.target = target
        start = datetime.strptime(start, '%b %d %Y %H:%M')
        end = datetime.strptime(end, '%b %d %Y %H:%M')
        start = datetime.timestamp(start)
        end = datetime.timestamp(end)
        while start <= end:
            self.date_queue.put(start)
            start += 60*60*24

    def fetch_image(self, timestamp, target):
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
            response = self.session.get('http://climate.weather.gc.ca/radar/index_e.html', params=params)
            html = BeautifulSoup(response.content, 'html.parser')
            image_url = html.body.main.span.img['src']
            image_base = 'http://climate.weather.gc.ca'
            urllib.request.urlretrieve(image_base+image_url, f'past radar/{date.hour}/{target}/{str(int(timestamp))}.jpg')
            print('finish {}'.format(target)+date.strftime(' at %Y-%m-%d %H:%M'))
        except:
            print("ERROR: {}".format(str(int(timestamp))))
            self.exceptions.append(str(int(timestamp)))

        # self.success += 1
        # if self.success%100 == 0:
        #     print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), end=': ')
        #     # print('finish '+str(self.success))

    def start(self, thread_num):
        for i in range(0,thread_num):
            thread = threading.Thread(target=self.fetch_image_thread)
            self.fetch_image_threads.append(thread)
            thread.start()
        for thread in self.fetch_image_threads:
            thread.join()

    def fetch_image_thread(self):
        while self.date_queue.qsize() > 0:
            self.fetch_image(self.date_queue.get(), self.target)


for x in range(24):
    x = str(x)
    target = 'rain'
    begin = f'JAN 1 2017  {x}:00'
    end = f'JAN 1 2019  {x}:00'



    whether = Whether(begin, end, target)
    whether.start(32)
    print("********************************************************** EXCEPTIONS **********************************************************")
    print(whether.exceptions)


    dest = f"past radar/{x}/{target}/exceptions.txt"
    f = open(dest, "w")
    for i in whether.exceptions:
        f.write(i+"\n")

for x in range(24):
    x = str(x)
    target = 'snow'
    begin = f'JAN 1 2017  {x}:00'
    end = f'JAN 1 2019  {x}:00'



    whether = Whether(begin, end, target)
    whether.start(32)
    print("********************************************************** EXCEPTIONS **********************************************************")
    print(whether.exceptions)


    dest = f"past radar/{x}/{target}/exceptions.txt"
    f = open(dest, "w")
    for i in whether.exceptions:
        f.write(i+"\n")