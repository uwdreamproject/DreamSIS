class ConvertToMultiYearFafsa < ActiveRecord::Migration
  def self.up
    n = 0
    Participant.find_in_batches do |parts|
      parts.each do |p|
        if (!p.fafsa_submitted_date.nil? || !p.fafsa_not_applicable.nil?) && !p.grad_year.nil?
          f = p.fafsa(p.grad_year)
          f.fafsa_submitted_at = p.fafsa_submitted_date
          f.not_applicable = p.fafsa_not_applicable
          f.save
          n = n+1
        end
      end
    end
    puts "#{n} records updated."
  end

  def self.down
    puts "Nothing to reverse."
  end
end
