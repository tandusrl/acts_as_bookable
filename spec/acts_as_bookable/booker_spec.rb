require 'spec_helper'

describe 'Booker model' do
  before(:each) do
    @booker = Booker.new
  end

  it 'should be valid with all required fields set' do
    expect(@booker).to be_valid
  end

  it 'should save a booker' do
    expect(@booker.save).to be_truthy
  end

  describe 'has_many :bookings' do
    before(:each) do
      @booker.save!
      bookable1 = Bookable.create(name: 'Bookable 1')
      bookable2 = Bookable.create(name: 'Bookable 2')
      booking1 = ActsAsBookable::Booking.create(bookable: bookable1, booker: @booker)
      booking2 = ActsAsBookable::Booking.create(bookable: bookable2, booker: @booker)
      @booker.reload
    end

    it 'should have many bookings' do
      expect(@booker.bookings).to be_present
      expect(@booker.bookings.count).to eq 2
    end

    it 'dependent: :destroy' do
      count = ActsAsBookable::Booking.count
      @booker.destroy
      expect(ActsAsBookable::Booking.count).to eq count -2
    end
  end

  describe '#book' do
    before(:each) do
      @bookable = Bookable.create(name: 'Bookable')
    end

    it 'should respond to #book' do
      expect(@booker).to respond_to :book
    end

    it 'should create a new booking' do
      count = ActsAsBookable::Booking.count
      @booker.book(@bookable)

    end
  end



  # describe 'Booker Method Generation' do
  #   before :each do
  #     Generic.acts_as_booker
  #     @booker = Generic.new()
  #   end
  #
  #   it "should responde 'true' to booker?" do
  #     expect(@booker.class).to be_booker
  #   end
  # end
  #
  # describe 'class configured as Booker' do
  #   before(:each) do
  #     @booker = Booker.new
  #   end
  #
  #   it 'should add #booker? query method to the class-side' do
  #     expect(Booker).to respond_to(:booker?)
  #   end
  #
  #   it 'should return true from the class-side #booker?' do
  #     expect(Booker.booker?).to be_truthy
  #   end
  #
  #   it 'should return false from the base #booker?' do
  #     expect(ActiveRecord::Base.booker?).to be_falsy
  #   end
  #
  #   it 'should add #booker? query method to the singleton' do
  #     expect(@booker).to respond_to(:booker?)
  #   end
  #
  #   it 'should add #booker? query method to the instance-side' do
  #     expect(@booker).to respond_to(:booker?)
  #   end
  #
  #   it 'should add #booker? query method to the instance-side' do
  #     expect(@booker.booker?).to be_truthy
  #   end
  #
  #   # it 'should add #tag method on the instance-side' do
  #   #   expect(@booker).to respond_to(:tag)
  #   # end
  #
  #   # it 'should generate an association for #owned_taggings and #owned_tags' do
  #   #   expect(@booker).to respond_to(:owned_taggings, :owned_tags)
  #   # end
  # end
  #
  # describe 'Reloading' do
  #   it 'should save a model instantiated by Model.find' do
  #     booker = Generic.create!(name: 'Booker')
  #     found_booker = Generic.find(booker.id)
  #     expect(found_booker.save).to eq true
  #   end
  # end
end
