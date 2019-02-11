class User < ActiveRecord::Base

  has_many :saves
  has_many :sss, through: :saves

end
