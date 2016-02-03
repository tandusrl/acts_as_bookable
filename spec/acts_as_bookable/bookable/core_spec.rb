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
            date_type: :none,
            time_type: :none,
            location_type: :none,
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

      describe 'with date_type: :range' do
        before(:each) do
          Bookable.booking_opts = {
            date_type: :range,
            time_type: :none,
            location_type: :none,
            capacity_type: :none
          }
          Bookable.initialize_acts_as_bookable_core
          @bookable = Bookable.create!(name: 'bookable', schedule: 'ever')
        end

        pending 'should be available in available dates'
        pending 'should not be available in not bookable dates'
      end

      describe 'with date_type: :fixed' do
        before(:each) do
          Bookable.booking_opts = {
            date_type: :fixed,
            time_type: :none,
            location_type: :none,
            capacity_type: :none
          }
          Bookable.initialize_acts_as_bookable_core
          @bookable = Bookable.create!(name: 'bookable', schedule: 'ever')
        end

        pending 'should be available in available dates'
        pending 'should not be available in not bookable dates'
      end
    end

    describe 'with time_type: :range' do
      before(:each) do
        Bookable.booking_opts = {
          date_type: :none,
          time_type: :range,
          location_type: :none,
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
          date_type: :none,
          time_type: :fixed,
          location_type: :none,
          capacity_type: :none
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable')
      end

      pending 'should be available in available times'
      pending 'should not be available in not bookable times'
    end

    describe 'with location_type: :range' do
      before(:each) do
        Bookable.booking_opts = {
          date_type: :none,
          location_type: :range,
          time_type: :none,
          capacity_type: :none
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable')
      end

      pending 'should be available in available locations'
      pending 'should not be available in not bookable locations'
    end

    describe 'with location_type: :fixed' do
      before(:each) do
        Bookable.booking_opts = {
          date_type: :none,
          time_type: :none,
          location_type: :fixed,
          capacity_type: :none
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable')
      end

      pending 'should be available in available locations'
      pending 'should not be available in not bookable locations'
    end

    describe 'with capacity_type: :open' do
      before(:each) do
        Bookable.booking_opts = {
          date_type: :none,
          location_type: :none,
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
      end

      pending 'should be available if already booked but amount <= conditional capacity'
      pending 'should not be available if amount <= capacity but already booked and amount > conditional capacity'
    end

    describe 'with capacity_type: :closed' do
      before(:each) do
        Bookable.booking_opts = {
          date_type: :none,
          time_type: :none,
          location_type: :none,
          capacity_type: :closed
        }
        Bookable.initialize_acts_as_bookable_core
        @bookable = Bookable.create!(name: 'bookable')
      end

      pending 'should be available if amount < capacity'
      pending 'should not be available if amount > capacity'
      pending 'should not be available if amount < capacity but already booked'
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
        Bookable.booking_opts = {preset: 'room'}
        Bookable.initialize_acts_as_bookable_core
        expect(Bookable.booking_opts[:preset]).to eq 'room'
        expect(Bookable.booking_opts[:date_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:time_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:location_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:capacity_type]).to be(:open).or be(:closed)
      end

      it 'preset options for event' do
        Bookable.booking_opts = {preset: 'event'}
        Bookable.initialize_acts_as_bookable_core
        expect(Bookable.booking_opts[:preset]).to eq 'event'
        expect(Bookable.booking_opts[:date_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:time_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:location_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:capacity_type]).to be(:open).or be(:closed)
      end

      it 'preset options for show' do
        Bookable.booking_opts = {preset: 'show'}
        Bookable.initialize_acts_as_bookable_core
        expect(Bookable.booking_opts[:preset]).to eq 'show'
        expect(Bookable.booking_opts[:date_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:time_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:location_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:capacity_type]).to be(:open).or be(:closed)
      end

      # it 'preset options for table' do
      #   Bookable.booking_opts = {preset: 'table'}
      #   Bookable.initialize_acts_as_bookable_core
      #   expect(Bookable.booking_opts[:preset]).to eq 'table'
      #   expect(Bookable.booking_opts[:date_type]).to be(:range).or be(:fixed).or be(:none)
      #   expect(Bookable.booking_opts[:time_type]).to be(:range).or be(:fixed).or be(:none)
      #   expect(Bookable.booking_opts[:location_type]).to be(:range).or be(:fixed).or be(:none)
      #   expect(Bookable.booking_opts[:capacity_type]).to be(:open).or be(:closed)
      # end

      it 'preset options for taxi' do
        Bookable.booking_opts = {preset: 'taxi'}
        Bookable.initialize_acts_as_bookable_core
        expect(Bookable.booking_opts[:preset]).to eq 'taxi'
        expect(Bookable.booking_opts[:date_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:time_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:location_type]).to be(:range).or be(:fixed).or be(:none)
        expect(Bookable.booking_opts[:capacity_type]).to be(:open).or be(:closed)
      end

      it 'fails when using an unknown preset' do
        Bookable.booking_opts = {preset: 'unknown'}
        expect{ Bookable.initialize_acts_as_bookable_core }.to raise_error ActsAsBookable::InitializationError
      end

      it 'correctly set undefined options' do
        Bookable.booking_opts = {}
        Bookable.initialize_acts_as_bookable_core
        expect(Bookable.booking_opts[:preset]).to be_present
        expect(Bookable.booking_opts[:date_type]).to be_present
        expect(Bookable.booking_opts[:time_type]).to be_present
        expect(Bookable.booking_opts[:location_type]).to be_present
        expect(Bookable.booking_opts[:capacity_type]).to be_present
      end

      it 'correctly merges options' do
        Bookable.booking_opts = {time_type: :range, capacity_type: :closed}
        Bookable.initialize_acts_as_bookable_core
        expect(Bookable.booking_opts[:preset]).to be_present
        expect(Bookable.booking_opts[:date_type]).to be_present
        expect(Bookable.booking_opts[:time_type]).to be :range
        expect(Bookable.booking_opts[:location_type]).to be_present
        expect(Bookable.booking_opts[:capacity_type]).to be :closed
      end
    end
  end

  describe 'self.validate_booking_options!' do
    before(:each) do
      Bookable.booking_opts = {
        time_type: :none,
        location_type: :none,
        capacity_type: :none,
        date_type: :none
      }
      @opts = {}
    end

    describe 'with date_type: :none, location_type: :none and date_type: :none' do
      it 'validates with default options' do
        expect(Bookable.validate_booking_options!(@opts)).to be_truthy
      end
    end

    describe 'with date_type = ' do
      describe ':range' do
        before(:each) do
          Bookable.booking_opts[:date_type] = :range
          Bookable.initialize_acts_as_bookable_core
          @opts[:from_date] = Date.today + 10.days
          @opts[:to_date] = Date.today + 14.days
        end

        it 'validates with all options fields set' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end

        it 'requires from_date as Date' do
          @opts[:from_date] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          @opts[:from_date] = 'String'
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'requires to_date as Date' do
          @opts[:to_date] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          @opts[:to_date] = 'String'
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept a fixed date' do
          @opts[:date] = Date.today
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end

      describe ':fixed' do
        before(:each) do
          Bookable.booking_opts[:date_type] = :fixed
          Bookable.initialize_acts_as_bookable_core
          @opts[:date] = Date.today + 15
        end

        it 'validates with the right fields set' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end

        it 'requires date as Date' do
          @opts[:date] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          @opts[:date] = 'String'
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept from_date' do
          @opts[:from_date] = Date.today + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept to_date' do
          @opts[:to_date] = Date.today + 15
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end

      describe ':none' do
        before(:each) do
          Bookable.initialize_acts_as_bookable_core
        end

        it 'doesn\'t accept date' do
          @opts[:date] = Date.today + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept from_date' do
          @opts[:from_date] = Date.today + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept to_date' do
          @opts[:to_date] = Date.today + 15
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end
    end

    describe 'with time_type = ' do
      describe ':range' do
        before(:each) do
          Bookable.booking_opts[:time_type] = :range
          Bookable.initialize_acts_as_bookable_core
          @opts[:from_time] = Time.now + 1.hour
          @opts[:to_time] = Time.now + 4.hours
        end

        it 'validates with all options fields set' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end

        it 'requires from_time as Time' do
          @opts[:from_time] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          @opts[:from_time] = 'String'
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'requires to_time as Time' do
          @opts[:to_time] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
          @opts[:to_time] = 'String'
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
          @opts[:from_time] = Time.now + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept to_time' do
          @opts[:to_time] = Time.now + 15
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
          @opts[:from_time] = Time.now + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept to_time' do
          @opts[:to_time] = Time.now + 15
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end
    end

    describe 'with location_type = ' do
      describe ':range' do
        before(:each) do
          Bookable.booking_opts[:location_type] = :range
          Bookable.initialize_acts_as_bookable_core
          @opts[:from_location] = 'Torino'
          @opts[:to_location] = 'Cuneo'
        end

        it 'validates with all options fields set' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end

        it 'requires from_location as String' do
          @opts[:from_location] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'requires to_location as String' do
          @opts[:to_location] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept a fixed location' do
          @opts[:time] = 'String'
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end

      describe ':fixed' do
        before(:each) do
          Bookable.booking_opts[:location_type] = :fixed
          Bookable.initialize_acts_as_bookable_core
          @opts[:location] = 'Torino'
        end

        it 'validates with the right fields set' do
          expect(Bookable.validate_booking_options!(@opts)).to be_truthy
        end

        it 'requires location as String' do
          @opts[:location] = nil
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept from_location' do
          @opts[:from_location] = 'String'
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept to_location' do
          @opts[:to_location] = Date.today + 15
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end
      end

      describe ':none' do
        before(:each) do
          Bookable.initialize_acts_as_bookable_core
        end

        it 'doesn\'t accept date' do
          @opts[:location] = Date.today + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept from_location' do
          @opts[:from_location] = Date.today + 13
          expect{ Bookable.validate_booking_options!(@opts) }.to raise_error ActsAsBookable::OptionsInvalid
        end

        it 'doesn\'t accept to_location' do
          @opts[:to_location] = Date.today + 15
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
