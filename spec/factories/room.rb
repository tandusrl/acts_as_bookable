FactoryGirl.define do
  factory :room, class: 'Room' do
    name 'Room name'
    capacity 4
    schedule IceCube::Schedule.new
  end
end
