require "json"
require "http"
require "pry"

API_HOST = "https://api.yelp.com"
SEARCH_PATH = "/v3/businesses/search"
BUSINESS_PATH = "/v3/businesses/"  # trailing / because we append the business id to the path
API_KEY = ENV["API_KEY"]
DEFAULT_BUSINESS_ID = "yelp-san-francisco"
DEFAULT_TERM = "dinner"
DEFAULT_LOCATION = "New York, NY"
SEARCH_LIMIT = 3

class YelpApiAdapter
  #Returns a parsed json object of the request





  def self.search(term, location="new york")
    url = "#{API_HOST}#{SEARCH_PATH}"
    params = {
      term: term,
      location: location,
      limit: SEARCH_LIMIT
    }
    response = HTTP.auth("Bearer #{API_KEY}").get(url, params: params)
    response.parse["businesses"]
  end


  def self.business_reviews(business_id)
    url = "#{API_HOST}#{BUSINESS_PATH}#{business_id}/reviews"
    response = HTTP.auth("Bearer #{API_KEY}").get(url)
    response.parse["reviews"]
  end

  def business(business_id)
    url = "#{API_HOST}#{BUSINESS_PATH}#{business_id}"
    response = HTTP.auth("Bearer #{API_KEY}").get(url)
    response.parse
  end

end

# https://www.shakeshack.com/locations/
# states = [
#   'AK', 'AL', 'AR', 'AZ',
#   'CA', 'CO', 'CT',
#   'DC', 'DE',
#   'FL',
#   'GA',
#   'HI',
#   'IA', 'ID', 'IL', 'IN',
#   'KS', 'KY',
#   'LA',
#   'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS', 'MT',
#   'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY',
#   'OH', 'OK', 'OR',
#   'PA',
#   'RI',
#   'SC', 'SD',
#   'TN', 'TX',
#   'UT',
#   'VA', 'VT',
#   'WA', 'WI', 'WV', 'WY'
# ]
# @all_shake_shacks = states.map { |state| YelpApiAdapter.search("Shake Shack", state) }.flatten.select { |rest| rest["name"] == "Shake Shack" }
# above method returns restaurants with only shake shack. Every other states work, but New York.
# this is just for the future reference. Instead of API => CLI, would be better(?) to do API => Instance => CLI.

# binding.pry
