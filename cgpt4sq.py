import requests
import json

url = "https://api.foursquare.com/v3/places/search"

headers = {
    "accept": "application/json",
    "Authorization": "fsq3JXQp3TUcZCZIWwPZouBNth41zAGSm5IzTDVJYe9rptg="
}

# Define the parameters for your search
params = {
    "ll": "40.7128,-74.0060",  # Example latitude and longitude (New York City)
    "query": "restaurant",  # Example search query
    "categoryId": "19057"
}

response = requests.get(url, headers=headers, params=params)
data = json.loads(response.text)

print(data)