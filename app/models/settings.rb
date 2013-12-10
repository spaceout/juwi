class Settings < ActiveRecord::Base
  # attr_accessible :title, :body
   def self.get_value(name)
     Settings.find_by_name(name).try(:value)
   end
end
