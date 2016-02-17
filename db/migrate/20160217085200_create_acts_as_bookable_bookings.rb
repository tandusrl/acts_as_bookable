class CreateActsAsBookableBookings < ActiveRecord::Migration
  def change
    create_table :acts_as_bookable_bookings, force: :cascade do |t|
      t.references :bookable, polymorphic: true
      t.references :booker, polymorphic: true
      t.column :amount, :integer
      t.column :schedule, :text
      t.column :time_start, :datetime
      t.column :time_end, :datetime
      t.column :time, :datetime
      t.datetime :created_at
    end
  end
end
