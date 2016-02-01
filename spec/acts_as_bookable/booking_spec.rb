require 'spec_helper'

describe 'Booking model' do
  before(:each) do
    @booking = ActsAsBookable::Booking.new
    @booker = Booker.create!(name: 'Booker')
    @bookable = Bookable.create!(name: 'Bookable')
    @booking.booker = @booker
    @booking.bookable = @bookable
  end

  it 'should be valid with all required fields set' do
    expect(@booking).to be_valid
  end

  it 'should save a booking' do
    expect(@booking.save).to be_truthy
  end

  it 'should not be valid without a booker' do
    @booking.booker = nil
    expect(@booking).not_to be_valid
  end

  it 'should not be valid without a bookable' do
    @booking.bookable = nil
    expect(@booking).not_to be_valid
  end

  it 'should not be valid if booking.booker.booker? is false' do
    not_booker = Generic.create(name: 'New generic model')
    @booking.booker = not_booker
    expect(@booking).not_to be_valid
    expect(@booking.errors.messages[:booker]).to be_present
    expect(@booking.errors.messages[:booker][0]).to include "Generic"
    expect(@booking.errors.messages).not_to include "missing translation"
  end

  it 'should not be valid if booking.bookable.bookable? is false' do
    bookable = Generic.create(name: 'New generic model')
    @booking.bookable = bookable
    expect(@booking).not_to be_valid
    expect(@booking.errors.messages[:bookable]).to be_present
    expect(@booking.errors.messages[:bookable][0]).to include "Generic"
    expect(@booking.errors.messages).not_to include "missing translation"
  end

  it 'should belong to booker' do
    expect(@booking.booker.id).to eq @booker.id
  end

  it 'should belong to bookable' do
    expect(@booking.bookable.id).to eq @bookable.id
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
