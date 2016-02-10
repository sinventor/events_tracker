require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:event) { create(:event) }
  let!(:repeated_event1) { create(:periodic_event1) }
  let(:source_title) { repeated_event1.title }

  describe 'new records generation' do
    it 'should generate new records until end date of series' do
      expect(Event.where(title: source_title).count).to eq 8
    end

    it 'should set base_id for repeated event' do
      expect(Event.where(base_id: repeated_event1.id).count).to eq(7)
    end
  end

  describe 'deleting one based records' do
    let(:sample_event) { Event.where(base_id: repeated_event1.id).sample }

    it 'should delete all one based when requested' do
      sample_event.is_requested_apply_for_all_one_based = true
      sample_event.destroy
      expect(Event.where(title: source_title).count).to eq(0)
    end
  end

end