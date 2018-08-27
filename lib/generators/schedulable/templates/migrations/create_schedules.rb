class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.references :schedulable, polymorphic: true
      
      t.date :date
      t.time :time
      
      t.string :rule
      t.string :interval

      t.text :minute_of_hour
      t.text :hour_of_day
      t.text :day
      t.text :day_of_week
      t.text :day_of_month
      
      t.datetime :until
      t.integer :count
      
      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end