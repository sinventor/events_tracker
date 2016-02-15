require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'creating new records' do
    let!(:user) { build(:user) }
    let(:invalid_user) { create(:invalid_user) }

    it 'user should valid' do
      expect(user.valid?).to eq(true)
    end

    it 'should raise error when password confirmation not match' do
      expect { invalid_user }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Password confirmation doesn't match Password")
    end

    describe 'not required fields' do
      let!(:user_without_full_name) { create(:user_without_full_name) }

      it 'full_name field is not required' do
        expect(user_without_full_name.valid?).to eq(true)
      end
    end
  end
end
