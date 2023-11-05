using HTTP
using JSON

url = "https://api.foursquare.com/v3/places/search"

headers = Dict(
    "accept" => "application/json",
    "Authorization" => "fsq3JXQp3TUcZCZIWwPZouBNth41zAGSm5IzTDVJYe9rptg="
)

# Define the parameters for your search
params = Dict(
    "ll" => "40.7128,-74.0060",  # Example latitude and longitude (New York City)
    "query" => "restaurant",     # Example search query
    "categoryId" => "19057"  # Example category ID for "Food"
)

response = HTTP.get(url, headers=headers, query=params)
data = JSON.parse(String(response.body))
results = data["results"]  # Access the results array

for venue in results
    println(venue)
    name = get(venue, "name", "N/A")
    distance = get(venue, "distance", "N/A")
    
    location = get(venue, "formatted address", Dict())

    main_geocode = get(venue, "geocodes", Dict())
    main_geocode = get(main_geocode, "main", Dict())
    lat = get(main_geocode, "latitude", "N/A")
    long = get(main_geocode, "longitude", "N/A")

end