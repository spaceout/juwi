class Setting < ActiveRecord::Base
   def self.get_value(name)
     Setting.find_by_name(name).try(:value)
   end
   def self.set_value(name, value)
     Setting.find_by_name(name).update_attributes(:value => value)
   end
end
