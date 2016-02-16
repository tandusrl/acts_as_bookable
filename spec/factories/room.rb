FactoryGirl.define do
  factory :room, class: 'Room' do
    name 'Room name'
    capacity 4
    schedule {
      schedule = IceCube::Schedule.new(Date.today, duration: 1.day)
      schedule.add_recurrence_rule IceCube::Rule.daily
      schedule
    }
  end
end
