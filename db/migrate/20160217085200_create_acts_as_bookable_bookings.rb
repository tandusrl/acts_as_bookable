class CreateActsAsBookableBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :acts_as_bookable_bookings, force: true do |t|
      t.references :bookable, polymorphic: true, index: {name: "index_acts_as_bookable_bookings_bookable"}
      t.references :booker, polymorphic: true, index: {name: "index_acts_as_bookable_bookings_booker"}
      t.column :amount, :integer
      t.column :schedule, :text
      t.column :time_start, :datetime
      t.column :time_end, :datetime
      t.column :time, :datetime
      t.datetime :created_at
    end
  end
end
