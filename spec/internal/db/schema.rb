ActiveRecord::Schema.define version: 0 do
  create_table :acts_as_bookable_bookings, force: true do |t|
    t.references :bookable, polymorphic: true
    t.references :booker, polymorphic: true
    t.column :amount, :integer
    t.column :schedule, :text
    t.column :time_start, :datetime
    t.column :time_end, :datetime
    t.column :time, :datetime
    t.datetime :created_at
  end

  create_table :bookables, force: true do |t|
    t.column :name, :string
    t.column :schedule, :text
    t.column :capacity, :integer
  end

  create_table :rooms, force: true do |t|
    t.column :name, :string
    t.column :schedule, :text
    t.column :capacity, :integer
  end

  create_table :events, force: true do |t|
    t.column :name, :string
    t.column :capacity, :integer
  end

  create_table :shows, force: true do |t|
    t.column :name, :string
    t.column :schedule, :text
    t.column :capacity, :integer
  end

  create_table :unbookables, force: true do |t|
    t.column :name, :string
  end

  create_table :not_bookers, force: true do |t|
    t.column :name, :string
  end

  create_table :generics, force: true do |t|
    t.column :name, :string
  end

  create_table :bookers, force: true do |t|
    t.column :name, :string
  end
end
