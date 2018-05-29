require 'spec_helper'

describe 'Bookable model' do
  before(:each) do
    @bookable = build(:bookable)
  end

  describe 'conditional validations' do
    it 'should be valid with all required fields set' do
      expect(@bookable).to be_valid
    end

    it 'should save a bookable' do
      expect(@bookable.save).to be_truthy
    end

    describe 'when capacity is required' do
      before(:each) do
        Bookable.booking_opts[:capacity_type] = :closed
        Bookable.initialize_acts_as_bookable_core
      end
      after(:all) do
        Bookable.booking_opts = {}
        Bookable.initialize_acts_as_bookable_core
      end

      it 'should not validate with capacity < 0 if capacity is required' do
        @bookable.capacity = -1
        expect(@bookable.valid?).to be_falsy
      end

      it 'should not validate without capacity' do
        @bookable.capacity = nil
        expect(@bookable.valid?).to be_falsy
      end
    end

    describe 'when capacity is not required' do
      before(:each) do
        Bookable.booking_opts[:capacity_type] = :none
        Bookable.initialize_acts_as_bookable_core
      end
      after(:all) do
        Bookable.booking_opts = {}
        Bookable.initialize_acts_as_bookable_core
      end

      it 'should validate with capacity < 0' do
        @bookable.capacity = -1
        expect(@bookable.valid?).to be_truthy
      end

      it 'should validate without capacity if it\'s not required' do
        @bookable.capacity = nil
        expect(@bookable.valid?).to be_truthy
      end
    end

    describe 'when schedule is required' do
      before(:each) do
        Bookable.booking_opts[:time_type] = :range
        Bookable.initialize_acts_as_bookable_core
      end
      after(:all) do
        Bookable.booking_opts = {}
        Bookable.initialize_acts_as_bookable_core
      end

      it 'should not validate without schedule' do
        @bookable.schedule = nil
        expect(@bookable.valid?).to be_falsy
      end
    end

    describe 'when schedule is not required' do
      before(:each) do
        Bookable.booking_opts[:time_type] = :none
        Bookable.initialize_acts_as_bookable_core
      end
      after(:all) do
        Bookable.booking_opts = {}
        Bookable.initialize_acts_as_bookable_core
      end

      it 'should validate without schedule if it\'s not required' do
        @bookable.schedule = nil
        expect(@bookable.valid?).to be_truthy
      end
    end
  end


  describe 'has_many :bookings' do
    before(:each) do
      @bookable.save!
      booker1 = create(:booker, name: 'Booker 1')
      booker2 = create(:booker, name: 'Booker 2')
      booking1 = ActsAsBookable::Booking.create!(booker: booker1, bookable: @bookable)
      booking2 = ActsAsBookable::Booking.create!(booker: booker1, bookable: @bookable)
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

  describe '#schedule' do
    it 'allows for creation of a bookable with a IceCube schedule' do
      schedule = IceCube::Schedule.new
      # Every Monday,Tuesday and Friday
      schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday, :tuesday, :friday)
      @bookable.schedule = schedule
      expect(@bookable.save).to be_truthy
    end
  end
end
