require 'spec_helper'

describe 'Booking model' do
  before(:each) do
    @booking = ActsAsBookable::Booking.new(amount: 2)
    @booker = create(:booker)
    @bookable = create(:bookable)
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
end
