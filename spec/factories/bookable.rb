FactoryGirl.define do
  factory :bookable, class: 'Bookable' do
    name 'Bookable name'
    capacity 4
    schedule 'ever'
  end
end
