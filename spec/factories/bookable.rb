FactoryBot.define do
  factory :bookable, class: 'Bookable' do
    name 'Bookable name'
    capacity 4
    schedule IceCube::Schedule.new
    ammount 1
  end
end
