# The parent class for all objects that come from the UWSDB.  StudentInfo establishes a connection to the UWSDB database and sets the primary key for all child classes to match UWSDB's primary key ("system_key")
class StudentInfo < ActiveRecord::Base

  self.abstract_class = true
  establish_connection :uwsdb

  # Set some options to work with the UWSDB tables properly
  #self.pluralize_table_names = false  # don't do this because it seems to be a global change, not just on StudentInfo models
  set_primary_key "system_key"
  
end
