require 'spec_helper'

describe 'Bookable model' do
  describe 'InstanceMethods' do
    it 'should add a method #check_availability! in instance-side' do
      @bookable = Bookable.new
      expect(@bookable).to respond_to :check_availability!
    end

    it 'should add a method #¢heck_availability in instance-side' do
      @bookable = Bookable.new
      expect(@bookable).to respond_to :check_availability
    end

    it 'should add a method #validate_booking_options! in instance-side' do
      @bookable = Bookable.new
      expect(@bookable).to respond_to :validate_booking_options!
    end

    describe '#check_availability! and check_availability' do
      after(:each) do
        Bookable.booking_opts = {}
        Bookable.initialize_acts_as_bookable_core
      end

      describe 'whithout any costraint' do
        before(:each) do
          Bookable.booking_opts = {
            time_type: :none,
            capacity_type: :none
          }
          Bookable.initialize_acts_as_bookable_core
          @bookable = Bookable.create!(name: 'bookable')
        end

        it 'should be always available' do
          expect(@bookable.check_availability({})).to be_truthy
          expect(@bookable.check_availability!({})).to be_truthy
        end
      end
    end

    describe 'with time_type: :range' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :range,
          capacity_type: :none
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable')
      end

      pending 'should be available in available times'
      pending 'should not be available in not bookable times'
    end

    describe 'with time_type: :fixed' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :fixed,
          capacity_type: :none
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable')
      end

      pending 'should be available in available times'
      pending 'should not be available in not bookable times'
    end

    describe 'with capacity_type: :open' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :none,
          capacity_type: :open
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable', capacity: 4)
      end

      it 'should be available if amount <= capacity' do
        (1..@bookable.capacity).each do |amount|
          expect(@bookable.check_availability(amount: amount)).to be_truthy
          expect(@bookable.check_availability!(amount: amount)).to be_truthy
        end
      end

      it 'should not be available if amount > capacity' do
        expect(@bookable.check_availability(amount: @bookable.capacity + 1)).to be_falsy
        expect { @bookable.check_availability!(amount: @bookable.capacity + 1) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!(amount: @bookable.capacity + 1)
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include 'cannot be greater'
        end
      end

      it 'should be available if already booked but amount <= conditional capacity' do
        booker = create(:booker)
        @bookable.book!(booker, amount: 2)
        (1..(@bookable.capacity - 2)).each do |amount|
          expect(@bookable.check_availability(amount: amount)).to be_truthy
          expect(@bookable.check_availability!(amount: amount)).to be_truthy
        end
      end

      it 'should not be available if amount <= capacity but already booked and amount > conditional capacity' do
        booker = create(:booker)
        @bookable.book!(booker, amount: 2)
        amount = @bookable.capacity - 2 + 1
        expect(@bookable.check_availability(amount: amount)).to be_falsy
        expect { @bookable.check_availability!(amount: amount) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!(amount: amount)
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include 'is fully booked'
        end
      end


      pending 'should be available if amount <= capacity and already booked and amount > conditional capacity but overlappings are separated in time and space'
    end

    describe 'with capacity_type: :closed' do
      before(:each) do
        Bookable.booking_opts = {
          time_type: :none,
          capacity_type: :closed
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable', capacity: 4)
      end

      it 'should be available if amount <= capacity' do
        (1..@bookable.capacity).each do |amount|
          expect(@bookable.check_availability(amount: amount)).to be_truthy
          expect(@bookable.check_availability!(amount: amount)).to be_truthy
        end
      end

      it 'should not be available if amount > capacity' do
        expect(@bookable.check_availability(amount: @bookable.capacity + 1)).to be_falsy
        expect { @bookable.check_availability!(amount: @bookable.capacity + 1) }.to raise_error ActsAsBookable::AvailabilityError
        begin
          @bookable.check_availability!(amount: @bookable.capacity + 1)
        rescue ActsAsBookable::AvailabilityError => e
          expect(e.message).to include 'cannot be greater'
        end
      end

      it 'should not be available if already booked (even though amount < capacity - overlapped amounts)' do
        booker = create(:booker)
        @bookable.book!(booker, amount: 1)
        (1..(@bookable.capacity + 1)).each do |amount|
          expect(@bookable.check_availability(amount: amount)).to be_falsy
          expect { @bookable.check_availability!(amount: amount) }.to raise_error ActsAsBookable::AvailabilityError
          begin
            @bookable.check_availability!(amount: amount)
          rescue ActsAsBookable::AvailabilityError => e
            if(amount <= @bookable.capacity)
              expect(e.message).to include('is fully booked')
            else
              expect(e.message).to include('cannot be greater')
            end
          end
        end
      end
    end
  end

  describe 'self.initialize_acts_as_bookable_core' do
    after(:each) do
      Bookable.booking_opts = {}
      Bookable.initialize_acts_as_bookable_core
    end

    describe '#set_options' do
      it 'defaults preset to room' do
        Bookable.booking_opts = {}
        Bookable.initialize_acts_as_bookable_core
        expect(Bookable.booking_opts[:preset]).to eq 'room'
      end

      it 'preset options for room' do
        ['room','event','show'].each do |p|
          Bookable.booking_opts = {preset: p}
          Bookable.initialize_acts_as_bookable_core
          expect(Bookable.booking_opts[:preset]).to eq p
          expect(Bookable.booking_opts[:time_type]).to be(:range).or be(:fixed).or be(:none)
          expect(Bookable.booking_opts[:capacity_type]).to be(:open).or be(:closed)
        end
      end

      it 'fails when using an unknown preset' do
        Bookable.booking_opts = {preset: 'unknown'}
        expect{ Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
      end

      it 'correctly set undefined options' do
        Bookable.booking_opts = {}
        Bookable.initialize_acts_as_bookable_core
        expect(Bookable.booking_opts[:preset]).to be_present
        expect(Bookable.booking_opts[:date_type]).not_to be_present
        expect(Bookable.booking_opts[:time_type]).to be_present
        expect(Bookable.booking_opts[:location_type]).not_to be_present
        expect(Bookable.booking_opts[:capacity_type]).to be_present
      end

      it 'correctly merges options' do
        Bookable.booking_opts = {time_type: :range, capacity_type: :closed}
        Bookable.initialize_acts_as_bookable_core
        expect(Bookable.booking_opts[:preset]).to be_present
        expect(Bookable.booking_opts[:date_type]).not_to be_present
        expect(Bookable.booking_opts[:time_type]).to be :range
        expect(Bookable.booking_opts[:location_type]).not_to be_present
        expect(Bookable.booking_opts[:capacity_type]).to be :closed
      end

      it 'should not allow unknown keys' do
        Bookable.booking_opts = {unknown: 'lol'}
        expect { Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
        begin
          Bookable.initialize_acts_as_bookable_core
        rescue ActsAsBookable::InitializationError => e
          expect(e.message).to include 'is not a valid option'
        end
      end

      it 'should not allow unknown values on :time_type' do
        Bookable.booking_opts = {time_type: :unknown}
        expect { Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
        begin
          Bookable.initialize_acts_as_bookable_core
        rescue ActsAsBookable::InitializationError => e
          expect(e.message).to include 'is not a valid value for time_type'
        end
      end

      it 'should not allow unknown values on :capacity_type' do
        Bookable.booking_opts = {capacity_type: :unknown}
        expect { Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
        begin
          Bookable.initialize_acts_as_bookable_core
        rescue ActsAsBookable::InitializationError => e
          expect(e.message).to include 'is not a valid value for capacity_type'
        end
      end
    end
  end

  describe 'self.validate_booking_options!' do
    before(:each) do
      Bookable.booking_opts = {
        time_type: :none,
        capacity_type: :none
      }
      @opts = {}
    end

    describe 'with capacity_type: :none and time_type: :none' do
      it 'validates with default options' do
        expect(Bookable.validate_booking_options!(@opts)).to be_truthy
      end
    end

    describe 'with time_type = ' do
      describe ':range' do
        before(:each) do
          Bookable.booking_opts[:time_type] = :range
          Bookable.initialize_acts_as_bookable_core
          @opts[:time_start] = Time.now + 1.hour
          @opts[:time_end] = Time.now + 4.hours
        end

        it 'validates with all options fields set' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end

        it 'requires from_time as Time' do
          @opts[:time_start] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          @opts[:time_start] = 'String'
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'requires to_time as Time' do
          @opts[:time_end] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          @opts[:time_end] = 'String'
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept a fixed time' do
          @opts[:time] = Time.now
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end

      describe ':fixed' do
        before(:each) do
          Bookable.booking_opts[:time_type] = :fixed
          Bookable.initialize_acts_as_bookable_core
          @opts[:time] = Time.now + 1.hour
        end

        it 'validates with the right fields set' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end

        it 'requires date as Time' do
          @opts[:time] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          @opts[:time] = 'String'
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept from_time' do
          @opts[:time_start] = Time.now + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept to_time' do
          @opts[:time_end] = Time.now + 15
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end

      describe ':none' do
        before(:each) do
          Bookable.initialize_acts_as_bookable_core
        end

        it 'doesn\'t accept time' do
          @opts[:time] = Time.now + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept from_time' do
          @opts[:time_start] = Time.now + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept to_time' do
          @opts[:time_end] = Time.now + 15
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end
    end

    describe 'with capacity_type = ' do
      describe ':open' do
        before(:each) do
          Bookable.booking_opts[:capacity_type] = :open
          Bookable.initialize_acts_as_bookable_core
          @opts[:amount] = 2
        end

        it 'validates with all options fields set' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end

        it 'requires :amount as integer' do
          @opts[:amount] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end

      describe ':closed' do
        before(:each) do
          Bookable.booking_opts[:capacity_type] = :closed
          Bookable.initialize_acts_as_bookable_core
          @opts[:amount] = 2
        end

        it 'validates with all options fields set' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end

        it 'requires :amount as integer' do
          @opts[:amount] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end

      describe ':none' do
        before(:each) do
          Bookable.initialize_acts_as_bookable_core
        end

        it 'doesn\'t accept amount' do
          @opts[:amount] = 2.3
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end
    end

  end
end
