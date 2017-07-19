class RemoveStartTimeToCalendarGuest < ActiveRecord::Migration
  def change
    remove_column :calendar_guests, :start_time, :datetime
  end
end
