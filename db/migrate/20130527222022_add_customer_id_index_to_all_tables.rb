class AddCustomerIdIndexToAllTables < ActiveRecord::Migration
  TABLE_NAMES = %w[events locations event_attendances education_levels income_levels scholarships users how_did_you_hear_options how_did_you_hear_options_people event_groups event_types notes identities event_shifts training_completions trainings people test_scores test_types mentor_term_groups mentor_terms terms enrollments degrees object_filters]
  
  def self.up
    for table_name in TABLE_NAMES
      add_index table_name, :customer_id
    end
  end

  def self.down
    for table_name in TABLE_NAMES.reverse
      remove_index table_name, :customer_id
    end
  end
end