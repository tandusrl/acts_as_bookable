class AddZenBookingToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :acts_as_bookable_bookings, :zen_booking, :integer
  end
end
