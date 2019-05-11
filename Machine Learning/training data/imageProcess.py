import os
from PIL import Image

cnt = 0

for absTime in range(24):
    for weatherType in ["snow"]:
        directory = f"raw image data/{absTime}/{weatherType}"
        print(f"starting processing on images in {directory}")
        for filename in os.listdir(directory):
            if cnt%100 == 0:
                print(f"successfully processed {cnt} images.")
            if filename.endswith(".jpg"):
                try:
                    destination = directory+"/"+filename
                    imageObject = Image.open(destination)
                    cropped = imageObject.crop((300,100,450,250))
                    cropped.convert('RGB').save(f"processed image data/{weatherType}/{filename}")
                    cnt += 1
                except:
                    print(f"failed in processing {destination}")


print(f"totally processed {cnt} images.")
