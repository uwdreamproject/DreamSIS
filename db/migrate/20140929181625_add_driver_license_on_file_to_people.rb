class AddDriverLicenseOnFileToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :driver_license_on_file, :boolean
  end

  def self.down
    remove_column :people, :driver_license_on_file
  end
end
