require 'spec_helper'

describe 'Bookable model' do
  before(:each) do
    @bookable = build(:bookable)
  end

  describe 'validations' do
    it 'should be valid with all required fields set' do
      expect(@bookable).to be_valid
    end

    it 'should save a bookable' do
      expect(@bookable.save).to be_truthy
    end

    it 'should not validate with capacity < 0' do
      @bookable.capacity = -1
      expect(@bookable.valid?).to be_falsy
    end

    it 'should not validate without capacity' do
      @bookable.capacity = nil
      expect(@bookable.valid?).to be_falsy
    end

    it 'should not validate without schedule' do
      @bookable.schedule = nil
      expect(@bookable.valid?).to be_falsy
    end
  end


  describe 'has_many :bookings' do
    before(:each) do
      @bookable.save!
      booker1 = create(:booker, name: 'Booker 1')
      booker2 = create(:booker, name: 'Booker 2')
      booking1 = ActsAsBookable::Booking.create!(booker: booker1, bookable: @bookable, schedule: 'ever', amount: 2)
      booking2 = ActsAsBookable::Booking.create!(booker: booker1, bookable: @bookable, schedule: 'ever', amount: 2)
      @bookable.reload
    end

    it 'should have many bookings' do
      expect(@bookable.bookings).to be_present
      expect(@bookable.bookings.count).to eq 2
    end

    it 'dependent: :destroy' do
      count = ActsAsBookable::Booking.count
      @bookable.destroy
      expect(ActsAsBookable::Booking.count).to eq count -2
    end
  end
end
