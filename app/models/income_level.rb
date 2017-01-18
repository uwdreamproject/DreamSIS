class IncomeLevel < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  
  # Calculate the title for this IncomeLevel. In most cases, this is just ":min_level to :max_level." But if min_level is 0, we
  # change it to "Under :max_level" and if max_level is greater than +10e9+, we return ":min_level and above."
  def title
    return "Under #{number_to_currency max_level, precision: 0}" if min_level == 0
    return "#{number_to_currency min_level, precision: 0} and above" if max_level > 10e9
    "#{number_to_currency min_level, precision: 0} to #{number_to_currency max_level, precision: 0}"
  end
  
  def <=>(o)
    min_level <=> o.min_level rescue 0
  end
  
end
