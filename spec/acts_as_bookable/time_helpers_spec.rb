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

  describe '#subintervals' do
    before :each do
      @time = Time.now
    end

    it 'returns ArgumentError if called without an array' do
      expect{ ActsAsBookable::TimeHelpers.subintervals(1) }.to raise_error ArgumentError
    end

    it 'returns ArgumentError if an interval has no time_start or time_end' do
      intervals = [
        {time_start: @time, time_end: @time + 1.hour},
        {time_start: @time}
      ]
      expect{ ActsAsBookable::TimeHelpers.subintervals(1) }.to raise_error ArgumentError
      intervals = [
        {time_start: @time, time_end: @time + 1.hour},
        {time_end: @time}
      ]
      expect{ ActsAsBookable::TimeHelpers.subintervals(1) }.to raise_error ArgumentError
    end

    it 'returns ArgumentError if time_start or time_end is not a Time or Date' do
      intervals = [
        {time_start: @time, time_end: 1}
      ]
      expect{ ActsAsBookable::TimeHelpers.subintervals(1) }.to raise_error ArgumentError
      intervals = [
        {time_start: 2, time_end: @time + 1.hour}
      ]
      expect{ ActsAsBookable::TimeHelpers.subintervals(1) }.to raise_error ArgumentError
    end

    it 'returns empty array if input is an empty array' do
      expect(ActsAsBookable::TimeHelpers.subintervals([])).to eq []
    end

    # |----|
    # =>
    # |----|
    it 'returns a copy of the same interval if input is a single interval' do
      intervals = [
        {time_start: @time, time_end: @time + 1.hour}
      ]
      subintervals = ActsAsBookable::TimeHelpers.subintervals(intervals)
      expect(subintervals.length).to eq 1
      expect(subintervals[0][:time_start]).to eq intervals[0][:time_start]
      expect(subintervals[0][:time_end]).to eq intervals[0][:time_end]
    end

    # |----| |----| |----|
    # =>
    # |----| |----| |----|
    it 'returns a copy of the same intervals if they are all separated' do
      intervals = [
        {time_start: @time, time_end: @time + 1.hour},
        {time_start: @time + 2.hours, time_end: @time + 3.hours},
        {time_start: @time + 4.hours, time_end: @time + 5.hours}
      ]
      subintervals = ActsAsBookable::TimeHelpers.subintervals(intervals)
      expect(subintervals.length).to eq 3
      (0..2).each do |i|
        expect(subintervals[i][:time_start]).to eq intervals[i][:time_start]
        expect(subintervals[i][:time_end]).to eq intervals[i][:time_end]
      end
    end

    #               |----|
    #        |----|
    # |----|
    # =>
    # |----|
    #        |----|
    #               |----|
    it 'returns the sub-intervals sorted' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      time3 = @time + 3.hours
      time4 = @time + 4.hours
      time5 = @time + 5.hours
      time6 = @time + 6.hours

      intervals = [
        {time_start: time4, time_end: time5},
        {time_start: time2, time_end: time3},
        {time_start: time0, time_end: time1}
      ]
      subintervals = ActsAsBookable::TimeHelpers.subintervals(intervals)
      expect(subintervals.length).to eq 3
      expect(subintervals[0][:time_start]).to eq time0
      expect(subintervals[0][:time_end]).to eq time1
      expect(subintervals[1][:time_start]).to eq time2
      expect(subintervals[1][:time_end]).to eq time3
      expect(subintervals[2][:time_start]).to eq time4
      expect(subintervals[2][:time_end]).to eq time5
    end

    # |----|
    # |----|
    # |----|
    # =>
    # |----|
    it 'merges intervals if they have same time_start and time_end' do
      intervals = [
        {time_start: @time, time_end: @time + 1.hour},
        {time_start: @time, time_end: @time + 1.hour},
        {time_start: @time, time_end: @time + 1.hour}
      ]
      subintervals = ActsAsBookable::TimeHelpers.subintervals(intervals)
      expect(subintervals.length).to eq 1
      expect(subintervals[0][:time_start]).to eq intervals[0][:time_start]
      expect(subintervals[0][:time_end]).to eq intervals[0][:time_end]
    end

    # |---|
    # |------|
    # =>
    # |---|
    #     |--|
    it 'returns two intervals if input is 2 intervals with same time_start and different time_end' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      intervals = [
        {time_start: time0, time_end: time1},
        {time_start: time0, time_end: time2}
      ]
      subintervals = ActsAsBookable::TimeHelpers.subintervals(intervals)
      expect(subintervals.length).to eq 2
      expect(subintervals[0][:time_start]).to eq time0
      expect(subintervals[0][:time_end]).to eq time1
      expect(subintervals[1][:time_start]).to eq time1
      expect(subintervals[1][:time_end]).to eq time2
    end

    # |------|
    #    |---|
    # =>
    # |--|
    #    |---|
    it 'returns two intervals if input is 2 intervals with same time_end and different time_start' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      intervals = [
        {time_start: time0, time_end: time2},
        {time_start: time1, time_end: time2}
      ]
      subintervals = ActsAsBookable::TimeHelpers.subintervals(intervals)
      expect(subintervals.length).to eq 2
      expect(subintervals[0][:time_start]).to eq time0
      expect(subintervals[0][:time_end]).to eq time1
      expect(subintervals[1][:time_start]).to eq time1
      expect(subintervals[1][:time_end]).to eq time2
    end

    # |---------|
    #    |---|
    # =>
    # |--|
    #    |---|
    #        |--|
    it 'returns three intervals if one includes another' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      time3 = @time + 3.hours
      intervals = [
        {time_start: time0, time_end: time3},
        {time_start: time1, time_end: time2}
      ]
      subintervals = ActsAsBookable::TimeHelpers.subintervals(intervals)
      expect(subintervals.length).to eq 3
      expect(subintervals[0][:time_start]).to eq time0
      expect(subintervals[0][:time_end]).to eq time1
      expect(subintervals[1][:time_start]).to eq time1
      expect(subintervals[1][:time_end]).to eq time2
      expect(subintervals[2][:time_start]).to eq time2
      expect(subintervals[2][:time_end]).to eq time3
    end

    # |---2---|
    #     |------4------|
    # |----3------|
    #                      |----1----|
    #                      |----8----|
    # =>
    # |-5-|
    #     |-9-|
    #         |-7-|
    #             |--4--|
    #                      |----9----|
    it 'correctly merges interval attributes' do
      time0 = @time
      time1 = @time + 1.hour
      time2 = @time + 2.hours
      time3 = @time + 3.hours
      time4 = @time + 4.hours
      time5 = @time + 5.hours
      time6 = @time + 6.hours
      intervals = [
        {time_start: time0, time_end: time2, attr: 2},
        {time_start: time1, time_end: time4, attr: 4},
        {time_start: time0, time_end: time3, attr: 3},
        {time_start: time5, time_end: time6, attr: 1},
        {time_start: time5, time_end: time6, attr: 8}
      ]
      subintervals = ActsAsBookable::TimeHelpers.subintervals(intervals) do |a,b,op|
          if op == :open
            res = {attr: a[:attr] + b[:attr]}
          end
          if op == :close
            res = {attr: a[:attr] - b[:attr]}
          end
          res
      end
      expect(subintervals.length).to eq 5
      expect(subintervals[0][:time_start]).to eq time0
      expect(subintervals[0][:time_end]).to eq time1
      expect(subintervals[0][:attr]).to eq 5
      expect(subintervals[1][:time_start]).to eq time1
      expect(subintervals[1][:time_end]).to eq time2
      expect(subintervals[1][:attr]).to eq 9
      expect(subintervals[2][:time_start]).to eq time2
      expect(subintervals[2][:time_end]).to eq time3
      expect(subintervals[2][:attr]).to eq 7
      expect(subintervals[3][:time_start]).to eq time3
      expect(subintervals[3][:time_end]).to eq time4
      expect(subintervals[3][:attr]).to eq 4
      expect(subintervals[4][:time_start]).to eq time5
      expect(subintervals[4][:time_end]).to eq time6
      expect(subintervals[4][:attr]).to eq 9
    end
  end
end
