require 'spec_helper'

describe 'Bookable' do
  it "should provide a class method 'bookable?' that is false for unbookable models" do
    expect(UnbookableModel).not_to be_bookable
  end

  describe 'Bookable Method Generation' do
    before :each do
      BookableModel.acts_as_bookable
      @bookable = BookableModel.new()
    end

    it "should responde 'true' to bookable?" do
      expect(@bookable.class).to be_taggable
    end
  end
end
