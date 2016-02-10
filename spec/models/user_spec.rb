require 'rails_helper'

RSpec.describe User, type: :model do
  describe '' do
  end
  describe "generating one based records" do
    let!(:user) { build(:user) }
    # let(:user2) { create(:user) }

    it 'should create ' do
    end

    it "should create new records" do
      # puts user.inspect
      # puts user2.inspect
      expect(user.valid?).to eq(true)
      # expect { user.email }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Password confirmation doesn't match Password")
    end
  end
end
