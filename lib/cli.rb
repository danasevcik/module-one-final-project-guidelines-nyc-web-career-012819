require 'pry'
require_relative '../config/environment'
require_relative '../lib/save.rb'
require_relative '../lib/ss.rb'
require_relative '../lib/user.rb'
require_relative '../lib/yelp_api_adapter.rb'
require_relative '../lib/cli.rb'

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
  this_user = User.find_by(name: user_name)
  if input == "1" && (Save.where(user_id: this_user.id).count > 0)
    puts Save.where(user_id: this_user.id).ss
  elsif input == "1" && (Save.where(user_id: this_user.id).count <= 0)
    puts "#{user_name}, you don't have any saved Shake Shacks yet."
    old_user_menu(user_name)
  elsif input == "2"
    puts "Please enter a zip code:"
    get_zip_code
  else
    puts "Please enter 1 or 2!"
  end
end

def new_user_menu(user_name)
  User.create(name: user_name)
  help_find_ss
  ask_for_zip_code
  get_zip_code
end















def get_zip_code
  zip_code = gets.chomp
  get_ss_from_zip_code(zip_code)
end

def get_ss_from_zip_code(zip_code)
  # go into API
  # get SS that matches zip code

  closest_ss = YelpApiAdapter.search("Shake Shack", zip_code)

  if closest_ss["location"]["zip_code"] == zip_code
    puts "
    Your closest Shake Shack:

    Name: #{closest_ss["alias"]}
    URL: https://www.yelp.com/biz/#{closest_ss["alias"]}
    Rating: #{closest_ss["rating"]}
    Address: #{closest_ss["location"]["display_address"]}
    Phone Number: #{closest_ss["phone"]}
    "
  elsif closest_ss["location"]["zip_code"] != zip_code
    puts "
    There are no Shake Shacks in your zip code.
    Please enter a nearby zip code:
    "

    # city_name = gets.chomp
    get_ss_from_city
  end
end

def get_ss_from_city
  city_name = gets.chomp
  SEARCH_LIMIT = 5
end

def new_user_greeting
  puts "
╦ ╦┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐  ┌┬┐┌─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─  ╔═╗┬┌┐┌┌┬┐┌─┐┬─┐┬
║║║├┤ │  │  │ ││││├┤    │ │ │  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐  ╠╣ ││││ ││├┤ ├┬┘│
╚╩╝└─┘┴─┘└─┘└─┘┴ ┴└─┘   ┴ └─┘  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴  ╚  ┴┘└┘─┴┘└─┘┴└─o
"
end

def old_user_greeting
  puts "
╦ ╦┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐  ╔╗ ┌─┐┌─┐┬┌─┬
║║║├┤ │  │  │ ││││├┤   ╠╩╗├─┤│  ├┴┐│
╚╩╝└─┘┴─┘└─┘└─┘┴ ┴└─┘  ╚═╝┴ ┴└─┘┴ ┴o
"
end

def old_user_menu_print
  puts "
╦ ╦┬ ┬┌─┐┌┬┐  ┬ ┬┌─┐┬ ┬┬  ┌┬┐  ┬ ┬┌─┐┬ ┬  ┬  ┬┬┌─┌─┐  ┌┬┐┌─┐  ┌┬┐┌─┐┌─┐
║║║├─┤├─┤ │   ││││ ││ ││   ││  └┬┘│ ││ │  │  │├┴┐├┤    │ │ │   │││ │ ┌┘
╚╩╝┴ ┴┴ ┴ ┴   └┴┘└─┘└─┘┴─┘─┴┘   ┴ └─┘└─┘  ┴─┘┴┴ ┴└─┘   ┴ └─┘  ─┴┘└─┘ o
Please select a number:
1. See my saved Shake Shacks
2. Find a new Shake Shack
  "
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
end

def what_is_your_name
  puts "

╦ ╦┬ ┬┌─┐┌┬┐  ┬┌─┐  ┬ ┬┌─┐┬ ┬┬─┐  ┌┐┌┌─┐┌┬┐┌─┐┌─┐
║║║├─┤├─┤ │   │└─┐  └┬┘│ ││ │├┬┘  │││├─┤│││├┤  ┌┘
╚╩╝┴ ┴┴ ┴ ┴   ┴└─┘   ┴ └─┘└─┘┴└─  ┘└┘┴ ┴┴ ┴└─┘ o
"
end

def help_find_ss
  puts "

╦ ╦┌─┐  ┬ ┬┬┬  ┬    ┬ ┬┌─┐┬  ┌─┐  ┬ ┬┌─┐┬ ┬  ┌─┐┬┬┌┐┌┌┬┐  ┌─┐  ╔═╗┬ ┬┌─┐┬┌─┌─┐  ╔═╗┬ ┬┌─┐┌─┐┬┌─
║║║├┤   │││││  │    ├─┤├┤ │  ├─┘  └┬┘│ ││ │  ├┤ │││││ ││  ├─┤  ╚═╗├─┤├─┤├┴┐├┤   ╚═╗├─┤├─┤│  ├┴┐
╚╩╝└─┘  └┴┘┴┴─┘┴─┘  ┴ ┴└─┘┴─┘┴     ┴ └─┘└─┘  └  ┴┴┘└┘─┴┘  ┴ ┴  ╚═╝┴ ┴┴ ┴┴ ┴└─┘  ╚═╝┴ ┴┴ ┴└─┘┴ ┴
"
end

def ask_for_zip_code
  puts "

╦ ╦┬ ┬┌─┐┌┬┐  ┬┌─┐  ┬ ┬┌─┐┬ ┬┬─┐  ┌─┐┬┌─┐  ┌─┐┌─┐┌┬┐┌─┐┌─┐
║║║├─┤├─┤ │   │└─┐  └┬┘│ ││ │├┬┘  ┌─┘│├─┘  │  │ │ ││├┤  ┌┘
╚╩╝┴ ┴┴ ┴ ┴   ┴└─┘   ┴ └─┘└─┘┴└─  └─┘┴┴    └─┘└─┘─┴┘└─┘ o
"
end

binding.pry
puts "0"
