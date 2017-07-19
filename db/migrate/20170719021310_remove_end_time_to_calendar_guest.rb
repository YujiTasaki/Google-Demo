class RemoveEndTimeToCalendarGuest < ActiveRecord::Migration
  def change
    remove_column :calendar_guests, :end_time, :datetime
  end
end
