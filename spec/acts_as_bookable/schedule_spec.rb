require 'spec_helper'

describe 'Schedules' do
  describe "Room schedules" do
    before :each do
      @test_from = '2016-02-01'.to_date # it's a monday
      @schedule = IceCube::Schedule.new @test_from
      @schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday,:tuesday,:wednesday,:thursday,:friday)
    end

    it "Weekly, From monday to friday" do
      # Weekly, From monday to friday
      expect(@schedule.occurring_at?(@test_from)).to be true
      expect(@schedule.occurring_at?(@test_from + 1.day)).to be true
      expect(@schedule.occurring_at?(@test_from + 2.day)).to be true
      expect(@schedule.occurring_at?(@test_from + 3.day)).to be true
      expect(@schedule.occurring_at?(@test_from + 4.day)).to be true
      expect(@schedule.occurring_at?(@test_from + 5.day)).to be false
      expect(@schedule.occurring_at?(@test_from + 6.day)).to be false
    end

    it "doesn't match if not at exact minute" do
      expect(@schedule.occurring_at?(@test_from + 1.minute)).to be false
    end

    describe "with daily duration" do
      before :each do
        @test_from = '2016-02-01'.to_date # it's a monday
        @schedule = IceCube::Schedule.new @test_from
        @schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday,:tuesday,:wednesday,:thursday,:friday)
        @schedule.duration = 1.day
      end

      it "match with the exact minute" do
        # Weekly, From monday to friday
        expect(@schedule.occurring_at?(@test_from)).to be true
      end

      it "matches if not at exact minute" do
        expect(@schedule.occurring_at?(@test_from + 1.minute)).to be true
      end

      it "matches if at end of day" do
        expect(@schedule.occurring_at?(@test_from + 1.day - 1.minute)).to be true
        expect(@schedule.occurring_at?(@test_from + 1.day - 1.minute)).to be true
        expect(@schedule.occurring_at?(@test_from + 4.day - 1.second)).to be true
        expect(@schedule.occurring_at?(@test_from + 4.day - 1.second)).to be true
      end

      it "doesn't match at the first second of the first day not included" do
        expect(@schedule.occurring_at?(@test_from + 5.days)).to be false
        expect(@schedule.occurring_at?(@test_from + 5.days + 1.second)).to be false
      end
    end

    describe "except the first and the last day of the month" do
      before :each do
        @test_from = '2016-02-01'.to_date # it's a monday
        @schedule = IceCube::Schedule.new @test_from
        @schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday,:tuesday,:wednesday,:thursday,:friday)
        @schedule.add_exception_rule IceCube::Rule.monthly.day_of_month(1, -1)
      end

      it "doesn't match on the first of the month" do
        expect(@schedule.occurring_at?(@test_from)).to be false
        expect(@schedule.occurring_at?(@test_from.end_of_month)).to be false
        expect(@schedule.occurring_at?(@test_from + 1.month)).to be false
        expect(@schedule.occurring_at?((@test_from + 1.month).end_of_month)).to be false
        expect(@schedule.occurring_at?('2017-01-01'.to_date)).to be false # sunday
        expect(@schedule.occurring_at?('2017-01-01'.to_date + 1.second)).to be false # sunday
        expect(@schedule.occurring_at?('2017-01-01'.to_date + 1.day)).to be true # monday
      end
    end
  end

  describe "Gym schedules" do
    before :each do
      # Mon         | Tue   | Wed         | Thu   | Fri | Sat   |Sun
      # 9-10        | 10-11 | 9-10        | 10-11 |     | 14-15 |
      # 18:10-19:10 | 20-21 | 18:10-19:10 | 20-21 |     |       |
      # Except for the third saturday of the month
      @test_from = '2016-02-01'.to_date # it's a monday
      @schedule = IceCube::Schedule.new(@test_from, duration: 1.hour)
      @schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday,:wednesday).hour_of_day(9)
      @schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday,:wednesday).hour_of_day(18).minute_of_hour(10)
      @schedule.add_recurrence_rule IceCube::Rule.weekly.day(:tuesday,:thursday).hour_of_day(10,20)
      @schedule.add_recurrence_rule IceCube::Rule.weekly.day(:saturday).hour_of_day(14)
      @schedule.add_exception_rule IceCube::Rule.monthly.day_of_week(saturday: [3]).hour_of_day(14)
      @schedule.add_exception_rule IceCube::Rule.monthly.day_of_week(wednesday: [3]).hour_of_day(9)
    end

    it "matches at the occurrences" do
      (0...12).each do |i|
        minute = (i * 5).minutes
        expect(@schedule.occurring_at?(@test_from + 9.hours + minute)).to be true # monday
        expect(@schedule.occurring_at?(@test_from + 18.hours + 10.minutes + minute)).to be true # monday
        expect(@schedule.occurring_at?(@test_from + 5.days + 14.hours + minute)).to be true # tuesday
      end
    end

    it "doesn't match close to the occurrences" do
      expect(@schedule.occurring_at?(@test_from + 9.hours - 1.minute)).to be false # monday
      expect(@schedule.occurring_at?(@test_from + 10.hours)).to be false # monday
      expect(@schedule.occurring_at?(@test_from + 18.hours + 9.minutes)).to be false # monday
      expect(@schedule.occurring_at?(@test_from + 19.hours + 9.minutes)).to be true # monday
      expect(@schedule.occurring_at?(@test_from + 19.hours + 10.minutes)).to be false # monday
    end

    it "doesn't match the saturday of the third week of the month" do
      (0...12).each do |i|
        minute = (i * 5).minutes
        expect(@schedule.occurring_at?('2016-02-20'.to_date + 14.hours + minute)).to be false # monday
      end
    end

    describe "borderline matchings" do
      before :each do
        # Except the third wednesday of the month
        @test_from = '2016-02-01'.to_date # it's a monday
        @schedule = IceCube::Schedule.new(@test_from)
        @schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_week(wednesday: [3])
      end

      it "matches the third wednesday of the month, in normal conditions" do
        expect(@schedule.occurring_at?('2016-02-17'.to_date)).to be true
      end

      it "matches the third wednesday of the month, if the month starts on friday" do
        expect(@schedule.occurring_at?('2016-04-20'.to_date)).to be true
      end

      it "doesn't match the wednesday of the third week of the month, if the month starts on friday" do
        expect(@schedule.occurring_at?('2016-04-13'.to_date)).to be false
      end
    end
  end
end
