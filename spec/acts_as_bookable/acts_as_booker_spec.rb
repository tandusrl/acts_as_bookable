require 'spec_helper'

describe 'acts_as_booker' do
  it "should provide a class method 'booker?' that is false for not booker models" do
    expect(NotBooker).not_to be_booker
  end

  describe 'Booker Method Generation' do
    before :each do
      NotBooker.acts_as_booker
      @booker = NotBooker.new()
    end

    it "should respond 'true' to booker?" do
      expect(@booker.class).to be_booker
    end
  end

  describe 'class configured as Booker' do
    before(:each) do
      @booker = Booker.new
    end

    it 'should add #booker? query method to the class-side' do
      expect(Booker).to respond_to(:booker?)
    end

    it 'should return true from the class-side #booker?' do
      expect(Booker.booker?).to be_truthy
    end

    it 'should return false from the base #booker?' do
      expect(ActiveRecord::Base.booker?).to be_falsy
    end

    it 'should add #booker? query method to the instance-side' do
      expect(@booker).to respond_to(:booker?)
    end

    it 'should add #booker? query method to the instance-side' do
      expect(@booker.booker?).to be_truthy
    end


    # it 'should generate an association for #owned_taggings and #owned_tags' do
    #   expect(@booker).to respond_to(:owned_taggings, :owned_tags)
    # end
  end

  describe 'Reloading' do
    it 'should save a model instantiated by Model.find' do
      booker = Booker.create!(name: 'Booker')
      found_booker = Booker.find(booker.id)
      expect(found_booker.save).to eq true
    end
  end
end
