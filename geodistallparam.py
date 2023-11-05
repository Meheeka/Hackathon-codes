

import urllib3
import re

print("give the number of places")
n=int(input())

latitude=[]
longitude=[]
place=[]
http = urllib3.PoolManager()
for i in range(n):
    print("give the place")
    place.append(input())
    tempplace=place[i].replace(' ','+')

    print(tempplace)
    url="https://api.distancematrix.ai/maps/api/geocode/json?address=" + tempplace +"&key=jPj9KEXFhk72jG8L0L0qmDpOxIIDzaQEVmgaJ6NOIFK9WxaxKzwAT2ozta5U1lJ0"
    
    resp = http.request('GET', url)

    print(resp.data)

    data=resp.data
    data= data.decode('utf-8')

    lat=re.search(r'"lat":([-+]?\d*\.\d+)',data)
    long=re.search(r'"lng":([-+]?\d*\.\d+)',data)

    latitude.append(lat.group(1))
    longitude.append(long.group(1))

distmatrix=[[[0,0,0] for col in range(n)] for row in range(n)]#2 is for dist aand time

print(latitude,longitude)
for t in range(n):
    for d in range(n):

        url2="https://api.distancematrix.ai/maps/api/distancematrix/json?origins="+latitude[t] + ","+ longitude[t]+"&destinations="+latitude[d] + ","+ longitude[d]+"&mode=driving&departure_time=now&key=jPj9KEXFhk72jG8L0L0qmDpOxIIDzaQEVmgaJ6NOIFK9WxaxKzwAT2ozta5U1lJ0"
        resp2 = http.request('GET', url2)               #t is origin.., d index for destination so adj matrix rowsindices are origins, 
        
        data2=resp2.data
        data2=data2.decode('utf-8')
        print(data2,"\n")

        dist=re.search(r'"distance":{"text":"(\d+\.*\d*) km"',data2)#metre
        trafftime=re.search(r'"duration_in_traffic":{"text":"((\d+) day )?((\d+) hour )?((\d+) mins)"',data2)
        normtime=re.search(r'"duration":{"text":"((\d+) day )?((\d+) hour )?((\d+) mins)"',data2)

        print(t,d,"\n")
        if dist:
            distmatrix[t][d][0]=float(dist.group(1))

            day = int(trafftime.group(2)) if trafftime.group(2) else 0
            hour = int(trafftime.group(4)) if trafftime.group(4) else 0
            minute = int(trafftime.group(6))
            trafft=(day*1440) + (hour* 60) + minute            ##this block enters time in traffic to distmatrix[-][-][1]
            distmatrix[t][d][1]=trafft

            day2 = int(normtime.group(2)) if normtime.group(2) else 0
            hour2 = int(normtime.group(4)) if normtime.group(4) else 0
            minute2 = int(normtime.group(6))
            normt=(day2*1440) + (hour2* 60) + minute2         ##this block enters time without traffic to distmatrix[-][-][2]
            distmatrix[t][d][2]=normt
        else:
            distmatrix[t][d][0]=0
            distmatrix[t][d][1]=0
            distmatrix[t][d][2]=0
print(distmatrix)
epsilon=30
count=0
flag=0
for i in range(n):
    for j in range(n):
        if distmatrix[i][j][1]-distmatrix[i][j][2]>=epsilon: # traffic time - normal time exceeds limit
            count+=1
print("count=",count)
if count>=(((n*n)-n)/2):
    flag=1  # indicates we should use time matrix
print(flag)