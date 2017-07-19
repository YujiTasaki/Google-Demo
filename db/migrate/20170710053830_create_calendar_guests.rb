class CreateCalendarGuests < ActiveRecord::Migration
  def change
    create_table :calendar_guests do |t|
      t.string :event_id
      t.string :user_id
      t.datetime :start_time
      t.datetime :end_time
      
      t.timestamps null: false
    end
  end
end
