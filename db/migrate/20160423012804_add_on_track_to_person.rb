class AddOnTrackToPerson < ActiveRecord::Migration
  def change
    add_column :people, :on_track_to_graduate, :boolean, default: true
  end
end
