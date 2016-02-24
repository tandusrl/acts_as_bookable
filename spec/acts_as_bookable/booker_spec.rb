require 'spec_helper'

describe 'Booker model' do
  before(:each) do
    @booker = build(:booker)
  end

  it 'should be valid with all required fields set' do
    expect(@booker).to be_valid
  end

  it 'should save a booker' do
    expect(@booker.save).to be_truthy
  end

  describe 'has_many :bookings' do
    before(:each) do
      @booker.save!
      bookable1 = create(:bookable)
      bookable2 = create(:bookable)
      booking1 = ActsAsBookable::Booking.create(bookable: bookable1, booker: @booker)
      booking2 = ActsAsBookable::Booking.create(bookable: bookable2, booker: @booker)
      @booker.reload
    end

    it 'should have many bookings' do
      expect(@booker.bookings).to be_present
      expect(@booker.bookings.count).to eq 2
    end

    it 'dependent: :destroy' do
      count = ActsAsBookable::Booking.count
      @booker.destroy
      expect(ActsAsBookable::Booking.count).to eq count -2
    end
  end

  describe '#book!' do
    before(:each) do
      @bookable = create(:room)

    end

    it 'should respond to #book!' do
      expect(@booker).to respond_to :book!
    end

    it 'should create a new booking' do
      count = @booker.bookings.count
      new_booking = @booker.book!(@bookable, time_start: Date.today, time_end: Date.today + 1.day, amount: 2)
      expect(@booker.bookings.count).to eq count+1
      expect(new_booking.class.to_s).to eq "ActsAsBookable::Booking"
    end

    it 'new booking should have all fields set' do
      new_booking = @booker.book!(@bookable, time_start: Date.today, time_end: Date.today + 1.day, amount: 2)
      new_booking.reload
      expect(new_booking.time_start).to be_present
      expect(new_booking.time_end).to be_present
      expect(new_booking.amount).to be_present
    end

    it 'should raise ActiveRecord::RecordInvalid if new booking is not valid' do
      expect{ @booker.book!(Generic.new) }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'should not create a new booking if it\'s not valid' do
      count = @booker.bookings.count
      begin
        @booker.book!(Generic.new)
      rescue ActiveRecord::RecordInvalid => er
      end
      expect(@booker.bookings.count).to eq count
    end

    it 'should raise ActsAsBookable::AvailabilityError if the bookable is not available' do
      @booker.book!(@bookable, time_start: Date.today, time_end: Date.today + 1.day, amount: 2)
      expect{ @booker.book!(@bookable, time_start: Date.today, time_end: Date.today + 1.day, amount: 2)}.to raise_error ActsAsBookable::AvailabilityError
    end
  end
end
