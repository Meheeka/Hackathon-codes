using HTTP
using JSON

println("Give the number of places:")
n = parse(Int, readline())

latitude = Vector{String}(undef, n)
longitude = Vector{String}(undef, n)
place = Vector{String}(undef, n)
http = HTTP.Pool()
for i in 1:n
    println("Give the place:")
    place[i] = readline()
    tempplace = replace(place[i], ' ' => '+')
    println(tempplace)

    url = "https://api.distancematrix.ai/maps/api/geocode/json?address=$tempplace&key=jPj9KEXFhk72jG8L0L0qmDpOxIIDzaQEVmgaJ6NOIFK9WxaxKzwAT2ozta5U1lJ0"
    response = HTTP.get(url)
    data = String(response.body)
    println(data)

    lat_match = match(r"\"lat\":([-+]?\d*\.\d+)", data)
    long_match = match(r"\"lng\":([-+]?\d*\.\d+)", data)

    latitude[i] = lat_match.match
    longitude[i] = long_match.match
end

distmatrix = [[[0.0, 0, 0] for col in 1:n] for row in 1:n]  # 2 is for distance and time

for t in 1:n
    for d in 1:n
        url2 = "https://api.distancematrix.ai/maps/api/distancematrix/json?origins=$(latitude[t]),$(longitude[t])&destinations=$(latitude[d]),$(longitude[d])&mode=driving&departure_time=now&key=jPj9KEXFhk72jG8L0L0qmDpOxIIDzaQEVmgaJ6NOIFK9WxaxKzwAT2ozta5U1lJ0"
        resp2 = HTTP.get(url2)  # t is origin, d index for the destination, so adj matrix rows indices are origins

        data2 = String(resp2.body)
        println(data2, "\n")

        dist_match = match(r"\"distance\":{\"text\":\"(\d+\.*\d*) km\"", data2)  # meter
        trafftime_match = match(r"\"duration_in_traffic\":{\"text\":\"((\d+) day )?((\d+) hour )?((\d+) mins)\"", data2)
        normtime_match = match(r"\"duration\":{\"text\":\"((\d+) day )?((\d+) hour )?((\d+) mins)\"", data2)

        println(t, d, "\n")

        if dist_match!==nothing
            distmatrix[t][d][1] = parse(Float64, dist_match.match)

            day = get(trafftime_match.captures, 2, 0)
            hour = get(trafftime_match.captures, 4, 0)
            minute = parse(Int, get(trafftime_match.captures, 6, 0))
            trafft = day * 1440 + hour * 60 + minute  # this block enters time in traffic to distmatrix[-][-][2]
            distmatrix[t][d][2] = trafft

            day2 = get(normtime_match.captures, 2, 0)
            hour2 = get(normtime_match.captures, 4, 0)
            minute2 = parse(Int, get(normtime_match.captures, 6, 0))
            normt = day2 * 1440 + hour2 * 60 + minute2  # this block enters time without traffic to distmatrix[-][-][3]
            distmatrix[t][d][3] = normt
        else
            distmatrix[t][d][1] = 0.0
            distmatrix[t][d][2] = 0
            distmatrix[t][d][3] = 0
        end
    end
end
print(distmatrix)
epsilon = 30
count = 0
flag = 0

for i in 1:n
    for j in 1:n
        if distmatrix[i][j][2] - distmatrix[i][j][3] >= epsilon
            count += 1
        end
    end
end

println("Count = %d\n", count)
if count >= (n * (n - 1) )/ 2
    flag = 1  # indicates we should use the time matrix
end

println("Flag = %d\n", flag)

