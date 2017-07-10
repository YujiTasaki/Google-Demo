class DropTableGoogleCalendars < ActiveRecord::Migration
  def change
    drop_table :google_calendars 
  end
end
