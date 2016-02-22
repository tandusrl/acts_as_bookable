require 'spec_helper'

describe 'acts_as_bookable' do
  it "should provide a class method 'bookable?' that is false for unbookable models" do
    expect(Unbookable).not_to be_bookable
  end

  describe 'Bookable Method Generation' do
    before :each do
      Unbookable.acts_as_bookable
      @bookable = Unbookable.new()
    end

    it "should respond 'true' to bookable?" do
      expect(@bookable.class).to be_bookable
    end

    it "should use last options inserted if acts_as_bookable is invoked more than once" do
      expect(Unbookable.booking_opts[:capacity_type]).not_to be :open
      Unbookable.acts_as_bookable capacity_type: :open
      expect(Unbookable.booking_opts[:capacity_type]).to be :open
      Unbookable.acts_as_bookable
      expect(Unbookable.booking_opts[:capacity_type]).not_to be :open
    end
  end

  describe 'class configured as Bookable' do
    before(:each) do
      @bookable = Bookable.new
    end

    it 'should add #bookable? query method to the class-side' do
      expect(Bookable).to respond_to(:bookable?)
    end

    it 'should return true from the class-side #bookable?' do
      expect(Bookable.bookable?).to be_truthy
    end

    it 'should return false from the base #bookable?' do
      expect(ActiveRecord::Base.bookable?).to be_falsy
    end

    # it 'should add #tag method on the instance-side' do
    #   expect(@bookable).to respond_to(:tag)
    # end

    # it 'should generate an association for #owned_taggings and #owned_tags' do
    #   expect(@bookable).to respond_to(:owned_taggings, :owned_tags)
    # end
  end

  describe 'Reloading' do
    it 'should save a model instantiated by Model.find' do
      bookable = create(:bookable)
      found_bookable = Bookable.find(bookable.id)
      expect(found_bookable.save).to eq true
    end
  end
end
