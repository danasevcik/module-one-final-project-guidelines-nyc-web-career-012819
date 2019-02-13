require 'pry'
require 'colorize'
require 'colorized_string'
require_relative '../config/environment'
require_relative '../lib/save.rb'
require_relative '../lib/ss.rb'
require_relative '../lib/user.rb'
require_relative '../lib/yelp_api_adapter.rb'
require_relative '../lib/cli.rb'

# Notes for tomorrow
# create number menu for restaurants by city
# delete one of the saved restaurants


def greeting
  #welcome greeting
  main_greeting
  what_is_your_name
  user_name = gets.chomp
  has_user_been_here(user_name)
end


def has_user_been_here(user_name)
  #check if user has been here
  #if they have, welcome back
  #if not, create user
  if User.find_by(name: user_name)
    old_user_greeting
    old_user_menu(user_name)
  else
    new_user_greeting
    new_user_menu(user_name)
  end
end


def old_user_menu(user_name)
  #user can choose if they want to:
  #1. see saved shake shacks
  #2. find a new shake shack
  #3. delete account
  #4. exit app
  old_user_menu_print
  input = gets.chomp
  # binding.pry
  @user = User.find_by(name: user_name)
  if input == "1" && (Save.where(user_id: @user.id).count > 0)
    @my_saves = Save.where(user_id: @user.id)
    your_shake_shacks
    puts print_my_restaurants
    do_you_want_to_select
    old_user_menu(user_name)
  elsif input == "1" && (Save.where(user_id: @user.id).count <= 0)
    puts "#{user_name}, you don't have any saved Shake Shacks yet."
    old_user_menu(user_name)
  elsif input == "2"
    puts "Please enter a zip code:".colorize(:green)
    get_zip_code
  elsif input == "3"
    do_you_want_to_exit
  elsif input == "4"
    goodbye
    exit!
  else
    puts "Please enter 1, 2, 3, or 4!".colorize(:green)
    old_user_menu(user_name)
  end
end

def do_you_want_to_select
  #ask user if they want to choose a restaurant from their favorites
  select_from_favorites
  yes_or_no = gets.chomp
  if yes_or_no == "y"
    want_to_select
  elsif yes_or_no == "n"
    old_user_menu(@user.name)
  else
    please_enter_y_or_n
    old_user_menu(@user.name)
  end
 end

 def want_to_select
   #choose which shake shack to save
   number_version_of_print_my_restaurants
   select_which_number
   number_response = gets.chomp
   if @chosen_restuarant = number_version_of_print_my_restaurants[number_response.to_i - 1]
     @yelp_chosen_restaurant = YelpApiAdapter.search("Shake Shack", @chosen_restuarant)
     @yelp_chosen_restaurant.each do |single_rest|
       if single_rest["alias"] == @chosen_restuarant
         puts "
         Name: #{single_rest["alias"]}
         URL: https://www.yelp.com/biz/#{single_rest["alias"]}
         Rating: #{single_rest["rating"]}
         Address: #{single_rest["location"]["display_address"]}
         Phone Number: #{single_rest["phone"]}
         "
         if single_rest["is_closed"] == false
           this_shake_shack_is_open
           old_user_menu(@user.name)
         elsif single_rest["is_closed"] == true
           this_shake_shack_is_closed
           old_user_menu(@user.name)
         end
       end
     end
   else
     puts "


     Please enter a valid number.".colorize(:green)
     want_to_select
   end
 end

def print_my_restaurants
  #print a user's saved restaurants
  @my_saves_mapped = @my_saves.map do |save|
    # binding.pry
    Ss.find(save.ss_id).name
  end
end

def number_version_of_print_my_restaurants
  #print a user's saved restaurants with numbers (1. , 2. , 3. ...)
  count = 0
  @my_saves_mapped.each do |restaurant_name|
    puts "#{count+1}: #{restaurant_name}"
    count += 1
  end
end

def new_user_menu(user_name)
  #create new user
  @user = User.create(name: user_name)
  help_find_ss
  ask_for_zip_code
  get_zip_code
end

def do_you_want_to_exit
  #ask if user wants to delete account
  really?
  answer = gets.chomp
  if answer == "y"
    really_really?
    final_answer = gets.chomp
    if final_answer == "y"
      User.where(name: @user.name).delete_all
      goodbye
      exit!
    elsif  final_answer == "n"
      knew_it
      old_user_menu(@user)
    end
  elsif answer == "n"
    knew_it
    old_user_menu(@user)
  else
    puts "valid input please".colorize(:green)
    old_user_menu(@user)
  end
end

def get_zip_code
  #get a user input zip code
  zip_code = gets.chomp
  get_ss_from_zip_code(zip_code)
end

def get_ss_from_zip_code(zip_code)
  #find one shake shack in the zip code entered
  closest_ss = YelpApiAdapter.search("Shake Shack", zip_code).first
  if closest_ss["location"]["zip_code"] == zip_code
    puts "
    Your closest Shake Shack:

    Name: #{closest_ss["alias"]}
    URL: https://www.yelp.com/biz/#{closest_ss["alias"]}
    Rating: #{closest_ss["rating"]}
    Address: #{closest_ss["location"]["display_address"]}
    Phone Number: #{closest_ss["phone"]}
    "
    @restaurant = Ss.create(name: "#{closest_ss["alias"]}")
    # binding.pry
    do_you_want_to_save_by_zip
  elsif closest_ss["location"]["zip_code"] != zip_code
    puts "
    There are no Shake Shacks in your zip code.
    Please enter your city name:
    ".colorize(:green)
    # city_name = gets.chomp
    get_ss_from_city
  end
end

def get_ss_from_city
  #get 3 shake shacks from city entered
  city_name = gets.chomp
  if city_name == "new york" || "New York" || "manhattan" || "Manhattan"
    new_york_version(city_name)
  end
  closest_city_ss = YelpApiAdapter.search("Shake Shack", city_name)
# binding.pry
  if closest_city_ss.first["location"]["city"] == city_name.split.map(&:capitalize).join(' ')
    puts "Your 3 closest Shake Shacks:".colorize(:green)
    closest_city_ss.each do |each_shake_shack|
      puts "
      Name:         #{each_shake_shack["alias"]}
      URL:          https://www.yelp.com/biz/#{each_shake_shack["alias"]}
      Rating:       #{each_shake_shack["rating"]}
      Address:      #{each_shake_shack["location"]["display_address"]}
      Phone Number: #{each_shake_shack["phone"]}
      ".colorize(:green)
      Ss.create(name: "#{each_shake_shack["alias"]}")
    end
    do_you_want_to_save_by_city
  elsif closest_city_ss.first["location"]["city"] != city_name.split.map(&:capitalize).join(' ')
    puts "
    There are no Shake Shacks in your city.
    You should probably move.
    ".colorize(:green)
    exit
  end
end

def new_york_version(city_name)
  #get 3 shake shacks from city entered if its new york or manhattan
  new_york_ss = YelpApiAdapter.search("Shake Shack", city_name)
  puts "3 Shake Shacks near you:".colorize(:green)
  new_york_ss.each do |each_shake_shack|
    puts "
    Name:         #{each_shake_shack["alias"]}
    URL:          https://www.yelp.com/biz/#{each_shake_shack["alias"]}
    Rating:       #{each_shake_shack["rating"]}
    Address:      #{each_shake_shack["location"]["display_address"]}
    Phone Number: #{each_shake_shack["phone"]}
    ".colorize(:green)
    Ss.create(name: "#{each_shake_shack["alias"]}")
  end
  do_you_want_to_save_by_city
end

def do_you_want_to_save_by_city
  #ask user if they want to save a shake shack based on city entry
  do_you_want_to_save_c
  user_input = gets.chomp
  if user_input == 'y'
    which_one
    # Please select one of the following by number
    # print_options_and_please_select_by_number
    restaurant_name_response = gets.chomp
    if !Ss.find_by(name: "#{restaurant_name_response}")
      puts "Please enter one of the three Shake Shack names.".colorize(:green)
      do_you_want_to_save_by_city
    else
      @restaurant_to_save = Ss.find_by(name: "#{restaurant_name_response}")
      if !Save.find_by(user_id: @user.id, ss_id: @restaurant_to_save.id)
        Save.create(user_id: @user.id, ss_id: @restaurant_to_save.id)
        puts "Saved!"
        old_user_menu(@user.name)
      else
        puts "That Shake Shack is already in your favorites!".colorize(:green)
        old_user_menu(@user.name)
      end
    end
  elsif user_input == 'n'
    old_user_menu(@user.name)
  else
    puts "Please enter y or n".colorize(:green)
    do_you_want_to_save_by_city
  end

end


def do_you_want_to_save_by_zip
  #ask user if they want to save a shake shack based on zip code entry
  do_you_want_to_save
  user_input = gets.chomp
  # binding.pry
  if user_input == 'y'
    # binding.pry
    Save.create(user_id: @user.id, ss_id: @restaurant.id)
    old_user_menu(@user.name)
    puts "Saved!"
  elsif user_input == 'n'
    old_user_menu(@user.name)
  end
end

# binding.pry
puts "0"
