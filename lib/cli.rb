require 'pry'
require 'colorize'
require 'colorized_string'

# Notes for tomorrow
# delete one of the saved restaurants
# fix the "Lets Go" after restaurant is open


def greeting # METHOD 1
  #welcome greeting and ask for name
  main_greeting #art 1
  what_is_your_name #art 2
  user_name = gets.chomp
  has_user_been_here(user_name) # => method 2
end


def has_user_been_here(user_name) # METHOD 2
  #check if user has been here
  #if they have, welcome back
  #if not, create user
  if User.find_by(name: user_name)
    old_user_greeting #art 3
    old_user_menu(user_name) # => method 3
  else
    new_user_greeting #art 4
    new_user_menu(user_name) # => method 4
  end
end

def old_user_menu(user_name) # METHOD 3
  #user can choose if they want to:
  #1. see saved shake shacks
  #2. find a new shake shack
  #3. delete account
  #4. exit app
  old_user_menu_print #art 5
  input = gets.chomp
  @user = User.find_by(name: user_name)
  if input == "1" && (Save.where(user_id: @user.id).count > 0)
    #check if user has any saves
    @my_saves = Save.where(user_id: @user.id)
    your_shake_shacks #art 6
    puts print_my_restaurants # => puts method 5
    do_you_want_to_select # => method 6
    old_user_menu(user_name) # call this method again
  elsif input == "1" && (Save.where(user_id: @user.id).count <= 0)
    # if user doesn't have saves
    puts "#{user_name}, you don't have any saved Shake Shacks yet."
    old_user_menu(user_name) # call this method again
  elsif input == "2"
    puts "Please enter a zip code:".colorize(:green)
    get_zip_code # => method 7
  elsif input == "3"
    do_you_want_to_exit # => method 13
  elsif input == "4"
    goodbye #art
    exit! # terminal command
  else
    puts "Please enter 1, 2, 3, or 4!".colorize(:green)
    old_user_menu(user_name) # => method 3
  end
end

def new_user_menu(user_name) # METHOD 4
  #create new user
  @user = User.create(name: user_name)
  help_find_ss #art 20
  ask_for_zip_code #art 21
  get_zip_code # => method 7
end

def print_my_restaurants # METHOD 5
  #print a user's saved restaurants
  @my_saves_mapped = @my_saves.map do |save|
    Ss.find(save.ss_id).name
  end
end

def do_you_want_to_select # METHOD 6
  #ask user if they want to choose a restaurant from their favorites
  select_from_favorites #art 7
  yes_or_no = gets.chomp
  if yes_or_no == "y"
    want_to_select # => method 9, choose which shake shack to save
  elsif yes_or_no == "n"
    old_user_menu(@user.name) # => method 3
  else
    please_enter_y_or_n #art 8
    old_user_menu(@user.name) # => method 3
  end
end

def get_zip_code # METHOD 7
  #get a user input zip code
  zip_code = gets.chomp
  get_ss_from_zip_code(zip_code) # => method 8
end

def get_ss_from_zip_code(zip_code) # METHOD 8
  #find one shake shack in the zip code entered
  closest_ss = YelpApiAdapter.search("Shake Shack", zip_code).first
  if closest_ss["location"]["zip_code"] == zip_code
    puts "
    Your closest Shake Shack:

    Name:         #{closest_ss["alias"]}
    URL:          https://www.yelp.com/biz/#{closest_ss["alias"]}
    Rating:       #{closest_ss["rating"]}
    Address:      #{closest_ss["location"]["display_address"]}
    Phone Number: #{closest_ss["phone"]}
    "
    @restaurant = Ss.create(name: "#{closest_ss["alias"]}")
    do_you_want_to_save_by_zip # => method 11
  elsif closest_ss["location"]["zip_code"] != zip_code
    puts "
    There are no Shake Shacks in your zip code.
    Please enter your city name:
    ".colorize(:green)
    get_ss_from_city # => method 12
  end
end

def want_to_select # METHOD 9
  #choose which shake shack to save
  number_version_of_print_my_restaurants # => method 10
  select_which_number #art 9
  number_response = gets.chomp
  if @chosen_restuarant = number_version_of_print_my_restaurants[number_response.to_i - 1]
    @yelp_chosen_restaurant = YelpApiAdapter.search("Shake Shack", @chosen_restuarant)
    @yelp_chosen_restaurant.each do |single_rest|
      if single_rest["alias"] == @chosen_restuarant
        puts "
        Name:         #{single_rest["alias"]}
        URL:          https://www.yelp.com/biz/#{single_rest["alias"]}
        Rating:       #{single_rest["rating"]}
        Address:      #{single_rest["location"]["display_address"]}
        Phone Number: #{single_rest["phone"]}
        "
        if single_rest["is_closed"] == false
          this_shake_shack_is_open #art 10
          scroll_text # art  23
          old_user_menu(@user.name) # => method 3
        elsif single_rest["is_closed"] == true
          this_shake_shack_is_closed #art 11
          old_user_menu(@user.name) # => method 3
        end
      end
    end
  else
    puts "


    Please enter a valid number.".colorize(:green)
    want_to_select # => method 9, choose which shake shack to save
  end
end

def number_version_of_print_my_restaurants # METHOD 10
  #print a user's saved restaurants with numbers (1. , 2. , 3. ...)
  count = 0
  @my_saves_mapped.each do |restaurant_name|
    puts "#{count+1}: #{restaurant_name}"
    count += 1
  end
end

def do_you_want_to_save_by_zip # METHOD 11
  #ask user if they want to save a shake shack based on zip code entry
  do_you_want_to_save #art 12
  user_input = gets.chomp
  if user_input == 'y'
    Save.create(user_id: @user.id, ss_id: @restaurant.id)
    puts "Saved!"
    old_user_menu(@user.name) # => method 3
  elsif user_input == 'n'
    old_user_menu(@user.name) # => method 3
  end
end

def get_ss_from_city # METHOD 12
  #get 3 shake shacks from city entered
  city_name = gets.chomp
  # binding.pry
  if city_name == "new york" || "New York" || "manhattan" || "Manhattan"
    # binding.pry
    new_york_version(city_name) # => method 14
  end
  closest_city_ss = YelpApiAdapter.search("Shake Shack", city_name)
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
    do_you_want_to_save_by_city # => method 15
  elsif closest_city_ss.first["location"]["city"] != city_name.split.map(&:capitalize).join(' ')
    puts "
    There are no Shake Shacks in your city.
    You should probably move.
    ".colorize(:green)
    exit #art 19
  end
end

def do_you_want_to_exit # METHOD 13
  #ask if user wants to delete account
  really? #art 13
  answer = gets.chomp
  if answer == "y"
    really_really? #art 14
    final_answer = gets.chomp
    if final_answer == "y"
      User.where(name: @user.name).delete_all
      goodbye #art 15
      exit!
    elsif  final_answer == "n"
      knew_it # art 16
      old_user_menu(@user) # => method 3
    end
  elsif answer == "n"
    knew_it # art 16
    old_user_menu(@user) # => method 3
  else
    puts "valid input please".colorize(:green)
    old_user_menu(@user) # => method 3
  end
end

def new_york_version(city_name) # METHOD 14
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
  do_you_want_to_save_by_city # => method 15
end

def do_you_want_to_save_by_city # METHOD 15
  #ask user if they want to save a shake shack based on city entry
  do_you_want_to_save_c #art 17
  user_input = gets.chomp
  if user_input == 'y'
    which_one # art 18
    restaurant_name_response = gets.chomp
    if !Ss.find_by(name: "#{restaurant_name_response}")
      puts "Please enter one of the three Shake Shack names.".colorize(:green)
      do_you_want_to_save_by_city # calling this method
    else
      @restaurant_to_save = Ss.find_by(name: "#{restaurant_name_response}")
      if !Save.find_by(user_id: @user.id, ss_id: @restaurant_to_save.id)
        Save.create(user_id: @user.id, ss_id: @restaurant_to_save.id)
        puts "Saved!"
        old_user_menu(@user.name) # => method 3
      else
        puts "That Shake Shack is already in your favorites!".colorize(:green)
        old_user_menu(@user.name) # => method 3
      end
    end
  elsif user_input == 'n'
    old_user_menu(@user.name) # => method 3
  else
    puts "Please enter y or n".colorize(:green)
    do_you_want_to_save_by_city #calling this method
  end
end



# binding.pry
puts "0"
