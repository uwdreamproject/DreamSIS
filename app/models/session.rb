class Session < ActiveRecord::Base
  def self.sweep!(time = 12.hours, max = 3.days)
    time = time.split.inject { |count, unit| count.to_i.send(unit) } if time.is_a?(String)
    max = max.split.inject { |count, unit| count.to_i.send(unit) } if max.is_a?(String)
    
    delete_all "updated_at < '#{time.ago.to_s(:db)}' OR created_at < '#{max.ago.to_s(:db)}'"
  end
end
