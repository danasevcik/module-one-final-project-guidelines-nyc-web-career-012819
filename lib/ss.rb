class Ss < ActiveRecord::Base

  has_many :saves
  has_many :users, through: :saves

end
