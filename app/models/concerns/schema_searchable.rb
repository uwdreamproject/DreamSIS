module SchemaSearchable
  extend ActiveSupport::Concern
  include ActionView::Helpers::NumberHelper

  module ClassMethods
    def tenant_index_name
      -> { [Apartment::Tenant.current, model_name.plural, Rails.env].join('_') }
    end
  end
  
  def as_search_result_json(options = {})
    options = { root: false }.merge(options)
    search_result.as_json(options)
  end
  
  def search_result
    {
      id: id,
      type: self.class.to_s,
      name: try(:fullname) || try(:name) || try(:title),
      email: try(:email),
      phone: number_to_phone(try(:phone_mobile)),
      url: Rails.application.routes.url_helpers.try(self.class.to_s.underscore + "_path", self)
    }
  end
    
end
