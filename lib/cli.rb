require 'pry'
require_relative '../config/environment'
require_relative '../lib/save.rb'
require_relative '../lib/ss.rb'
require_relative '../lib/user.rb'
require_relative '../lib/yelp_api_adapter.rb'
require_relative '../lib/cli.rb'

# Notes for tomorrow
# tty prompt
# select from saved
# favorite features
# check if a person can save a single SS more than once


def greeting
  main_greeting
  what_is_your_name
  user_name = gets.chomp
  has_user_been_here(user_name)
end


def has_user_been_here(user_name)
  if User.find_by(name: user_name)
    old_user_greeting
    old_user_menu(user_name)
  else
    new_user_greeting
    new_user_menu(user_name)
  end
end


def old_user_menu(user_name)
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
    puts "Please enter a zip code:"
    get_zip_code
  elsif input == "3"
    do_you_want_to_exit
  elsif input == "4"
    goodbye
    exit!
  else
    puts "Please enter 1, 2, 3, or 4!"
    old_user_menu(user_name)
  end
end

def do_you_want_to_select
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
   number_version_of_print_my_restaurants
   select_which_number
   number_response = gets.chomp
   if @chosen_restuarant = number_version_of_print_my_restaurants[number_response.to_i - 1]
     @yelp_chosen_restaurant = YelpApiAdapter.search("Shake Shack", @chosen_restuarant)
     @yelp_chosen_restaurant.find do |single_rest|
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
         end
       else
         trouble_connecting
         old_user_menu(@user.name)
       end
     end
   else
     puts "


     Please enter a valid number."
     want_to_select
   end
 end

def print_my_restaurants
  @my_saves_mapped = @my_saves.map do |save|
    # binding.pry
    Ss.find(save.ss_id).name
  end
end

def number_version_of_print_my_restaurants
  count = 0
  @my_saves_mapped.each do |restaurant_name|
    puts "#{count+1}: #{restaurant_name}"
    count += 1
  end
end

def new_user_menu(user_name)
  @user = User.create(name: user_name)
  help_find_ss
  ask_for_zip_code
  get_zip_code
end

def do_you_want_to_exit
  really?
  answer = gets.chomp
  if answer == "y"
    really_really?
    final_answer = gets.chomp
    if final_answer == "y"
      User.where(name:  @user.name).delete_all
      goodbye
      exit!
    elsif  final_answer == "n"
      knew_it
      old_user_menu(user_name)
    end
  elsif answer == "n"
    knew_it
    old_user_menu(user_name)
  else
    puts "valid input please"
    old_user_menu(user_name)
  end
end

def get_zip_code
  zip_code = gets.chomp
  get_ss_from_zip_code(zip_code)
end

def get_ss_from_zip_code(zip_code)

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
    "
    # city_name = gets.chomp
    get_ss_from_city
  end
end

def get_ss_from_city
  city_name = gets.chomp
  closest_city_ss = YelpApiAdapter.search("Shake Shack", city_name)
# binding.pry
  if closest_city_ss.first["location"]["city"] == city_name.split.map(&:capitalize).join(' ')
    puts "Your 3 closest Shake Shacks:"
    closest_city_ss.each do |each_shake_shack|
      puts "
      Name: #{each_shake_shack["alias"]}
      URL: https://www.yelp.com/biz/#{each_shake_shack["alias"]}
      Rating: #{each_shake_shack["rating"]}
      Address: #{each_shake_shack["location"]["display_address"]}
      Phone Number: #{each_shake_shack["phone"]}
      "
      Ss.create(name: "#{each_shake_shack["alias"]}")
    end
    do_you_want_to_save_by_city
  elsif closest_city_ss.first["location"]["city"] != city_name.split.map(&:capitalize).join(' ')
    puts "
    There are no Shake Shacks in your city.
    You should probably move.
    "
    exit
  end
end

def do_you_want_to_save_by_city
  do_you_want_to_save_c
  user_input = gets.chomp
  if user_input == 'y'
    which_one
    restaurant_name_response = gets.chomp
    if !Ss.find_by(name: "#{restaurant_name_response}")
      puts "Please enter one of the three Shake Shack names."
      do_you_want_to_save_by_city
    else
      @restaurant_to_save = Ss.find_by(name: "#{restaurant_name_response}")
      Save.create(user_id: @user.id, ss_id: @restaurant_to_save.id)
      puts "Saved!"
      old_user_menu(@user.name)
    end
  elsif user_input == 'n'
    old_user_menu(@user.name)
  end
end

def do_you_want_to_save_by_zip
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










def which_one
  sleep(1)
  puts "
  ╦ ╦┬ ┬┬┌─┐┬ ┬  ┌─┐┌┐┌┌─┐┌─┐
  ║║║├─┤││  ├─┤  │ ││││├┤  ┌┘
  ╚╩╝┴ ┴┴└─┘┴ ┴  └─┘┘└┘└─┘ o

  "
  sleep(1)
  puts "Type the restaurant name"
  sleep(1)
end

def please_enter_y_or_n
  sleep(1)
  puts "


  ╔═╗┬  ┌─┐┌─┐┌─┐┌─┐  ┌─┐┌┐┌┌┬┐┌─┐┬─┐  ┬ ┬  ┌─┐┬─┐  ┌┐┌
  ╠═╝│  ├┤ ├─┤└─┐├┤   ├┤ │││ │ ├┤ ├┬┘  └┬┘  │ │├┬┘  │││
  ╩  ┴─┘└─┘┴ ┴└─┘└─┘  └─┘┘└┘ ┴ └─┘┴└─   ┴   └─┘┴└─  ┘└┘o


  "
  sleep(1)
end

def select_which_number
  sleep(1)
  puts "


  ╔═╗┌─┐┬  ┌─┐┌─┐┌┬┐  ┬ ┬┬ ┬┬┌─┐┬ ┬  ┌┐┌┬ ┬┌┬┐┌┐ ┌─┐┬─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─  ┬ ┬┌─┐┬ ┬┌┬┐  ┬  ┬┬┌─┌─┐  ┌┬┐┌─┐  ┬  ┬┬┌─┐┬ ┬
  ╚═╗├┤ │  ├┤ │   │   │││├─┤││  ├─┤  ││││ ││││├┴┐├┤ ├┬┘  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐  └┬┘│ ││ │ ││  │  │├┴┐├┤    │ │ │  └┐┌┘│├┤ │││
  ╚═╝└─┘┴─┘└─┘└─┘ ┴   └┴┘┴ ┴┴└─┘┴ ┴  ┘└┘└─┘┴ ┴└─┘└─┘┴└─  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴   ┴ └─┘└─┘─┴┘  ┴─┘┴┴ ┴└─┘   ┴ └─┘   └┘ ┴└─┘└┴┘o


  "
  sleep(1)
end

def trouble_connecting
  sleep(1)
  puts "


  ╔═╗┌─┐┬─┐┬─┐┬ ┬       ┬ ┬┌─┐  ┌─┐┬─┐┌─┐  ┬ ┬┌─┐┬  ┬┬┌┐┌┌─┐  ┌┬┐┬─┐┌─┐┬ ┬┌┐ ┬  ┌─┐  ┌─┐┌─┐┌┐┌┌┐┌┌─┐┌─┐┌┬┐┬┌┐┌┌─┐
  ╚═╗│ │├┬┘├┬┘└┬┘  ───  │││├┤   ├─┤├┬┘├┤   ├─┤├─┤└┐┌┘│││││ ┬   │ ├┬┘│ ││ │├┴┐│  ├┤   │  │ │││││││├┤ │   │ │││││ ┬
  ╚═╝└─┘┴└─┴└─ ┴        └┴┘└─┘  ┴ ┴┴└─└─┘  ┴ ┴┴ ┴ └┘ ┴┘└┘└─┘   ┴ ┴└─└─┘└─┘└─┘┴─┘└─┘  └─┘└─┘┘└┘┘└┘└─┘└─┘ ┴ ┴┘└┘└─┘
  ┌┬┐┌─┐  ┌┬┐┬ ┬┬┌─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─  ┬─┐┬┌─┐┬ ┬┌┬┐  ┌┐┌┌─┐┬ ┬
   │ │ │   │ ├─┤│└─┐  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐  ├┬┘││ ┬├─┤ │   ││││ ││││
   ┴ └─┘   ┴ ┴ ┴┴└─┘  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴  ┴└─┴└─┘┴ ┴ ┴   ┘└┘└─┘└┴┘o


  "
  sleep(1)
end

def do_you_want_to_save_c
  sleep(1)
  puts "

  ╔╦╗┌─┐  ┬ ┬┌─┐┬ ┬  ┬ ┬┌─┐┌┐┌┌┬┐  ┌┬┐┌─┐  ┌─┐┌─┐┬  ┬┌─┐  ┌─┐┌┐┌┌─┐┌─┐
   ║║│ │  └┬┘│ ││ │  │││├─┤│││ │    │ │ │  └─┐├─┤└┐┌┘├┤   │ ││││├┤  ┌┘
  ═╩╝└─┘   ┴ └─┘└─┘  └┴┘┴ ┴┘└┘ ┴    ┴ └─┘  └─┘┴ ┴ └┘ └─┘  └─┘┘└┘└─┘ o

  (y/n)
  "
  sleep(1)
end

def this_shake_shack_is_open
  sleep(1)
  puts "


  ╔╦╗┬ ┬┬┌─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─  ┬┌─┐  ┌─┐┬ ┬┬─┐┬─┐┌─┐┌┐┌┌┬┐┬ ┬ ┬  ┌─┐┌─┐┌─┐┌┐┌┬  ╦  ┌─┐┌┬┐┌─┐  ┌─┐┌─┐┬
   ║ ├─┤│└─┐  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐  │└─┐  │  │ │├┬┘├┬┘├┤ │││ │ │ └┬┘  │ │├─┘├┤ ││││  ║  ├┤  │ └─┐  │ ┬│ ││
   ╩ ┴ ┴┴└─┘  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴  ┴└─┘  └─┘└─┘┴└─┴└─└─┘┘└┘ ┴ ┴─┘┴   └─┘┴  └─┘┘└┘o  ╩═╝└─┘ ┴ └─┘  └─┘└─┘o

  "
  sleep(1)
end

def this_shake_shack_is_closed
  sleep(1)
  puts "


  ╔═╗┌─┐┬─┐┬─┐┬ ┬  ┌┬┐┬ ┬┬┌─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─  ┬┌─┐  ┌─┐┬ ┬┬─┐┬─┐┌─┐┌┐┌┌┬┐┬ ┬ ┬  ┌─┐┬  ┌─┐┌─┐┌─┐┌┬┐
  ╚═╗│ │├┬┘├┬┘└┬┘   │ ├─┤│└─┐  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐  │└─┐  │  │ │├┬┘├┬┘├┤ │││ │ │ └┬┘  │  │  │ │└─┐├┤  ││
  ╚═╝└─┘┴└─┴└─ ┴┘   ┴ ┴ ┴┴└─┘  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴  ┴└─┘  └─┘└─┘┴└─┴└─└─┘┘└┘ ┴ ┴─┘┴   └─┘┴─┘└─┘└─┘└─┘─┴┘o


  "
  sleep(1)
end

def knew_it
  sleep(1)
  puts "


  ╦  ┬┌─┌┐┌┌─┐┬ ┬  ┬ ┬┌─┐┬ ┬  ┌─┐┌─┐┬ ┬┬  ┌┬┐┌┐┌┌┬┐  ┬  ┌─┐┌─┐┬  ┬┌─┐  ┬ ┬┌─┐┬
  ║  ├┴┐│││├┤ │││  └┬┘│ ││ │  │  │ ││ ││   │││││ │   │  ├┤ ├─┤└┐┌┘├┤   │ │└─┐│
  ╩  ┴ ┴┘└┘└─┘└┴┘   ┴ └─┘└─┘  └─┘└─┘└─┘┴─┘─┴┘┘└┘ ┴   ┴─┘└─┘┴ ┴ └┘ └─┘  └─┘└─┘o


  "
  sleep(1)
end



def do_you_want_to_save
  sleep(1)
  puts "

╔╦╗┌─┐  ┬ ┬┌─┐┬ ┬  ┬ ┬┌─┐┌┐┌┌┬┐  ┌┬┐┌─┐  ┌─┐┌─┐┬  ┬┌─┐  ┌┬┐┬ ┬┬┌─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─┌─┐
 ║║│ │  └┬┘│ ││ │  │││├─┤│││ │    │ │ │  └─┐├─┤└┐┌┘├┤    │ ├─┤│└─┐  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐ ┌┘
═╩╝└─┘   ┴ └─┘└─┘  └┴┘┴ ┴┘└┘ ┴    ┴ └─┘  └─┘┴ ┴ └┘ └─┘   ┴ ┴ ┴┴└─┘  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴ o

(y/n)
  "
  sleep(1)
end

def select_from_favorites
  sleep(1)
  puts "


  ╦ ╦┌─┐┬ ┬┬  ┌┬┐  ┬ ┬┌─┐┬ ┬  ┬  ┬┬┌─┌─┐  ┌┬┐┌─┐  ┌─┐┌─┐┬  ┌─┐┌─┐┌┬┐  ┌─┐┬─┐┌─┐┌┬┐  ┌─┐┌─┐┬  ┬┌─┐┬─┐┬┌┬┐┌─┐┌─┐┌─┐
  ║║║│ ││ ││   ││  └┬┘│ ││ │  │  │├┴┐├┤    │ │ │  └─┐├┤ │  ├┤ │   │   ├┤ ├┬┘│ ││││  ├┤ ├─┤└┐┌┘│ │├┬┘│ │ ├┤ └─┐ ┌┘
  ╚╩╝└─┘└─┘┴─┘─┴┘   ┴ └─┘└─┘  ┴─┘┴┴ ┴└─┘   ┴ └─┘  └─┘└─┘┴─┘└─┘└─┘ ┴   └  ┴└─└─┘┴ ┴  └  ┴ ┴ └┘ └─┘┴└─┴ ┴ └─┘└─┘ o

(y/n)
  "
  sleep(1)
end

def exit
  sleep(1)
  puts "

╔═╗┌─┐┌┬┐┌─┐  ┌┐ ┌─┐┌─┐┬┌─  ┌┬┐┌─┐  ┬  ┬┬┌─┐┬┌┬┐  ┬ ┬┬ ┬┌─┐┌┐┌  ┬ ┬┌─┐┬ ┬  ┌┬┐┌─┐┬  ┬┌─┐  ┌─┐┬┌┬┐┬┌─┐┌─┐
║  │ ││││├┤   ├┴┐├─┤│  ├┴┐   │ │ │  └┐┌┘│└─┐│ │   │││├─┤├┤ │││  └┬┘│ ││ │  ││││ │└┐┌┘├┤   │  │ │ │├┤ └─┐
╚═╝└─┘┴ ┴└─┘  └─┘┴ ┴└─┘┴ ┴   ┴ └─┘   └┘ ┴└─┘┴ ┴   └┴┘┴ ┴└─┘┘└┘   ┴ └─┘└─┘  ┴ ┴└─┘ └┘ └─┘  └─┘┴ ┴ ┴└─┘└─┘

  "
  sleep(1)
end


def goodbye
  sleep(1)
  puts "


  ╔═╗┌─┐┌─┐┌┬┐┌┐ ┬ ┬┌─┐┬
  ║ ╦│ ││ │ ││├┴┐└┬┘├┤ │
  ╚═╝└─┘└─┘─┴┘└─┘ ┴ └─┘o


                              |\ /| /|_/|
                            |\||-|\||-/|/|
                             \\|\|//||///
            _..----.._       |\/\||//||||
          .'     o    '.     |||\\|/\\ ||
         /   o       o  \    | './\_/.' |
        |o        o     o|   |          |
        /'-.._o     __.-'\   |          |
        \      `````     /   |          |
        |``--........--'`|    '.______.'
         \              /
          `'----------'`


  "
end


def new_user_greeting
  sleep(1)
  puts "
╦ ╦┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐  ┌┬┐┌─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─  ╔═╗┬┌┐┌┌┬┐┌─┐┬─┐┬
║║║├┤ │  │  │ ││││├┤    │ │ │  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐  ╠╣ ││││ ││├┤ ├┬┘│
╚╩╝└─┘┴─┘└─┘└─┘┴ ┴└─┘   ┴ └─┘  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴  ╚  ┴┘└┘─┴┘└─┘┴└─o
"
sleep(1)
end

def old_user_greeting
  sleep(1)
  puts "
╦ ╦┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐  ╔╗ ┌─┐┌─┐┬┌─┬
║║║├┤ │  │  │ ││││├┤   ╠╩╗├─┤│  ├┴┐│
╚╩╝└─┘┴─┘└─┘└─┘┴ ┴└─┘  ╚═╝┴ ┴└─┘┴ ┴o
"
sleep(1)
end

def old_user_menu_print
  sleep(1)
  puts "
╦ ╦┬ ┬┌─┐┌┬┐  ┬ ┬┌─┐┬ ┬┬  ┌┬┐  ┬ ┬┌─┐┬ ┬  ┬  ┬┬┌─┌─┐  ┌┬┐┌─┐  ┌┬┐┌─┐┌─┐
║║║├─┤├─┤ │   ││││ ││ ││   ││  └┬┘│ ││ │  │  │├┴┐├┤    │ │ │   │││ │ ┌┘
╚╩╝┴ ┴┴ ┴ ┴   └┴┘└─┘└─┘┴─┘─┴┘   ┴ └─┘└─┘  ┴─┘┴┴ ┴└─┘   ┴ └─┘  ─┴┘└─┘ o
Please select a number:
1. See my saved Shake Shacks
2. Find a new Shake Shack
3. Delete my account
4. Exit
  "
  sleep(1)
end

def main_greeting
  puts "
╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─  ╔═╗┬┌┐┌┌┬┐┌─┐┬─┐
╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐  ╠╣ ││││ ││├┤ ├┬┘
╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴  ╚  ┴┘└┘─┴┘└─┘┴└─


                            |\ /| /|_/|
                          |\||-|\||-/|/|
                           \\|\|//||///
          _..----.._       |\/\||//||||
        .'     o    '.     |||\\|/\\ ||
       /   o       o  \    | './\_/.' |
      |o        o     o|   |          |
      /'-.._o     __.-'\   |          |
      \      `````     /   |          |
      |``--........--'`|    '.______.'
       \              /
        `'----------'`


  "
  sleep(1)
end

def what_is_your_name
  sleep(1)
  puts "

╦ ╦┬ ┬┌─┐┌┬┐  ┬┌─┐  ┬ ┬┌─┐┬ ┬┬─┐  ┌┐┌┌─┐┌┬┐┌─┐┌─┐
║║║├─┤├─┤ │   │└─┐  └┬┘│ ││ │├┬┘  │││├─┤│││├┤  ┌┘
╚╩╝┴ ┴┴ ┴ ┴   ┴└─┘   ┴ └─┘└─┘┴└─  ┘└┘┴ ┴┴ ┴└─┘ o
"
sleep(1)
end

def help_find_ss
  sleep(1)
  puts "

╦ ╦┌─┐  ┬ ┬┬┬  ┬    ┬ ┬┌─┐┬  ┌─┐  ┬ ┬┌─┐┬ ┬  ┌─┐┬┬┌┐┌┌┬┐  ┌─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─
║║║├┤   │││││  │    ├─┤├┤ │  ├─┘  └┬┘│ ││ │  ├┤ │││││ ││  ├─┤  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐
╚╩╝└─┘  └┴┘┴┴─┘┴─┘  ┴ ┴└─┘┴─┘┴     ┴ └─┘└─┘  └  ┴┴┘└┘─┴┘  ┴ ┴  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴
"
sleep(1)
end

def ask_for_zip_code
  sleep(1)
  puts "

╦ ╦┬ ┬┌─┐┌┬┐  ┬┌─┐  ┬ ┬┌─┐┬ ┬┬─┐  ┌─┐┬┌─┐  ┌─┐┌─┐┌┬┐┌─┐┌─┐
║║║├─┤├─┤ │   │└─┐  └┬┘│ ││ │├┬┘  ┌─┘│├─┘  │  │ │ ││├┤  ┌┘
╚╩╝┴ ┴┴ ┴ ┴   ┴└─┘   ┴ └─┘└─┘┴└─  └─┘┴┴    └─┘└─┘─┴┘└─┘ o
"
sleep(1)
end

def your_shake_shacks
  sleep(1)
  puts "
  ╦ ╦┌─┐┬ ┬┬─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─┌─┐
  ╚╦╝│ ││ │├┬┘  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐└─┐
   ╩ └─┘└─┘┴└─  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴└─┘

  "
  sleep(1)
end

def really?
  sleep(1)
  puts "


  ╦═╗┌─┐┌─┐┬  ┬ ┬ ┬┌─┐
  ╠╦╝├┤ ├─┤│  │ └┬┘ ┌┘
  ╩╚═└─┘┴ ┴┴─┘┴─┘┴  o

(y/n)

  "
sleep(1)
end

def really_really?
  sleep(1)
  puts "


  ╦═╗┌─┐┌─┐┬  ┬ ┬ ┬  ┬─┐┌─┐┌─┐┬  ┬ ┬ ┬┌─┐
  ╠╦╝├┤ ├─┤│  │ └┬┘  ├┬┘├┤ ├─┤│  │ └┬┘ ┌┘
  ╩╚═└─┘┴ ┴┴─┘┴─┘┴   ┴└─└─┘┴ ┴┴─┘┴─┘┴  o

(y/n)

  "
  sleep(1)

end

# binding.pry
puts "0"
