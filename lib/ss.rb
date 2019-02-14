class Ss < ActiveRecord::Base

  has_many :saves
  has_many :users, through: :saves

end
# @all_shake_shacks.each do |hash|
#     Ss.create(name: "Shake Shack", alias: hash["alias"], url: "https://www.yelp.com/biz/#{hash["alias"]}", review_count: hash["review_count"], rating: hash["rating"], city: hash["location"]["city"], zip_code: hash["location"]["zip_code"], state: hash["location"]["state"], display_address: "#{hash["location"]["display_address"].join}", phone: hash["phone"])
# end
