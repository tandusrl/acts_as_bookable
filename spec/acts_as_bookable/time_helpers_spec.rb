require 'spec_helper'

describe 'ActsAsBookable::TimeHelpers' do

  describe '#time_in_interval?' do
    before :each do
      @interval_start = Time.now
      @interval_end = Time.now + 1.hour
    end

    describe 'returns true' do
      it 'when time is the interval_start' do
        time = @interval_start
        expect(ActsAsBookable::TimeHelpers.time_in_interval?(time,@interval_start,@interval_end)).to eq true
      end

      it 'when time is bewteen interval_start and interval_end' do
        time = @interval_start + 5.minutes
        expect(ActsAsBookable::TimeHelpers.time_in_interval?(time,@interval_start,@interval_end)).to eq true
      end

      it 'when time is very close to interval end' do
        time = @interval_end - 1.second
        expect(ActsAsBookable::TimeHelpers.time_in_interval?(time,@interval_start,@interval_end)).to eq true
      end

    end

    describe 'returns false' do
      it 'when time is before interval_start' do
        time = @interval_start - 1.second
        expect(ActsAsBookable::TimeHelpers.time_in_interval?(time,@interval_start,@interval_end)).to eq false
      end

      it 'when time is after interval_end' do
        time = @interval_end + 1.second
        expect(ActsAsBookable::TimeHelpers.time_in_interval?(time,@interval_start,@interval_end)).to eq false
      end

      it 'when time is interval_end' do
        time = @interval_end
        expect(ActsAsBookable::TimeHelpers.time_in_interval?(time,@interval_start,@interval_end)).to eq false
      end
    end
  end

  describe '#interval_in_schedule?' do
    before :each do
      @day0 = '2016-01-05'.to_date
      @schedule = IceCube::Schedule.new(@day0,duration: 1.day)
      @schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(1,3,5,7)
    end

    describe 'returns true' do
      it 'when range starts and ends in the middle of an occurrence' do
        time_start = @day0 + 1.hour
        time_end = @day0 + 3.hours
        expect(ActsAsBookable::TimeHelpers.interval_in_schedule?(@schedule,time_start,time_end)).to eq true
      end

      it 'when range starts and ends in the middle of another occurrence' do
        time_start = @day0 + 2.days + 1.hour
        time_end = @day0 + 2.days + 3.hours
        expect(ActsAsBookable::TimeHelpers.interval_in_schedule?(@schedule,time_start,time_end)).to eq true
      end

      it 'when range starts at the beginning of an occurrence and ends at the end of the same occurence' do
        time_start = @day0
        time_end = @day0 + 1.day - 1.second
        expect(ActsAsBookable::TimeHelpers.interval_in_schedule?(@schedule,time_start,time_end)).to eq true
      end
    end

    describe 'retuns false' do
      it 'when range starts and ends outside any occurrence' do
        time_start = '2016-01-15'.to_date
        time_end = time_start + 1.day
        expect(ActsAsBookable::TimeHelpers.interval_in_schedule?(@schedule,time_start,time_end)).to eq false
      end

      it 'when range starts and ends outside any occurrence but contains an occurrence' do
        time_start = @day0 - 1.hour
        time_end = @day0 + 1.day + 1.hour
        expect(ActsAsBookable::TimeHelpers.interval_in_schedule?(@schedule,time_start,time_end)).to eq false
      end

      it 'when range starts within an occurrence but ends outside it' do
        time_start = @day0 + 1.hour
        time_end = @day0 + 1.day + 1.hour
        expect(ActsAsBookable::TimeHelpers.interval_in_schedule?(@schedule,time_start,time_end)).to eq false
      end

      it 'when range starts outside any occurrence but ends within an occurrence' do
        time_start = @day0 - 1.hour
        time_end = @day0 + 1.hour
        expect(ActsAsBookable::TimeHelpers.interval_in_schedule?(@schedule,time_start,time_end)).to eq false
      end

      it 'when range starts within an occurrence and ends within a different occurrence' do
        time_start = @day0 + 1.hour
        time_end = @day0 + 2.days + 1.hour
        expect(ActsAsBookable::TimeHelpers.interval_in_schedule?(@schedule,time_start,time_end)).to eq false
      end

      it 'when range starts within an occurrence and ends just after the end of the same occurrence' do
        time_start = @day0 + 1.hour
        time_end = @day0 + 1.day
        expect(ActsAsBookable::TimeHelpers.interval_in_schedule?(@schedule,time_start,time_end)).to eq false
      end
    end
  end

  describe '#time_in_schedule?' do
    before :each do
      @day0 = '2016-01-05'.to_date
      @schedule = IceCube::Schedule.new(@day0,duration: 1.day)
      @schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(1,3,5,7)
    end

    describe 'returns true' do
      it 'when time is at the beginning of an occurrence' do
        time = @day0
        expect(ActsAsBookable::TimeHelpers.time_in_schedule?(@schedule,time)).to eq true
      end

      it 'when time is in the middle of an occurrence' do
        time = @day0 + 5.hours
        expect(ActsAsBookable::TimeHelpers.time_in_schedule?(@schedule,time)).to eq true
      end

      it 'when time is at the end of an occurrence' do
        time = @day0 + 1.day - 1.second
        expect(ActsAsBookable::TimeHelpers.time_in_schedule?(@schedule, time)).to eq true
      end
    end

    describe 'retuns false' do
      it 'when time is outside an occurrence' do
        time = '2016-01-15'.to_date
        expect(ActsAsBookable::TimeHelpers.time_in_schedule?(@schedule, time)).to eq false
      end

      it 'when time is close to the end of an occurrence, but outside it' do
        time = @day0 + 1.day
        expect(ActsAsBookable::TimeHelpers.time_in_schedule?(@schedule, time)).to eq false
      end

      it 'when time is close to the beginning of an occurrence, but outside it' do
        time = @day0 + 2.days - 1.second
      end
    end
  end
end
