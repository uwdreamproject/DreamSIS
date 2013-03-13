class AddCollegeMapperIdToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :college_mapper_id, :integer
  end

  def self.down
    remove_column :people, :college_mapper_id
  end
end
