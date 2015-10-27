class AddRequireParentalConsentForMinorsToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :require_parental_consent_for_minors, :boolean
    add_column :people, :parental_consent_on_file, :boolean
  end
end
