import os
from pytube import YouTube
path="/Users/hpourzand/Dropbox/contracts/C18/LAN/LAN-Workshops/LAN2018Nov06"
os.chdir(path)
print("Current Working Directory " , os.getcwd())
with open("url.list") as listfile:
    for item in listfile:
        YouTube(item).streams.first().download()
        print(item)


YouTube(item).description
YouTube(item).length
YouTube(item).rating
YouTube(item).thumbnail_url
YouTube(item).title
YouTube(item).streams.first().filesize
