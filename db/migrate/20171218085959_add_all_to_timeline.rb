class AddAllToTimeline < ActiveRecord::Migration[5.0]
  def change
    add_column :timelines, :name, :text
    add_column :timelines, :latitude, :text
    add_column :timelines, :longitude, :text
  end
end
