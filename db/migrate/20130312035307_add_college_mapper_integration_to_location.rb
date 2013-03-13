class AddCollegeMapperIntegrationToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :enable_college_mapper_integration, :boolean
  end

  def self.down
    remove_column :locations, :enable_college_mapper_integration
  end
end
