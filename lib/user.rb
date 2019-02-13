class User < ActiveRecord::Base

  has_many :saves
  has_many :sses, through: :saves

end
